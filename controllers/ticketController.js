const pool = require('../config/db');
const { calculatePriority, calculateSLA, autoAssign } = require('../utils/ticketUtils');

// Create Ticket
exports.createTicket = async (req, res) => {
    // Basic fields + Mapping camelCase to snake_case
    const { title, description, urgency, impact, category, type, channel } = req.body;
    const asset_id = req.body.assetId || req.body.asset_id;
    const user_email = req.body.userEmail || req.body.user_email;

    try {
        // 2. Calculate SLA
        const priority = calculatePriority(urgency || 'Medium', impact || 'Medium'); // restore priority calc too if missing
        const { responseDue, resolveDue } = await calculateSLA(priority);

        // 3. Generate ID (Simple increment logic or UUID, here using TK-YYYY-Rand for demo simplicity or fetching max)
        // For production, better ID generation is needed. Here mimicking the format TK-2024-XXX
        const year = new Date().getFullYear();
        const [maxIdResult] = await pool.query('SELECT id FROM tickets WHERE id LIKE ? ORDER BY id DESC LIMIT 1', [`TK-${year}-%`]);
        let nextSeq = 1;
        if (maxIdResult.length > 0) {
            const lastId = maxIdResult[0].id;
            const lastSeq = parseInt(lastId.split('-')[2]);
            nextSeq = lastSeq + 1;
        }
        const ticketId = `TK-${year}-${String(nextSeq).padStart(3, '0')}`;

        // 4. Auto-Assign Logic
        let status = 'Open';
        let assignee = null;

        // Only auto-assign if not already assigned (if frontend allows manual assignment)
        assignee = await autoAssign(category);
        if (assignee) {
            status = 'In Progress';
        }

        // 5. Insert Ticket
        const query = `
            INSERT INTO tickets 
            (id, title, description, status, priority, type, category, user_email, channel, asset_id, urgency, impact, sla_response_due, sla_resolve_due, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        `;
        await pool.query(query, [
            ticketId, title, description, status, priority, type || 'Incident', category, user_email, channel || 'Web Portal', asset_id, urgency, impact, responseDue, resolveDue
        ]);

        // 6. Handle Assignee Insertion
        if (assignee) {
            await pool.query('INSERT INTO ticket_assignees (ticket_id, user_id) VALUES (?, ?)', [ticketId, assignee.id]);
        }

        // 7. Initial Timeline Entry
        await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, created_at) VALUES (?, ?, ?, NOW())', [
            ticketId, 'Created', user_email // Assuming user_email matches a user, or finding name
        ]);

        if (assignee) {
            await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
                ticketId, 'Auto-Assigned', 'System', `Assigned to ${assignee.name} based on skill match`,
            ]);
        }

        res.status(201).json({
            id: ticketId,
            message: 'Ticket created successfully',
            assignedTo: assignee ? assignee.name : null
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get All Tickets (with filters & pagination)
exports.getAllTickets = async (req, res) => {
    try {
        const { status, priority, category, assignee_id, user_email, search, page = 1, limit = 1000 } = req.query;
        const offset = (page - 1) * limit;

        let query = `
            SELECT t.*, 
            GROUP_CONCAT(DISTINCT u.name) as assignees_names,
            GROUP_CONCAT(DISTINCT u.id) as assignee_ids
            FROM tickets t 
            LEFT JOIN ticket_assignees ta ON t.id = ta.ticket_id 
            LEFT JOIN users u ON ta.user_id = u.id
        `;
        let params = [];
        let conditions = [];

        if (status) { conditions.push('t.status = ?'); params.push(status); }
        if (priority) { conditions.push('t.priority = ?'); params.push(priority); }
        if (category) { conditions.push('t.category = ?'); params.push(category); }
        if (user_email) { conditions.push('t.user_email = ?'); params.push(user_email); } // For "My Tickets"
        if (assignee_id) {
            conditions.push('ta.user_id = ?'); params.push(assignee_id);
        }
        if (search) {
            conditions.push('(t.title LIKE ? OR t.id LIKE ?)');
            params.push(`%${search}%`);
            params.push(`%${search}%`);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ') + ' AND t.deleted_at IS NULL';
        } else {
            query += ' WHERE t.deleted_at IS NULL';
        }

        query += ' GROUP BY t.id ORDER BY t.created_at DESC LIMIT ? OFFSET ?';
        params.push(parseInt(limit), parseInt(offset));

        const [rows] = await pool.query(query, params);

        // Convert keys to camelCase
        const tickets = rows.map(t => ({
            id: t.id,
            title: t.title,
            description: t.description,
            status: t.status,
            priority: t.priority,
            type: t.type,
            category: t.category,
            userEmail: t.user_email,
            channel: t.channel,
            assetId: t.asset_id,
            urgency: t.urgency,
            impact: t.impact,
            slaResponseDue: t.sla_response_due,
            slaResolveDue: t.sla_resolve_due,
            slaResponseMet: t.sla_response_met,
            slaResolveMet: t.sla_resolve_met,
            csatScore: t.csat_score,
            csatComment: t.csat_comment,
            createdAt: t.created_at,
            updatedAt: t.updated_at,
            assigneeIds: t.assignee_ids ? t.assignee_ids.split(',').map(id => {
                const num = Number(id);
                return isNaN(num) ? id : num;
            }) : [],
            assigneesNames: t.assignees_names
        }));

        res.json(tickets);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get Single Ticket Details
exports.getTicketById = async (req, res) => {
    try {
        const ticketId = req.params.id;
        const [ticketRows] = await pool.query('SELECT * FROM tickets WHERE id = ? AND deleted_at IS NULL', [ticketId]);

        if (ticketRows.length === 0) {
            return res.status(404).json({ message: 'Ticket not found' });
        }
        const ticket = ticketRows[0];

        // Fetch related data
        const [assignees] = await pool.query('SELECT u.id, u.name, u.avatar FROM ticket_assignees ta JOIN users u ON ta.user_id = u.id WHERE ta.ticket_id = ?', [ticketId]);
        const [timeline] = await pool.query('SELECT * FROM ticket_timeline WHERE ticket_id = ? ORDER BY created_at ASC', [ticketId]);
        const [attachments] = await pool.query('SELECT * FROM ticket_attachments WHERE ticket_id = ?', [ticketId]);

        res.json({
            id: ticket.id,
            title: ticket.title,
            description: ticket.description,
            status: ticket.status,
            priority: ticket.priority,
            type: ticket.type,
            category: ticket.category,
            userEmail: ticket.user_email,
            channel: ticket.channel,
            assetId: ticket.asset_id,
            urgency: ticket.urgency,
            impact: ticket.impact,
            slaResponseDue: ticket.sla_response_due,
            slaResolveDue: ticket.sla_resolve_due,
            slaResponseMet: ticket.sla_response_met,
            slaResolveMet: ticket.sla_resolve_met,
            csatScore: ticket.csat_score,
            csatComment: ticket.csat_comment,
            internalNote: ticket.internal_note,
            pendingReason: ticket.pending_reason,
            rootCause: ticket.root_cause,
            resolutionNote: ticket.resolution_note,
            createdAt: ticket.created_at,
            updatedAt: ticket.updated_at,
            assignees,
            assigneeIds: assignees.map(a => a.id),
            timeline: timeline.map(t => ({ ...t, date: t.created_at, user: t.user_name, action: t.action, detail: t.detail })), // Map to frontend expected keys
            attachments: attachments.map(a => ({ ...a, createdAt: a.created_at, fileName: a.file_name, filePath: a.file_path, fileType: a.file_type }))
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update Ticket Status/Fields
exports.updateTicket = async (req, res) => {
    try {
        const ticketId = req.params.id;
        const updates = req.body;
        // Mapping Map
        const fieldMap = {
            internalNote: 'internal_note',
            pendingReason: 'pending_reason',
            rootCause: 'root_cause',
            resolutionNote: 'resolution_note'
        };

        // Whitelist allowed fields to update
        const allowedFields = ['status', 'priority', 'internal_note', 'pending_reason', 'root_cause', 'resolution_note', 'urgency', 'impact'];

        // 1. Check if ticket is closed
        const [current] = await pool.query('SELECT status FROM tickets WHERE id = ?', [ticketId]);
        if (current.length === 0) return res.status(404).json({ message: 'Ticket not found' });

        const isITManager = req.user && (req.user.role === 'IT Manager' || req.user.role === 'Admin' || req.user.role === 'admin');
        if (current[0].status === 'Closed' && !isITManager) {
            return res.status(403).json({ message: 'Cannot update a closed ticket. Only IT Managers can perform this action.' });
        }

        let updateQuery = 'UPDATE tickets SET ';
        let params = [];
        let hasUpdates = false;

        Object.keys(updates).forEach(key => {
            let dbField = allowedFields.includes(key) ? key : fieldMap[key];
            if (dbField && allowedFields.includes(dbField) && updates[key] !== undefined) {
                updateQuery += `${dbField} = ?, `;
                params.push(updates[key]);
                hasUpdates = true;
            }
        });

        if (hasUpdates) {
            updateQuery = updateQuery.slice(0, -2); // Remove trailing comma
            updateQuery += ' WHERE id = ?';
            params.push(ticketId);
            await pool.query(updateQuery, params);
        }

        // Handle Assignees (if provided)
        if (updates.assigneeIds && Array.isArray(updates.assigneeIds)) {
            // Check subordinate/peer permission (only IT Manager can reassign any ticket)
            if (!isITManager) {
                // Get the requesting user's supervisor_id
                const [reqUserRows] = await pool.query('SELECT supervisor_id FROM users WHERE id = ?', [req.user.id]);
                const reqSupervisorId = reqUserRows.length > 0 ? reqUserRows[0].supervisor_id : null;

                // Get current assignees for this ticket
                const [currentAssignees] = await pool.query(
                    'SELECT ta.user_id, u.supervisor_id FROM ticket_assignees ta JOIN users u ON ta.user_id = u.id WHERE ta.ticket_id = ?',
                    [ticketId]
                );
                // Check if at least one current assignee is self, a subordinate, OR a peer (same supervisor)
                const hasPermission = currentAssignees.some(a =>
                    a.user_id === req.user.id || // self (own ticket)
                    a.supervisor_id === req.user.id || // subordinate
                    (reqSupervisorId && a.supervisor_id === reqSupervisorId) // peer (same supervisor)
                );
                if (!hasPermission) {
                    return res.status(403).json({ message: 'คุณสามารถเปลี่ยนผู้รับผิดชอบได้เฉพาะเคสของผู้ใต้บังคับบัญชาหรือผู้ที่มีตำแหน่งเทียบเท่าเท่านั้น' });
                }
            }

            // Delete existing
            await pool.query('DELETE FROM ticket_assignees WHERE ticket_id = ?', [ticketId]);

            // Insert new
            if (updates.assigneeIds.length > 0) {
                const values = updates.assigneeIds.map(uid => [ticketId, uid]);
                await pool.query('INSERT INTO ticket_assignees (ticket_id, user_id) VALUES ?', [values]);
            }

            // Log to timeline
            await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
                ticketId, 'Assignees Updated', req.user ? req.user.username : 'System', `Assignees set to: ${updates.assigneeIds.join(', ')}`
            ]);
        }

        // Log to timeline if status changed
        if (updates.status) {
            await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
                ticketId, 'Status Update', req.user ? req.user.username : 'System', `Status changed to ${updates.status}`
            ]);
        }

        // Return the updated ticket data
        const [updatedRows] = await pool.query('SELECT * FROM tickets WHERE id = ?', [ticketId]);
        const [assignees] = await pool.query('SELECT u.id, u.name FROM ticket_assignees ta JOIN users u ON ta.user_id = u.id WHERE ta.ticket_id = ?', [ticketId]);

        const t = updatedRows[0];
        res.json({
            id: t.id,
            title: t.title,
            description: t.description,
            status: t.status,
            priority: t.priority,
            type: t.type,
            category: t.category,
            userEmail: t.user_email,
            channel: t.channel,
            assetId: t.asset_id,
            urgency: t.urgency,
            impact: t.impact,
            internalNote: t.internal_note,
            pendingReason: t.pending_reason,
            rootCause: t.root_cause,
            resolutionNote: t.resolution_note,
            slaResponseDue: t.sla_response_due,
            slaResolveDue: t.sla_resolve_due,
            slaResponseMet: t.sla_response_met,
            slaResolveMet: t.sla_resolve_met,
            createdAt: t.created_at,
            updatedAt: t.updated_at,
            assigneeIds: assignees.map(a => a.id),
            assigneesNames: assignees.map(a => a.name).join(', ')
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteTicket = async (req, res) => {
    try {
        const ticketId = req.params.id;
        await pool.query('UPDATE tickets SET deleted_at = NOW() WHERE id = ?', [ticketId]);
        res.json({ message: 'Ticket deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Manage Assignees
exports.assignTicket = async (req, res) => {
    try {
        const ticketId = req.params.id;
        const { user_id, action } = req.body; // action: 'add' or 'remove'

        if (!user_id || !action) {
            return res.status(400).json({ message: 'User ID and action are required' });
        }

        if (action === 'add') {
            // Check if already assigned
            const [existing] = await pool.query('SELECT * FROM ticket_assignees WHERE ticket_id = ? AND user_id = ?', [ticketId, user_id]);
            if (existing.length === 0) {
                await pool.query('INSERT INTO ticket_assignees (ticket_id, user_id) VALUES (?, ?)', [ticketId, user_id]);

                // Add timeline entry
                const [user] = await pool.query('SELECT name FROM users WHERE id = ?', [user_id]);
                const assigneeName = user.length > 0 ? user[0].name : user_id;

                await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
                    ticketId, 'Assign', req.user ? req.user.username : 'System', `Assigned to ${assigneeName}`
                ]);
            }
        } else if (action === 'remove') {
            await pool.query('DELETE FROM ticket_assignees WHERE ticket_id = ? AND user_id = ?', [ticketId, user_id]);

            // Add timeline entry
            const [user] = await pool.query('SELECT name FROM users WHERE id = ?', [user_id]);
            const assigneeName = user.length > 0 ? user[0].name : user_id;

            await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
                ticketId, 'Unassign', req.user ? req.user.username : 'System', `Removed assignment from ${assigneeName}`
            ]);
        }

        res.json({ message: 'Assignment updated' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Add Timeline Comment
exports.addComment = async (req, res) => {
    try {
        const ticketId = req.params.id;
        const { detail } = req.body;

        // Check if ticket is closed
        const [current] = await pool.query('SELECT status FROM tickets WHERE id = ?', [ticketId]);
        if (current.length === 0) return res.status(404).json({ message: 'Ticket not found' });

        const isITManager = req.user && (req.user.role === 'IT Manager' || req.user.role === 'Admin' || req.user.role === 'admin');
        if (current[0].status === 'Closed' && !isITManager) {
            return res.status(403).json({ message: 'Cannot add comments to a closed ticket.' });
        }

        await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
            ticketId, 'Comment', req.user ? req.user.username : 'User', detail
        ]);

        res.json({ message: 'Comment added' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};
// Upload Attachment
exports.uploadAttachment = async (req, res) => {
    try {
        const ticketId = req.params.id;

        if (!req.file) {
            return res.status(400).json({ message: 'No file uploaded' });
        }

        const { filename, mimetype, size, path: filePath } = req.file;

        await pool.query('INSERT INTO ticket_attachments (ticket_id, file_name, file_type, file_size, file_path, uploaded_at) VALUES (?, ?, ?, ?, ?, NOW())', [
            ticketId, filename, mimetype, size, filePath
        ]);

        // Add to timeline
        await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
            ticketId, 'Attachment', req.user ? req.user.username : 'User', `Uploaded file: ${filename}`
        ]);

        res.json({ message: 'File uploaded', file: req.file });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Submit CSAT
exports.submitCSAT = async (req, res) => {
    try {
        const ticketId = req.params.id;
        const { score, comment } = req.body;

        await pool.query('UPDATE tickets SET csat_score = ?, csat_comment = ? WHERE id = ?', [score, comment, ticketId]);

        // Add to timeline
        await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
            ticketId, 'CSAT Submitted', req.user ? req.user.username : 'User', `Score: ${score}/5, Comment: ${comment || '-'}`
        ]);

        res.json({ message: 'CSAT submitted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

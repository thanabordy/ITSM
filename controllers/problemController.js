const pool = require('../config/db');

// Get all Problems (with related tickets)
exports.getAll = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM problems ORDER BY created_at DESC');

        // Get related tickets for each problem
        const mapped = await Promise.all(rows.map(async (r) => {
            const [ticketRows] = await pool.query('SELECT ticket_id FROM problem_related_tickets WHERE problem_id = ?', [r.id]);
            return {
                id: r.id,
                title: r.title,
                description: r.description || '',
                rootCause: r.root_cause || '',
                status: r.status,
                workaround: r.workaround || '',
                relatedTickets: ticketRows.map(t => t.ticket_id),
                createdAt: r.created_at ? (typeof r.created_at === 'string' ? r.created_at : r.created_at.toISOString().split('T')[0]) : null,
                updatedAt: r.updated_at
            };
        }));
        res.json(mapped);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get single Problem
exports.getById = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM problems WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Not found' });
        const r = rows[0];
        const [ticketRows] = await pool.query('SELECT ticket_id FROM problem_related_tickets WHERE problem_id = ?', [r.id]);
        res.json({
            id: r.id,
            title: r.title,
            description: r.description || '',
            rootCause: r.root_cause || '',
            status: r.status,
            workaround: r.workaround || '',
            relatedTickets: ticketRows.map(t => t.ticket_id),
            createdAt: r.created_at
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Create Problem
exports.create = async (req, res) => {
    try {
        const { title, description, rootCause, status, workaround, relatedTickets } = req.body;

        // Auto-generate ID
        const [countRows] = await pool.query('SELECT COUNT(*) as cnt FROM problems');
        const id = `PB${String(countRows[0].cnt + 1).padStart(3, '0')}`;
        const createdAt = new Date().toISOString().split('T')[0];

        await pool.query(
            'INSERT INTO problems (id, title, description, root_cause, status, workaround, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [id, title, description || null, rootCause || null, status || 'Investigating', workaround || null, createdAt]
        );

        // Insert related tickets
        if (relatedTickets && relatedTickets.length > 0) {
            const validTickets = relatedTickets.filter(t => t.trim());
            for (const ticketId of validTickets) {
                await pool.query(
                    'INSERT IGNORE INTO problem_related_tickets (problem_id, ticket_id) VALUES (?, ?)',
                    [id, ticketId.trim()]
                );
            }
        }

        res.status(201).json({
            id, title, description: description || '', rootCause: rootCause || '',
            status: status || 'Investigating', workaround: workaround || '',
            relatedTickets: relatedTickets || [], createdAt
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update Problem
exports.update = async (req, res) => {
    try {
        const { title, description, rootCause, status, workaround, relatedTickets } = req.body;

        await pool.query(
            'UPDATE problems SET title = ?, description = ?, root_cause = ?, status = ?, workaround = ? WHERE id = ?',
            [title, description || null, rootCause || null, status, workaround || null, req.params.id]
        );

        // Update related tickets: clear and re-insert
        await pool.query('DELETE FROM problem_related_tickets WHERE problem_id = ?', [req.params.id]);
        if (relatedTickets && relatedTickets.length > 0) {
            const validTickets = relatedTickets.filter(t => t.trim());
            for (const ticketId of validTickets) {
                await pool.query(
                    'INSERT IGNORE INTO problem_related_tickets (problem_id, ticket_id) VALUES (?, ?)',
                    [req.params.id, ticketId.trim()]
                );
            }
        }

        res.json({ message: 'Updated', id: req.params.id });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Delete Problem
exports.delete = async (req, res) => {
    try {
        // Related tickets cascade delete via FK
        await pool.query('DELETE FROM problems WHERE id = ?', [req.params.id]);
        res.json({ message: 'Deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

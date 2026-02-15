const pool = require('../config/db');

// Get all Change Requests
exports.getAll = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM change_requests ORDER BY created_at DESC');
        // Map DB column names to frontend-expected camelCase
        const mapped = rows.map(r => ({
            id: r.id,
            title: r.title,
            description: r.description || '',
            type: r.type,
            risk: r.risk,
            status: r.status,
            requestedBy: r.requested_by,
            scheduledDate: r.scheduled_date ? r.scheduled_date.toISOString().split('T')[0] : null,
            impact: r.impact || '',
            rollbackPlan: r.rollback_plan || '',
            createdAt: r.created_at,
            updatedAt: r.updated_at
        }));
        res.json(mapped);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get single Change Request
exports.getById = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM change_requests WHERE id = ?', [req.params.id]);
        if (rows.length === 0) return res.status(404).json({ message: 'Not found' });
        const r = rows[0];
        res.json({
            id: r.id,
            title: r.title,
            description: r.description || '',
            type: r.type,
            risk: r.risk,
            status: r.status,
            requestedBy: r.requested_by,
            scheduledDate: r.scheduled_date ? r.scheduled_date.toISOString().split('T')[0] : null,
            impact: r.impact || '',
            rollbackPlan: r.rollback_plan || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Create Change Request
exports.create = async (req, res) => {
    try {
        const { title, description, type, risk, status, requestedBy, scheduledDate, impact, rollbackPlan } = req.body;

        // Auto-generate ID
        const [countRows] = await pool.query('SELECT COUNT(*) as cnt FROM change_requests');
        const id = `CR${String(countRows[0].cnt + 1).padStart(3, '0')}`;

        await pool.query(
            'INSERT INTO change_requests (id, title, description, type, risk, status, requested_by, scheduled_date, impact, rollback_plan) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [id, title, description || null, type, risk, status || 'Pending', requestedBy || null, scheduledDate || null, impact || null, rollbackPlan || null]
        );

        res.status(201).json({
            id, title, description: description || '', type, risk, status: status || 'Pending',
            requestedBy: requestedBy || null, scheduledDate: scheduledDate || null,
            impact: impact || '', rollbackPlan: rollbackPlan || ''
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update Change Request
exports.update = async (req, res) => {
    try {
        const { title, description, type, risk, status, requestedBy, scheduledDate, impact, rollbackPlan } = req.body;

        await pool.query(
            'UPDATE change_requests SET title = ?, description = ?, type = ?, risk = ?, status = ?, requested_by = ?, scheduled_date = ?, impact = ?, rollback_plan = ? WHERE id = ?',
            [title, description || null, type, risk, status, requestedBy || null, scheduledDate || null, impact || null, rollbackPlan || null, req.params.id]
        );

        res.json({ message: 'Updated', id: req.params.id });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Delete Change Request
exports.delete = async (req, res) => {
    try {
        await pool.query('DELETE FROM change_requests WHERE id = ?', [req.params.id]);
        res.json({ message: 'Deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

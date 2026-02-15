const pool = require('../config/db');

// Get all SLA Policies
exports.getPolicies = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM sla_policies');
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get all SLA Policies (mapped to frontend format)
exports.getAllMapped = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM sla_policies');
        const mapped = rows.map(r => ({
            priority: r.priority,
            responseTime: r.response_time,
            resolveTime: r.resolve_time,
            escalateAfter: r.escalate_after,
            unit: r.unit
        }));
        res.json(mapped);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Create SLA Policy
exports.createPolicy = async (req, res) => {
    try {
        const { priority, responseTime, resolveTime, escalateAfter, unit } = req.body;

        await pool.query(
            'INSERT INTO sla_policies (priority, response_time, resolve_time, escalate_after, unit) VALUES (?, ?, ?, ?, ?)',
            [priority, responseTime, resolveTime, escalateAfter, unit || 'hours']
        );

        res.status(201).json({ priority, responseTime, resolveTime, escalateAfter, unit: unit || 'hours' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update SLA Policy
exports.updatePolicy = async (req, res) => {
    try {
        const { priority } = req.params;
        const { responseTime, resolveTime, escalateAfter } = req.body;

        await pool.query('UPDATE sla_policies SET response_time = ?, resolve_time = ?, escalate_after = ? WHERE priority = ?', [
            responseTime, resolveTime, escalateAfter, priority
        ]);

        res.json({ message: 'SLA Policy updated' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Delete SLA Policy
exports.deletePolicy = async (req, res) => {
    try {
        await pool.query('DELETE FROM sla_policies WHERE priority = ?', [req.params.priority]);
        res.json({ message: 'Deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

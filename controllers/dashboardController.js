const pool = require('../config/db');

exports.getDashboardStats = async (req, res) => {
    try {
        // Parallel queries for stats
        const [ticketCounts] = await pool.query(`
            SELECT 
                COUNT(*) as total,
                SUM(CASE WHEN status = 'Open' THEN 1 ELSE 0 END) as open,
                SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress,
                SUM(CASE WHEN status = 'Resolved' THEN 1 ELSE 0 END) as resolved,
                SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) as closed
            FROM tickets
        `);

        const [priorityCounts] = await pool.query(`
            SELECT priority, COUNT(*) as count FROM tickets GROUP BY priority
        `);

        // SLA Breaches (Example: Response time missed)
        const [slaBreaches] = await pool.query(`
            SELECT COUNT(*) as count FROM tickets WHERE sla_response_met = 0 OR sla_resolve_met = 0
        `);

        // Recent Tickets
        const [recentTickets] = await pool.query(`
            SELECT id, title, status, priority, created_at FROM tickets ORDER BY created_at DESC LIMIT 5
        `);

        res.json({
            tickets: ticketCounts[0],
            byPriority: priorityCounts,
            slaBreaches: slaBreaches[0].count,
            recentTickets
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

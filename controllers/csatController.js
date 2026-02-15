const pool = require('../config/db');

// Submit CSAT
exports.submitCSAT = async (req, res) => {
    try {
        const { ticketId } = req.params;
        const { score, comment } = req.body;

        if (!score || score < 1 || score > 5) {
            return res.status(400).json({ message: 'Score must be between 1 and 5' });
        }

        // Update Ticket
        await pool.query('UPDATE tickets SET csat_score = ?, csat_comment = ? WHERE id = ?', [score, comment, ticketId]);

        // Insert into csat_responses (Optional, if we want history, but schema has unique key so maybe just one per ticket)
        // Schema has unique key on ticket_id, so insert or update
        await pool.query(`
            INSERT INTO csat_responses (ticket_id, score, comment, response_date) 
            VALUES (?, ?, ?, NOW()) 
            ON DUPLICATE KEY UPDATE score = VALUES(score), comment = VALUES(comment), response_date = NOW()
        `, [ticketId, score, comment]);

        // Add to timeline
        await pool.query('INSERT INTO ticket_timeline (ticket_id, action, user_name, detail, created_at) VALUES (?, ?, ?, ?, NOW())', [
            ticketId, 'CSAT Submitted', 'User', `Score: ${score}, Comment: ${comment}`
        ]);

        res.json({ message: 'Thank you for your feedback' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Get CSAT Stats (Admin)
exports.getCSATStats = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT AVG(score) as average_score, COUNT(*) as total_responses FROM csat_responses');
        res.json(rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

const pool = require('../config/db');

// Get My Notifications
exports.getMyNotifications = async (req, res) => {
    try {
        const email = req.user.email;
        const [rows] = await pool.query('SELECT * FROM notifications WHERE to_email = ? ORDER BY sent_at DESC', [email]);
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Mark as Read (Simulate by deleting or updating status if we had a read_at column, schema has status 'Sent')
// Usually we'd update status to 'Read'.
exports.markAsRead = async (req, res) => {
    try {
        const { id } = req.params;
        await pool.query('UPDATE notifications SET status = ? WHERE id = ?', ['Read', id]);
        res.json({ message: 'Marked as read' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

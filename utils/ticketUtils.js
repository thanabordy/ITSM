const pool = require('../config/db');

// Priority Matrix Logic
const calculatePriority = (urgency, impact) => {
    const matrix = {
        'High': { 'High': 'Urgent', 'Medium': 'High', 'Low': 'Medium' },
        'Medium': { 'High': 'High', 'Medium': 'Medium', 'Low': 'Low' },
        'Low': { 'High': 'Medium', 'Medium': 'Low', 'Low': 'Low' }
    };
    return matrix[urgency]?.[impact] || 'Medium';
};

// SLA Calculation Logic
const calculateSLA = async (priority) => {
    // Default values if policy not found
    let responseHours = 4;
    let resolveHours = 24;

    try {
        const [rows] = await pool.query('SELECT response_time, resolve_time FROM sla_policies WHERE priority = ?', [priority]);
        if (rows.length > 0) {
            responseHours = rows[0].response_time;
            resolveHours = rows[0].resolve_time;
        }
    } catch (error) {
        console.error('Error fetching SLA policy:', error);
    }

    const now = new Date();
    const responseDue = new Date(now.getTime() + responseHours * 60 * 60 * 1000);
    const resolveDue = new Date(now.getTime() + resolveHours * 60 * 60 * 1000);

    return { responseDue, resolveDue };
};

// Auto-Assignment Logic
const autoAssign = async (category) => {
    try {
        // Find users with skill matching category
        // Assuming 'role' is IT staff (not 'User')
        const query = `
            SELECT u.id, u.email, u.name 
            FROM users u
            JOIN user_skills us ON u.id = us.user_id
            WHERE us.skill = ? AND u.role != 'User'
        `;
        const [candidates] = await pool.query(query, [category]);

        if (candidates.length === 0) return null;

        // Random Round Robin (Simple Random for now)
        const randomIndex = Math.floor(Math.random() * candidates.length);
        return candidates[randomIndex];
    } catch (error) {
        console.error('Error in auto-assign:', error);
        return null;
    }
};

module.exports = { calculatePriority, calculateSLA, autoAssign };

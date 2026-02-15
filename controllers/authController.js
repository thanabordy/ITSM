const pool = require('../config/db');
const jwt = require('jsonwebtoken');
// const bcrypt = require('bcryptjs'); // Will use plain text for now as per schema comments, or update if user wants hashing

const generateToken = (id, role, username) => {
    return jwt.sign({ id, role, username }, process.env.JWT_SECRET, {
        expiresIn: '8h',
    });
};

exports.login = async (req, res) => {
    const { username, password } = req.body;

    try {
        // Try to find by email or id or code (flexible login)
        const [rows] = await pool.query('SELECT * FROM users WHERE email = ? OR id = ? OR code = ?', [username, username, username]);

        if (rows.length === 0) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        const user = rows[0];

        // Ensure password check is secure. For now, matching schema comment "password123"
        // In production, use bcrypt.compare(password, user.password)
        if (user.password !== password) {
            return res.status(401).json({ message: 'Invalid credentials' });
        }

        // Fetch permissions
        const [permRows] = await pool.query('SELECT permission FROM user_permissions WHERE user_id = ?', [user.id]);
        let permissions = permRows.map(r => r.permission);

        // Fallback for Admin: Always give 'all' permission if not explicitly set (or even if set, to be safe)
        if (user.role === 'Admin' && !permissions.includes('all')) {
            permissions.push('all');
        }

        res.json({
            id: user.id,
            name: user.name, // Use 'name' from DB
            email: user.email,
            role: user.role,
            avatar: (user.avatar && user.avatar.length > 2) ? user.avatar : (user.name ? user.name.substring(0, 2).toUpperCase() : '?'),
            level: user.level,
            supervisorId: user.supervisor_id,
            phone: user.phone,
            location: user.location,
            gender: user.gender,
            permissions: permissions, // Send permissions
            token: generateToken(user.id, user.role, user.username)
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getMe = async (req, res) => {
    // req.user is set by authMiddleware
    try {
        const [rows] = await pool.query('SELECT id, name, email, role, department, position, avatar, level, supervisor_id, phone, location, gender FROM users WHERE id = ?', [req.user.id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = rows[0];
        // Fetch permissions
        const [permRows] = await pool.query('SELECT permission FROM user_permissions WHERE user_id = ?', [user.id]);
        user.permissions = permRows.map(r => r.permission);

        if (user.role === 'Admin' && !user.permissions.includes('all')) {
            user.permissions.push('all');
        }

        res.json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.demoLogin = async (req, res) => {
    const { email } = req.body;

    try {
        const [rows] = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
        if (rows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = rows[0];

        // Fetch permissions
        const [permRows] = await pool.query('SELECT permission FROM user_permissions WHERE user_id = ?', [user.id]);
        let permissions = permRows.map(r => r.permission);

        // Fallback for Admin
        if (user.role === 'Admin' && !permissions.includes('all')) {
            permissions.push('all');
        }

        res.json({
            id: user.id,
            name: user.name,
            email: user.email,
            role: user.role,
            avatar: (user.avatar && user.avatar.length > 2) ? user.avatar : (user.name ? user.name.substring(0, 2).toUpperCase() : '?'),
            level: user.level,
            supervisorId: user.supervisor_id,
            phone: user.phone,
            location: user.location,
            gender: user.gender,
            permissions: permissions,
            token: generateToken(user.id, user.role, user.code)
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

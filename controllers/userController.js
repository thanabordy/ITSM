const pool = require('../config/db');

exports.getAllUsers = async (req, res) => {
    try {
        const { role, department } = req.query;
        // Modified query to include skills and permissions via left join and group_concat
        let query = `
            SELECT u.id, u.code, u.name, u.name_en, u.email, u.role, u.department, u.position, u.avatar, u.level, u.supervisor_id, u.phone, u.location, u.gender,
            GROUP_CONCAT(DISTINCT us.skill) as skills,
            GROUP_CONCAT(DISTINCT up.permission) as permissions
            FROM users u
            LEFT JOIN user_skills us ON u.id = us.user_id
            LEFT JOIN user_permissions up ON u.id = up.user_id
        `;

        let params = [];
        let conditions = [];

        if (role || department) {
            conditions.push('u.deleted_at IS NULL');
            if (role) {
                conditions.push('u.role = ?');
                params.push(role);
            }
            if (department) {
                conditions.push('u.department = ?');
                params.push(department);
            }
        } else {
            conditions.push('u.deleted_at IS NULL');
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ');
        }

        query += ' GROUP BY u.id';

        const [rows] = await pool.query(query, params);



        // Process rows to convert comma-separated strings to arrays
        const users = rows.map(u => ({
            id: u.id,
            code: u.code,
            name: u.name,
            nameEn: u.name_en,
            email: u.email,
            role: u.role,
            department: u.department,
            position: u.position,
            avatar: u.avatar,
            level: u.level,
            supervisorId: u.supervisor_id,
            phone: u.phone,
            location: u.location,
            gender: u.gender,
            skills: u.skills ? u.skills.split(',') : [],
            permissions: u.permissions ? u.permissions.split(',') : []
        }));

        res.json(users);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getUserById = async (req, res) => {
    try {
        const userId = req.params.id;

        // Parallel queries: User details, Skills, Permissions
        const [userRows] = await pool.query('SELECT * FROM users WHERE id = ? AND deleted_at IS NULL', [userId]);

        if (userRows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userRows[0];
        delete user.password; // Don't send password

        const [skillRows] = await pool.query('SELECT skill FROM user_skills WHERE user_id = ?', [userId]);
        const [permRows] = await pool.query('SELECT permission FROM user_permissions WHERE user_id = ?', [userId]);

        user.skills = skillRows.map(row => row.skill);
        user.permissions = permRows.map(row => row.permission);

        res.json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Create User
exports.createUser = async (req, res) => {
    try {
        const { id, code, name, nameEn, email, department, position, role, password, level, supervisorId, phone, location, gender } = req.body;


        // Basic validation
        if (!id || !code || !name || !email || !role) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        // Check if user exists
        const [existing] = await pool.query('SELECT id FROM users WHERE id = ? OR email = ? OR code = ?', [id, email, code]);
        if (existing.length > 0) {
            return res.status(400).json({ message: 'User already exists (ID, Email, or Code)' });
        }

        // Insert User
        const avatar = name ? name.substring(0, 2).toUpperCase() : '?';
        const query = `
            INSERT INTO users (id, code, name, name_en, email, department, position, role, avatar, password, level, supervisor_id, phone, location, gender, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        `;
        await pool.query(query, [id, code, name, nameEn, email, department, position, role, avatar, password || 'password123', level, supervisorId, phone, location, gender]);

        // Insert Skills
        if (req.body.skills && Array.isArray(req.body.skills) && req.body.skills.length > 0) {
            const skillValues = req.body.skills.map(skill => [id, skill]);
            await pool.query('INSERT INTO user_skills (user_id, skill) VALUES ?', [skillValues]);
        }

        // Insert Permissions
        if (req.body.permissions && Array.isArray(req.body.permissions) && req.body.permissions.length > 0) {
            const permValues = req.body.permissions.map(perm => [id, perm]);
            await pool.query('INSERT INTO user_permissions (user_id, permission) VALUES ?', [permValues]);
        }

        // Return full user object
        const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [id]);
        const user = rows[0];
        delete user.password;
        user.nameEn = user.name_en;
        user.skills = req.body.skills || [];
        user.permissions = req.body.permissions || [];
        user.supervisorId = user.supervisor_id;

        res.status(201).json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

// Update User
exports.updateUser = async (req, res) => {
    try {
        const userId = req.params.id;
        const { name, nameEn, email, department, position, role, skills, permissions } = req.body;


        // Update User Details
        const avatar = name ? name.substring(0, 2).toUpperCase() : '?';
        await pool.query('UPDATE users SET name = ?, name_en = ?, email = ?, department = ?, position = ?, role = ?, avatar = ?, level = ?, supervisor_id = ?, phone = ?, location = ?, gender = ?, updated_at = NOW() WHERE id = ?',
            [name, nameEn, email, department, position, role, avatar, req.body.level, req.body.supervisorId, req.body.phone, req.body.location, req.body.gender, userId]);

        // Update Skills (Delete all and re-insert)
        if (skills && Array.isArray(skills)) {
            await pool.query('DELETE FROM user_skills WHERE user_id = ?', [userId]);
            if (skills.length > 0) {
                const skillValues = skills.map(skill => [userId, skill]);
                await pool.query('INSERT INTO user_skills (user_id, skill) VALUES ?', [skillValues]);
            }
        }

        // Update Permissions (Delete all and re-insert)
        if (permissions && Array.isArray(permissions)) {
            await pool.query('DELETE FROM user_permissions WHERE user_id = ?', [userId]);
            if (permissions.length > 0) {
                const permValues = permissions.map(perm => [userId, perm]);
                await pool.query('INSERT INTO user_permissions (user_id, permission) VALUES ?', [permValues]);
            }
        }

        // Return updated user object
        const [rows] = await pool.query('SELECT * FROM users WHERE id = ?', [userId]);
        const user = rows[0];
        delete user.password;
        user.nameEn = user.name_en;

        const [skillRows] = await pool.query('SELECT skill FROM user_skills WHERE user_id = ?', [userId]);
        const [permRows] = await pool.query('SELECT permission FROM user_permissions WHERE user_id = ?', [userId]);

        user.skills = skillRows.map(row => row.skill);
        user.permissions = permRows.map(row => row.permission);
        user.supervisorId = user.supervisor_id;

        res.json(user);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteUser = async (req, res) => {
    try {
        const userId = req.params.id;
        await pool.query('UPDATE users SET deleted_at = NOW() WHERE id = ?', [userId]);
        res.json({ message: 'User deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

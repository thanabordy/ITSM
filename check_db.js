
const pool = require('./config/db');

async function checkData() {
    try {
        await pool.query('UPDATE users SET password = ? WHERE email = ?', ['password123', 'admin@demo.com']);
        console.log('Admin password reset to password123');

        process.exit(0);
    } catch (error) {
        console.error('Error checking database:', error);
        process.exit(1);
    }
}

checkData();

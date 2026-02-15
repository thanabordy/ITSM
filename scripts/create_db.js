const mysql = require('mysql2/promise');
require('dotenv').config({ path: '../.env' });

async function createDB() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || ''
        });

        const dbName = process.env.DB_NAME || 'ticket_system';
        console.log(`Creating database: ${dbName}...`);

        await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
        console.log(`Database ${dbName} created (or already exists).`);

        await connection.end();
    } catch (error) {
        console.error('Error creating database:', error);
        process.exit(1);
    }
}

createDB();

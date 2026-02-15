const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: '../.env' });

async function initDB() {
    try {
        const connection = await mysql.createConnection({
            host: process.env.DB_HOST || 'localhost',
            user: process.env.DB_USER || 'root',
            password: process.env.DB_PASSWORD || '',
            database: process.env.DB_NAME || 'ticket_system',
            multipleStatements: true
        });

        const sqlPath = path.join(__dirname, '../database/schema_with_demo_data.sql');
        const sql = fs.readFileSync(sqlPath, 'utf8').replace(/^\uFEFF/, '');

        console.log(`Running SQL from ${sqlPath}...`);
        await connection.query(sql);
        console.log('Database initialized successfully with schema and demo data.');

        await connection.end();
    } catch (error) {
        console.error('Error initializing database:', error);
        process.exit(1);
    }
}

initDB();

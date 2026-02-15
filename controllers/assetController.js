const pool = require('../config/db');

exports.getAllAssets = async (req, res) => {
    try {
        const { type, status, assigned_to } = req.query;
        let query = 'SELECT * FROM assets';
        let params = [];
        let conditions = [];

        if (type) {
            conditions.push('type = ?');
            params.push(type);
        }
        if (status) {
            conditions.push('status = ?');
            params.push(status);
        }
        if (assigned_to) {
            conditions.push('assigned_to = ?');
            params.push(assigned_to);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ') + ' AND deleted_at IS NULL';
        } else {
            query += ' WHERE deleted_at IS NULL';
        }

        query += ' ORDER BY id ASC';

        const [rows] = await pool.query(query, params);
        const assets = rows.map(a => ({
            id: a.id,
            name: a.name,
            type: a.type,
            brand: a.brand,
            model: a.model,
            serial: a.serial,
            location: a.location,
            status: a.status,
            assignedTo: a.assigned_to,
            createdAt: a.created_at,
            updatedAt: a.updated_at
        }));
        res.json(assets);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getAssetById = async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM assets WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Asset not found' });
        }
        const asset = rows[0];
        res.json({
            id: asset.id,
            name: asset.name,
            type: asset.type,
            brand: asset.brand,
            model: asset.model,
            serial: asset.serial,
            location: asset.location,
            status: asset.status,
            assignedTo: asset.assigned_to,
            createdAt: asset.created_at,
            updatedAt: asset.updated_at
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createAsset = async (req, res) => {
    try {
        const { id, name, type, brand, model, serial, location, specs, purchaseDate, warrantyEnd, status } = req.body;
        const assigned_to = req.body.assignedTo || req.body.assigned_to;

        if (!id || !name || !type) {
            return res.status(400).json({ message: 'Missing required fields' });
        }

        const query = `
            INSERT INTO assets (id, name, type, brand, model, serial, stats, location, status, specs, purchase_date, warranty_end, assigned_to, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, 'Active', ?, ?, ?, ?, ?, ?, NOW(), NOW())
        `;
        // Note: 'stats' column doesn't exist in schema provided (it was status), wait, schema says status.
        // Let's re-read schema.
        // Schema: status ENUM default Active.
        // Schema: specs, purchase_date, warranty_end exist.

        const q = `
            INSERT INTO assets (id, name, type, brand, model, serial, specs, location, status, purchase_date, warranty_end, assigned_to, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
        `;

        await pool.query(q, [
            id, name, type,
            brand || null, model || null, serial || null,
            specs || null, location || null, status || 'Active',
            purchaseDate || null, warrantyEnd || null, assigned_to || null
        ]);

        // Return the created object for frontend store
        res.status(201).json({
            id, name, type, brand, model, serial, specs, location, status: status || 'Active',
            purchaseDate, warrantyEnd, assignedTo: assigned_to,
            createdAt: new Date(), updatedAt: new Date()
        });
    } catch (error) {
        console.error(error);
        if (error.code === 'ER_DUP_ENTRY') {
            return res.status(400).json({ message: 'Asset ID or Serial must be unique' });
        }
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateAsset = async (req, res) => {
    try {
        const { name, type, brand, model, serial, specs, location, status, purchaseDate, warrantyEnd } = req.body;
        const assigned_to = req.body.assignedTo || req.body.assigned_to;
        const assetId = req.params.id;

        const query = `
            UPDATE assets 
            SET name = ?, type = ?, brand = ?, model = ?, serial = ?, specs = ?, location = ?, status = ?, purchase_date = ?, warranty_end = ?, assigned_to = ?, updated_at = NOW()
            WHERE id = ?
        `;
        await pool.query(query, [
            name, type, brand, model, serial,
            specs || null, location, status,
            purchaseDate || null, warrantyEnd || null,
            assigned_to || null, assetId
        ]);

        // Fetch the updated asset to return full valid data
        const [rows] = await pool.query('SELECT * FROM assets WHERE id = ?', [assetId]);
        const a = rows[0];

        res.json({
            id: a.id,
            name: a.name,
            type: a.type,
            brand: a.brand,
            model: a.model,
            serial: a.serial,
            specs: a.specs,
            location: a.location,
            status: a.status,
            purchaseDate: a.purchase_date, // Frontend expects camelCase
            warrantyEnd: a.warranty_end,
            assignedTo: a.assigned_to,
            createdAt: a.created_at,
            updatedAt: a.updated_at
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteAsset = async (req, res) => {
    try {
        await pool.query('UPDATE assets SET deleted_at = NOW() WHERE id = ?', [req.params.id]);
        res.json({ message: 'Asset deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

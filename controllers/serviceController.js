const pool = require('../config/db');

exports.getServiceCatalog = async (req, res) => {
    try {
        // Fetch categories and items
        const [categories] = await pool.query('SELECT * FROM service_categories ORDER BY id');
        const [items] = await pool.query('SELECT * FROM service_items ORDER BY category_id, id');

        // Map items to categories
        const catalog = categories.map(cat => {
            const catItems = items.filter(item => item.category_id === cat.id);
            return {
                ...cat,
                items: catItems
            };
        });

        res.json(catalog);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

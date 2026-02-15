const pool = require('../config/db');

exports.getAllArticles = async (req, res) => {
    try {
        const { search, category } = req.query;
        let query = 'SELECT * FROM kb_articles';
        let params = [];
        let conditions = [];

        if (search) {
            conditions.push('(title LIKE ? OR content LIKE ?)');
            params.push(`%${search}%`);
            params.push(`%${search}%`);
        }
        if (category) {
            conditions.push('category = ?');
            params.push(category);
        }

        if (conditions.length > 0) {
            query += ' WHERE ' + conditions.join(' AND ') + ' AND deleted_at IS NULL';
        } else {
            query += ' WHERE deleted_at IS NULL';
        }

        query += ' ORDER BY created_at DESC';

        const [rows] = await pool.query(query, params);

        const articles = rows.map(a => ({
            id: a.id,
            title: a.title,
            category: a.category,
            content: a.content,
            isPublic: !!a.is_public,
            views: a.views,
            tags: a.tags ? JSON.parse(a.tags) : [], // Assuming tags are JSON or handled
            createdAt: a.created_at,
            updatedAt: a.updated_at
        }));

        res.json(articles);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.createArticle = async (req, res) => {
    try {
        const { title, category, content } = req.body;
        const is_public = (req.body.isPublic !== undefined) ? req.body.isPublic : req.body.is_public;
        // Generate ID: KB-XXX
        const [maxIdResult] = await pool.query('SELECT id FROM kb_articles ORDER BY id DESC LIMIT 1');
        let nextSeq = 1;
        if (maxIdResult.length > 0) {
            const lastId = maxIdResult[0].id; // KB010
            nextSeq = parseInt(lastId.substring(2)) + 1;
        }
        const id = `KB${String(nextSeq).padStart(3, '0')}`;

        await pool.query('INSERT INTO kb_articles (id, title, category, content, is_public, created_at) VALUES (?, ?, ?, ?, ?, NOW())', [
            id, title, category, content, (is_public === undefined || is_public) ? 1 : 0
        ]);

        res.status(201).json({ id, message: 'Article created' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.getArticleById = async (req, res) => {
    try {
        // Increment view count (maybe check if exists first to avoid update on deleted?) 
        // Better: select first, if not deleted, then update view

        const [rows] = await pool.query('SELECT * FROM kb_articles WHERE id = ? AND deleted_at IS NULL', [req.params.id]);
        if (rows.length === 0) {
            return res.status(404).json({ message: 'Article not found' });
        }

        await pool.query('UPDATE kb_articles SET views = views + 1 WHERE id = ?', [req.params.id]);

        const article = rows[0];

        // Fetch images
        const [images] = await pool.query('SELECT * FROM kb_attachments WHERE kb_id = ?', [req.params.id]);

        res.json({
            id: article.id,
            title: article.title,
            category: article.category,
            content: article.content,
            isPublic: !!article.is_public,
            views: article.views,
            tags: article.tags ? JSON.parse(article.tags) : [],
            createdAt: article.created_at,
            updatedAt: article.updated_at,
            images: images.map(img => ({
                id: img.id,
                name: img.file_name,
                path: img.file_path,
                type: img.file_type
            }))
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.updateArticle = async (req, res) => {
    try {
        const { title, category, content } = req.body;
        const is_public = (req.body.isPublic !== undefined) ? req.body.isPublic : req.body.is_public;
        const articleId = req.params.id;

        await pool.query('UPDATE kb_articles SET title = ?, category = ?, content = ?, is_public = ?, updated_at = NOW() WHERE id = ?', [
            title, category, content, (is_public === undefined || is_public) ? 1 : 0, articleId
        ]);

        res.json({ message: 'Article updated' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

exports.deleteArticle = async (req, res) => {
    try {
        await pool.query('UPDATE kb_articles SET deleted_at = NOW() WHERE id = ?', [req.params.id]);
        res.json({ message: 'Article deleted' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Server error' });
    }
};

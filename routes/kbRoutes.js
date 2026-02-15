const express = require('express');
const router = express.Router();
const kbController = require('../controllers/kbController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, kbController.getAllArticles);
router.post('/', protect, kbController.createArticle);
router.get('/:id', protect, kbController.getArticleById);
router.put('/:id', protect, kbController.updateArticle);
router.delete('/:id', protect, kbController.deleteArticle);

module.exports = router;

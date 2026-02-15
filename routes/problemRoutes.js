const express = require('express');
const router = express.Router();
const problemController = require('../controllers/problemController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, problemController.getAll);
router.post('/', protect, admin, problemController.create);
router.get('/:id', protect, problemController.getById);
router.put('/:id', protect, admin, problemController.update);
router.delete('/:id', protect, admin, problemController.delete);

module.exports = router;

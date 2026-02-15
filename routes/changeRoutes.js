const express = require('express');
const router = express.Router();
const changeController = require('../controllers/changeController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, changeController.getAll);
router.post('/', protect, admin, changeController.create);
router.get('/:id', protect, changeController.getById);
router.put('/:id', protect, admin, changeController.update);
router.delete('/:id', protect, admin, changeController.delete);

module.exports = router;

const express = require('express');
const router = express.Router();
const slaController = require('../controllers/slaController');
const { protect, admin } = require('../middleware/authMiddleware');

router.get('/', protect, slaController.getAllMapped);
router.post('/', protect, admin, slaController.createPolicy);
router.put('/:priority', protect, admin, slaController.updatePolicy);
router.delete('/:priority', protect, admin, slaController.deletePolicy);

module.exports = router;

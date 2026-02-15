const express = require('express');
const router = express.Router();
const csatController = require('../controllers/csatController');
const { protect, admin } = require('../middleware/authMiddleware');

router.post('/:ticketId', protect, csatController.submitCSAT);
router.get('/stats', protect, admin, csatController.getCSATStats);

module.exports = router;

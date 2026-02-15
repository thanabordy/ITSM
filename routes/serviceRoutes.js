const express = require('express');
const router = express.Router();
const serviceController = require('../controllers/serviceController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, serviceController.getServiceCatalog);

module.exports = router;

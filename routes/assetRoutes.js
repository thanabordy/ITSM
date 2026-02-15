const express = require('express');
const router = express.Router();
const assetController = require('../controllers/assetController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, assetController.getAllAssets);
router.post('/', protect, assetController.createAsset);
router.get('/:id', protect, assetController.getAssetById);
router.put('/:id', protect, assetController.updateAsset);
router.delete('/:id', protect, assetController.deleteAsset);

module.exports = router;

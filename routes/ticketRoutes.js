const express = require('express');
const router = express.Router();
const ticketController = require('../controllers/ticketController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, ticketController.getAllTickets);
router.post('/', protect, ticketController.createTicket);
router.get('/:id', protect, ticketController.getTicketById);
router.put('/:id', protect, ticketController.updateTicket);
router.delete('/:id', protect, ticketController.deleteTicket);
router.post('/:id/assign', protect, ticketController.assignTicket);
router.post('/:id/comment', protect, ticketController.addComment);
const upload = require('../middleware/uploadMiddleware');
router.post('/:id/attachments', protect, upload.single('file'), ticketController.uploadAttachment);
router.post('/:id/csat', protect, ticketController.submitCSAT);

module.exports = router;

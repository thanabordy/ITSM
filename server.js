const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', require('./routes/authRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/tickets', require('./routes/ticketRoutes'));
app.use('/api/assets', require('./routes/assetRoutes'));
app.use('/api/service-catalog', require('./routes/serviceRoutes'));
app.use('/api/kb', require('./routes/kbRoutes'));
app.use('/api/dashboard', require('./routes/dashboardRoutes'));
app.use('/api/sla', require('./routes/slaRoutes'));
app.use('/api/changes', require('./routes/changeRoutes'));
app.use('/api/problems', require('./routes/problemRoutes'));
app.use('/api/csat', require('./routes/csatRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));

// Health Check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', message: 'Server is running' });
});

const { errorHandler } = require('./middleware/errorMiddleware');

// Error Handling Middleware
app.use(errorHandler);

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

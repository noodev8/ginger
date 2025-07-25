// Example of how to integrate the QR code and points routes into your existing server

const express = require('express');
const app = express();

// Your existing middleware
app.use(express.json());

// Import the new route files
const qrCodeRoutes = require('./qr_code_routes');
const pointsRoutes = require('./points_routes');

// Your existing auth routes
// app.use('/auth', authRoutes);

// Add the new QR code and points routes
app.use('/qr-codes', qrCodeRoutes);
app.use('/points', pointsRoutes);

// Your existing routes...

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

// Environment variables you'll need to set:
// DB_HOST=your_database_host
// DB_PORT=5432
// DB_NAME=your_database_name
// DB_USER=your_database_user
// DB_PASSWORD=your_database_password

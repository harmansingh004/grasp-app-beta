const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const rateLimit = require("express-rate-limit");

const courseRoutes = require("./routes/courseRoutes");
const notesRoutes = require('./routes/notesRoutes');
const authRoutes = require('./routes/auth_routes');
const aiRoutes = require("./routes/aiRoutes");

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// MIDDLEWARE
app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('uploads'));

const generateLimiter = rateLimit({
  windowMs: 1 * 60 * 1000,
  max: 5,
  message: {
    success: false,
    error: "Too many requests, please try again later",
  },
});

// ROUTES
app.use('/api/auth', authRoutes);
app.use('/', notesRoutes);
app.use("/ai", aiRoutes);
app.use("/courses/generate", generateLimiter);
app.use("/courses", courseRoutes);

// GLOBAL ERROR HANDLER
app.use((err, req, res, next) => {
  console.error(err.stack);

  res.status(500).json({
    success: false,
    error: "Internal Server Error",
  });
});

// DB CONNECTION
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error('MongoDB Error:', err.message));

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
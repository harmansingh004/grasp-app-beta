const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");
const auth = require("../middleware/auth");

// PUBLIC ROUTES
router.post("/register", authController.register);
router.post("/login", authController.login);

// PROTECTED ROUTE
router.post("/logout", auth, authController.logout);

module.exports = router;
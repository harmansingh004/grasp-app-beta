const express = require("express");
const router = express.Router();
const multer = require("multer");
const auth = require("../middleware/auth");
const noteController = require("../controllers/noteController");

// MULTER CONFIG
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "uploads/"),
  filename: (req, file, cb) =>
    cb(null, Date.now() + "-" + file.originalname),
});

const upload = multer({
  storage,
  limits: { fileSize: 2 * 1024 * 1024 }, // 2MB
});

// ROUTES
router.post("/notes", auth, upload.array("files"), noteController.uploadNote);
router.get("/notes", auth, noteController.getNotes);
router.delete("/notes/:id", auth, noteController.deleteNote);

module.exports = router;
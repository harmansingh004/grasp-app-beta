const express = require("express");
const router = express.Router();
const auth = require("../middleware/auth");
const courseController = require("../controllers/courseController");

router.post("/generate", auth, courseController.generateCourse);
router.get("/", auth, courseController.getCourses);
router.get("/:id", auth, courseController.getCourseChapters);

module.exports = router;
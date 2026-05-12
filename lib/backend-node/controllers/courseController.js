const Course = require("../models/Course");
const { generateCourseService } = require("../services/aiService");

// GENERATE COURSE
exports.generateCourse = async (req, res) => {
  try {
    const { topic } = req.body;

    if (!topic || topic.trim() === "") {
      return res.status(400).json({
        success: false,
        error: "Topic is required",
      });
    }

    const courseData = await generateCourseService(topic);

    const course = await Course.create({
      ...courseData,
      userId: req.userId,
    });

    return res.json({
      success: true,
      data: course,
    });

  } catch (e) {
    console.error("Generate Error:", e.message);

    return res.status(500).json({
      success: false,
      error: "Failed to generate course",
    });
  }
};

// GET ALL COURSES
exports.getCourses = async (req, res) => {
  try {
    const courses = await Course.find({ userId: req.userId })
      .sort({ createdAt: -1 });

    return res.json({
      success: true,
      data: courses,
    });

  } catch (e) {
    return res.status(500).json({
      success: false,
      error: "Failed to fetch courses",
    });
  }
};

// GET CHAPTERS
exports.getCourseChapters = async (req, res) => {
  try {
    const course = await Course.findOne({
      _id: req.params.id,
      userId: req.userId,
    });

    if (!course) {
      return res.status(404).json({
        success: false,
        error: "Course not found",
      });
    }

    return res.json({
      success: true,
      data: course.chapters,
    });

  } catch (error) {
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
};
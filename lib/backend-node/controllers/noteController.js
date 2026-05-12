const noteService = require("../services/noteService");

// UPLOAD NOTE
exports.uploadNote = async (req, res) => {
  try {
    const result = await noteService.uploadNote(req);

    return res.json({
      success: true,
      data: result,
    });
  } catch (e) {
    return res.status(400).json({
      success: false,
      error: e.message,
    });
  }
};

// GET NOTES
exports.getNotes = async (req, res) => {
  try {
    const notes = await noteService.getNotes(req.userId);

    return res.json({
      success: true,
      data: notes,
    });
  } catch (e) {
    return res.status(500).json({
      success: false,
      error: "Failed to fetch notes",
    });
  }
};

// DELETE NOTE
exports.deleteNote = async (req, res) => {
  try {
    await noteService.deleteNote(req.params.id, req.userId);

    return res.json({
      success: true,
      message: "Note deleted",
    });
  } catch (e) {
    return res.status(400).json({
      success: false,
      error: e.message,
    });
  }
};
const Note = require("../models/notes");
const fs = require("fs");
const path = require("path");

// UPLOAD NOTE
exports.uploadNote = async (req) => {
  const { title, description } = req.body;

  if (!req.files || req.files.length === 0) {
    throw new Error("No files uploaded");
  }

  const fileNames = req.files.map((file) => file.filename);

  const note = await Note.create({
    title,
    description,
    files: fileNames,
    file_type: req.files[0].mimetype,
    userId: req.userId,
  });

  return note;
};

// GET NOTES
exports.getNotes = async (userId) => {
  const notes = await Note.find({ userId }).sort({ createdAt: -1 });

  const BASE_URL = process.env.BASE_URL;

  return notes.map((note) => ({
    id: note._id,
    title: note.title,
    description: note.description,
    file_urls: note.files.map(
      (f) => `${BASE_URL}/uploads/${f}`
    ),
  }));
};

// DELETE NOTE
exports.deleteNote = async (noteId, userId) => {
  const note = await Note.findOne({ _id: noteId, userId });

  if (!note) {
    throw new Error("Note not found");
  }

  if (note.files?.length) {
    for (let name of note.files) {
      const filePath = path.join(__dirname, "..", "uploads", name);

      if (fs.existsSync(filePath)) {
        await fs.promises.unlink(filePath);
      }
    }
  }

  await Note.findByIdAndDelete(noteId);
};
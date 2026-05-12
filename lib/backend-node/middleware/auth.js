const jwt = require("jsonwebtoken");

module.exports = (req, res, next) => {
  try {
    const header = req.headers.authorization;
    // Check header
    if (!header || !header.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        error: "Unauthorized: No token provided",
      });
    }

    const token = header.split(" ")[1];

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Attach user
    req.userId = decoded.userId;

    next();

  } catch (err) {
    console.error("Auth Error:", err.message);

    return res.status(401).json({
      success: false,
      error: "Unauthorized: Invalid or expired token",
    });
  }
};
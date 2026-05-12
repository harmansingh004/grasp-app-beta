const { ChatGroq } = require("@langchain/groq");
require("dotenv").config();

const llm = new ChatGroq({
  apiKey: process.env.GROQ_API_KEY,
  model: "llama-3.3-70b-versatile",
  temperature: 0.3,
  maxTokens: 1000,
});

exports.askAI = async (req, res) => {
  try {
    const { question, courseContent } = req.body;

    if (!question || !courseContent) {
      return res.status(400).json({ error: "Missing data" });
    }

    const prompt = `
You are a helpful AI tutor.

Answer the student's question clearly and simply.

COURSE CONTENT:
${courseContent}

QUESTION:
${question}

RULES:
- Answer in simple language
- Be concise but helpful
- Use examples if needed
`;

    const response = await llm.invoke(prompt);

    res.json({
      success: true,
      data: response.content,
    });

  } catch (e) {
    console.error("AI Error:", e.message);
    res.status(500).json({ error: "AI failed" });
  }
};
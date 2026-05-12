const { ChatGroq } = require("@langchain/groq");
const { PromptTemplate } = require("@langchain/core/prompts");
const { google } = require("googleapis");
require("dotenv").config();

// ======================
// LLM SETUP
// ======================
const llm = new ChatGroq({
  apiKey: process.env.GROQ_API_KEY,
  model: "llama-3.3-70b-versatile",
  temperature: 0.3,
  maxTokens: 5000,
});

// ======================
// YOUTUBE API
// ======================
const youtube = google.youtube({
  version: "v3",
  auth: process.env.YOUTUBE_API_KEY,
});

// ======================
// SIMPLE CACHE
// ======================
const cache = new Map();

// ======================
// STRONG JSON PARSER
// ======================
function parseJsonOutput(text) {
  try {
    let clean = text
      .replace(/```json/g, "")
      .replace(/```/g, "")
      .trim();

    return JSON.parse(clean);

  } catch (e) {
    console.log("Primary JSON parse failed");

    try {
      let start = text.indexOf("{");
      let end = text.lastIndexOf("}");

      if (start !== -1 && end !== -1 && end > start) {
        let jsonString = text.substring(start, end + 1);
        return JSON.parse(jsonString);
      }

    } catch (err) {
      console.log("Fallback parse failed");
    }

    console.error("=== AI RAW OUTPUT START ===");
    console.error(text.substring(0, 1000));
    console.error("=== AI RAW OUTPUT END ===");

    throw new Error("AI returned invalid JSON");
  }
}

// ======================
// YOUTUBE SEARCH
// ======================
async function searchYoutube(query) {
  try {
    const response = await youtube.search.list({
      part: "snippet",
      maxResults: 1,
      q: query + " tutorial",
      type: "video",
    });

    if (response.data.items?.length > 0) {
      return response.data.items[0].id.videoId;
    }
  } catch (error) {
    console.error(`YouTube Error for '${query}':`, error.message);
  }

  return null;
}

// ======================
// MAIN SERVICE
// ======================
async function generateCourseService(topic) {
  console.log(`\nGenerating course for: ${topic}`);

  if (!topic || topic.trim().length < 3) {
    throw new Error("Invalid topic");
  }

  if (topic.length > 100) {
    throw new Error("Topic too long");
  }

  const cleanTopic = topic.trim();
  const cacheKey = cleanTopic.toLowerCase();

  // ======================
  // CACHE CHECK
  // ======================
  if (cache.has(cacheKey)) {
    console.log("Returning cached course");
    return cache.get(cacheKey);
  }

  // ======================
  // IMPROVED PROMPT
  // ======================
  const template = `
  You are an expert university professor and an engaging teacher.

  Create a highly detailed 5-chapter course on: "{topic}"

  ========================
  STRICT OUTPUT RULES:
  ========================
  - Output ONLY valid JSON
  - No markdown code blocks (no \`\`\`)
  - No explanation outside JSON
  - No text before or after JSON
  - Ensure valid JSON syntax (no trailing commas)

  ========================
  CONTENT RULES:
  ========================
  - Each chapter must be detailed (600–1000 words)
  - Use clear structure with sections:
    - ## Introduction
    - ## Key Concepts
    - ## Examples
    - ## Summary
  - Use bullet points where helpful
  - Explain step-by-step like teaching a beginner
  - Include at least one real-world example per chapter
  - Keep language simple and easy to understand

  ========================
  FORMAT EXACTLY LIKE THIS:
  ========================

  {
    "topic": "Topic Name",
    "chapters": [
      {
        "chapter_number": 1,
        "title": "Chapter Title",
        "youtube_search_query": "Search query",
        "content_markdown": "## Introduction\\nDetailed explanation...\\n\\n## Key Concepts\\n- Point 1\\n- Point 2\\n\\n## Examples\\nExample explanation...\\n\\n## Summary\\nFinal thoughts...",
        "cheat_sheet_points": [
          "Important point 1",
          "Important point 2",
          "Important point 3",
          "Important point 4",
          "Important point 5"
        ],
        "quiz": [
          { "question": "Q1", "options": ["A", "B", "C", "D"], "correct_option_index": 0 },
          { "question": "Q2", "options": ["A", "B", "C", "D"], "correct_option_index": 1 },
          { "question": "Q3", "options": ["A", "B", "C", "D"], "correct_option_index": 2 },
          { "question": "Q4", "options": ["A", "B", "C", "D"], "correct_option_index": 3 },
          { "question": "Q5", "options": ["A", "B", "C", "D"], "correct_option_index": 0 }
        ]
      }
    ]
  }
  `;

  const finalPrompt = template.replace("{topic}", cleanTopic);

  let courseData = null;

  // ======================
  // AI CALL WITH RETRY
  // ======================
  for (let attempt = 1; attempt <= 2; attempt++) {
    try {
      console.log(`Attempt ${attempt}...`);

      const response = await llm.invoke(finalPrompt);

      console.log("RAW AI RESPONSE:", response.content.substring(0, 300));

      courseData = parseJsonOutput(response.content);

      if (!courseData.chapters || !Array.isArray(courseData.chapters)) {
        throw new Error("Invalid AI response structure");
      }

      console.log("AI JSON parsed successfully");
      break;

    } catch (e) {
      console.error(`Attempt ${attempt} failed:`, e.message);

      if (attempt === 2) {
        throw new Error("AI failed to generate valid course");
      }
    }
  }

  // ======================
  // FETCH YOUTUBE VIDEOS
  // ======================
  console.log("Fetching YouTube videos...");

  const videoPromises = courseData.chapters.map((ch) =>
    searchYoutube(ch.youtube_search_query || "")
  );

  const videoIds = await Promise.all(videoPromises);

  // ======================
  // FINAL CLEANUP
  // ======================
  courseData.chapters = courseData.chapters.map((ch, index) => {
    let points = ch.cheat_sheet_points || [];

    while (points.length < 5) {
      points.push("Review full content for details.");
    }

    points = points.slice(0, 5);

    return {
      ...ch,
      video_id: videoIds[index] || null,
      cheat_sheet_points: points,
      cheat_sheet_text: points.join("\n"),
      content_text: ch.content_markdown || "",
      quiz_data: ch.quiz || [],
    };
  });

  // ======================
  // CACHE STORE
  // ======================
  cache.set(cacheKey, courseData);

  return courseData;
}

module.exports = { generateCourseService };
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? 'Unknown Question',
      options: List<String>.from(json['options'] ?? []),
      correctIndex: json['correct_option_index'] ?? 0,
    );
  }
}

class Chapter {
  final String id;
  final String title;
  final String content;
  final String videoId;
  final String cheatSheet;
  final List<QuizQuestion> quiz;
  bool isCompleted;

  Chapter({
    required this.id,
    required this.title,
    required this.content,
    required this.videoId,
    required this.cheatSheet,
    required this.quiz,
    this.isCompleted = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    var quizList = json['quiz_data'] ?? [];

    return Chapter(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',

      content: json['content_text'] ?? '',

      videoId: json['video_id'] ?? '',
      cheatSheet: json['cheat_sheet_text'] ?? '',
      isCompleted: json['is_completed'] ?? false,

      quiz: (quizList as List).map((q) => QuizQuestion.fromJson(q)).toList(),
    );
  }
}

class Course {
  final String id;
  final String topic;
  final List<Chapter> chapters;

  Course({
    required this.id,
    required this.topic,
    required this.chapters
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    var list = json['chapters'] as List? ?? [];
    List<Chapter> chaptersList = list.map((i) => Chapter.fromJson(i)).toList();

    return Course(
      id: json['id']?.toString() ?? '',
      topic: json['topic'] ?? 'Unknown Topic',
      chapters: chaptersList,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/course_model.dart';
import '../widgets/ask_ai_dialog.dart';
import 'ai_chat_screen.dart';
import 'chapter_screen.dart';
import 'quiz_screen.dart';
import '../services/pdf_service.dart';
import '../theme_provider.dart';

class CourseScreen extends ConsumerStatefulWidget {
  final Course course;

  const CourseScreen({super.key, required this.course});

  @override
  ConsumerState<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends ConsumerState<CourseScreen> {

  String buildCourseContext() {
    return widget.course.chapters
        .map((ch) => "${ch.title}\n${ch.content}")
        .join("\n\n");
  }

  double get _progress {
    if (widget.course.chapters.isEmpty) return 0.0;
    int completed = widget.course.chapters.where((c) => c.isCompleted).length;
    return completed / widget.course.chapters.length;
  }

  Future<void> _toggleChapter(int index, bool? value) async {
    if (value == null) return;
    final chapter = widget.course.chapters[index];

    setState(() {
      chapter.isCompleted = value;
    });

    try {
      final url = Uri.parse('http://10.23.145.89:3000/chapters/${chapter.id}/toggle');

      await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"is_completed": value}),
      );
    } catch (e) {
      setState(() {
        chapter.isCompleted = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.topic),
        actions: [
          IconButton(
            icon: const Icon(Icons.smart_toy),
            onPressed: () {
              final contextText = buildCourseContext();

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AIChatScreen(
                    courseContent: contextText,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Generating Cheat Sheet..."),
              duration: Duration(seconds: 1),
            ),
          );

          try {
            await PdfService.saveAndOpenPdf(widget.course);
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Downloaded! Check the Saved tab."),
                  backgroundColor: Colors.teal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
              );
            }
          }
        },
        icon: const Icon(Icons.download),
        label: const Text("Cheat Sheet"),
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: isDark ? Colors.grey[900] : Colors.teal.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Course Progress",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87
                        )
                    ),
                    Text(
                      "${(_progress * 100).toInt()}%",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: widget.course.chapters.isEmpty
                ? const Center(child: Text("No chapters found."))
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: widget.course.chapters.length,
              itemBuilder: (context, index) {
                final chapter = widget.course.chapters[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: chapter.isCompleted,
                        onChanged: (val) => _toggleChapter(index, val),
                        activeColor: Colors.teal,
                      ),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: chapter.isCompleted ? TextDecoration.lineThrough : null,
                          color: chapter.isCompleted ? Colors.grey : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          const Text("Tap to watch lesson"),
                          const SizedBox(height: 8),
                          if (chapter.quiz.isNotEmpty)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizScreen(questions: chapter.quiz),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.quiz, size: 18),
                              label: const Text("Take Quiz"),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.play_circle_fill, color: Colors.teal, size: 30),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChapterScreen(chapter: chapter),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
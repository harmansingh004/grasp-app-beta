import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/course_model.dart';
import '../services/pdf_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.getCourseHistory(context);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.getCourseHistory(context);
    });
  }

  Future<void> _downloadCheatSheet(Course course) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chapters = await ApiService.getCourseChapters(course.id, context);

      final fullCourse = Course(
        id: course.id,
        topic: course.topic,
        chapters: chapters,
      );

      await PdfService.saveAndOpenPdf(fullCourse);

      if (mounted) Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Download ready"),
          backgroundColor: Colors.teal,
        ),
      );
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Course>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snap.hasError) {
              return Center(child: Text("Error: ${snap.error}"));
            }

            final courses = snap.data ?? [];

            if (courses.isEmpty) {
              return const Center(
                child: Text("No courses yet.\nGenerate a course first."),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.picture_as_pdf, color: Colors.white),
                    ),
                    title: Text(
                      c.topic,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Tap to view"),
                    trailing: const Icon(Icons.download),
                    onTap: () => _downloadCheatSheet(c),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
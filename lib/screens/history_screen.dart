import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/course_model.dart';
import '../services/auth_service.dart';
import 'course_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Course>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = ApiService.getCourseHistory(context);
  }

  Future<void> refreshHistory() async {
    setState(() {
      _historyFuture = ApiService.getCourseHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Courses"),
      ),
      body: RefreshIndicator(
        onRefresh: refreshHistory,
        child: FutureBuilder<List<Course>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No courses found. Go generate one!"));
            }

            final courses = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.book, color: Colors.white),
                    ),
                    title: Text(
                      course.topic,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Tap to continue learning"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => navigateToCourse(context, course),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void navigateToCourse(BuildContext context, Course course) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chapters = await ApiService.getCourseChapters(course.id, context);

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseScreen(
              course: Course(
                id: course.id,
                topic: course.topic,
                chapters: chapters,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (e.toString().contains("UNAUTHORIZED")) {
        await AuthService.handleUnauthorized(context);
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("$e")));
    }
  }
}
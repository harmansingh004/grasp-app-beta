import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import '../models/course_model.dart';
import '../services/api_service.dart';
import 'course_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String topic;
  const LoadingScreen({super.key, required this.topic});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final storage = const FlutterSecureStorage();
  bool _isCancelled = false;
  int _attemptCount = 0;

  @override
  void initState() {
    super.initState();
    _startGenerationSequence();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _startGenerationSequence() async {
    const int maxRetries = 3;

    while (_attemptCount < maxRetries) {
      if (_isCancelled) return;

      _attemptCount++;
      bool success = await _generateCourse();

      if (success) return;

      if (_attemptCount < maxRetries) {
        if (mounted) {
          setState(() {});
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    if (mounted && !_isCancelled) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to generate after 3 attempts. Try again later."), backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _generateCourse() async {
    try {
      final course = await ApiService.generateCourse(widget.topic, context);

      if (_isCancelled) return false;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CourseScreen(course: course),
          ),
        );
      }

      return true;

    } catch (e) {
      print("Attempt $_attemptCount failed: $e");
      return false;
    }
  }

  Future<void> _handleBackPress() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stop Generation?"),
        content: const Text("The AI is working hard! If you leave, this course will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep Waiting"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Stop", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldStop == true) {
      _isCancelled = true;
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackPress();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: _handleBackPress,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 250,
                child: Lottie.asset(
                  'assets/animations/Rocket animation.json',
                  errorBuilder: (context, error, stackTrace) {
                    return const CircularProgressIndicator(color: Colors.teal);
                  },
                ),
              ),
              const SizedBox(height: 30),
              Text(
                _attemptCount > 1
                    ? "Taking longer than usual... (Attempt $_attemptCount/3)"
                    : "Crafting your course...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
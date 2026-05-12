import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AskAIDialog extends StatefulWidget {
  final String courseContent;

  const AskAIDialog({super.key, required this.courseContent});

  @override
  State<AskAIDialog> createState() => _AskAIDialogState();
}

class _AskAIDialogState extends State<AskAIDialog> {
  final controller = TextEditingController();
  String answer = "";
  bool loading = false;

  Future<void> ask() async {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      loading = true;
      answer = "";
    });

    try {
      final res = await ApiService.askAI(
        controller.text.trim(),
        widget.courseContent,
        context,
      );

      setState(() {
        answer = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        answer = "Failed to get answer";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Ask Tutor"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Ask something about this course...",
              ),
            ),
            const SizedBox(height: 12),
            if (loading)
              const CircularProgressIndicator()
            else if (answer.isNotEmpty)
              Text(answer),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: ask,
          child: const Text("Ask"),
        ),
      ],
    );
  }
}
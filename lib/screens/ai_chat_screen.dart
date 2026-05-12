import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';

class AIChatScreen extends StatefulWidget {
  final String courseContent;

  const AIChatScreen({
    super.key,
    required this.courseContent,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();

  List<ChatMessage> messages = [];

  bool loading = false;

  Future<void> sendMessage() async {
    final question = controller.text.trim();

    if (question.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(
        text: question,
        isUser: true,
      ));

      loading = true;
    });

    controller.clear();
    scrollToBottom();

    try {
      final answer = await ApiService.askAI(
        question,
        widget.courseContent,
        context,
      );

      setState(() {
        messages.add(ChatMessage(
          text: answer,
          isUser: false,
        ));

        loading = false;
      });

      scrollToBottom();

    } catch (e) {
      setState(() {
        messages.add(ChatMessage(
          text: "Failed to get response.",
          isUser: false,
        ));

        loading = false;
      });
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ask Tutor"),
      ),

      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.smart_toy,
                      size: 80,
                      color: Colors.teal,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Ask anything about this course",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUser
                          ? Colors.teal
                          : (isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black87),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: CircularProgressIndicator(),
            ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Ask your AI tutor...",
                        filled: true,
                        fillColor: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: IconButton(
                      onPressed: loading ? null : sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
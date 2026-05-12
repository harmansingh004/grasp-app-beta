import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/course_model.dart';

class ChapterScreen extends StatefulWidget {
  final Chapter chapter;
  const ChapterScreen({super.key, required this.chapter});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  YoutubePlayerController? _controller;
  bool _isLoadingVideo = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initVideo();
    });
  }

  void _initVideo() {
    if (widget.chapter.videoId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.chapter.videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
    }
    if (mounted) {
      setState(() {
        _isLoadingVideo = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.chapter.title), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoadingVideo)
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_controller != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: YoutubePlayer(
                  controller: _controller!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.teal,
                ),
              )
            else
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, size: 50, color: Colors.grey[500]),
                    const SizedBox(height: 10),
                    Text(
                      "No Video Available",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 25),
            MarkdownBody(
              data: widget.chapter.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                    h1: const TextStyle(
                      color: Colors.teal,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    h2: TextStyle(
                      color: isDark ? Colors.tealAccent : Colors.teal.shade800,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                    h3: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),

                    p: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),

                    listBullet: const TextStyle(
                      color: Colors.teal,
                      fontSize: 16,
                    ),

                    strong: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),

                    code: TextStyle(
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      fontFamily: 'monospace',
                    ),
                    codeblockDecoration: BoxDecoration(
                      color: isDark ? Colors.grey[900] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                  ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

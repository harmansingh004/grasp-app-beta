import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notes_model.dart';
import '../services/note_service.dart';
import 'package:file_picker/file_picker.dart';

import 'note_detail_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<String> pickedFiles = [];
  List<Note> notes = [];
  bool loading = true;

  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    setState(() => loading = true);

    try {
      final data = await NoteService.getNotes();

      if (!mounted) return;

      setState(() {
        notes = data;
        loading = false;
      });

    } catch (e) {
      if (!mounted) return;

      setState(() {
        notes = [];
        loading = false;
      });
    }
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
    );

    if (result != null) {
      setState(() {
        pickedFiles = result.paths.whereType<String>().toList();
      });
    }
  }

  void removeFile(int index) {
    setState(() {
      pickedFiles.removeAt(index);
    });
  }

  Future<void> uploadNote() async {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Title is required")));
      return;
    }

    if (pickedFiles.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pick file first")));
      return;
    }

    String? error = await NoteService.uploadNote(
      titleController.text,
      descController.text,
      pickedFiles,
    );

    if (error == null) {
      setState(() => pickedFiles.clear());

      titleController.clear();
      descController.clear();
      loadNotes();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Uploaded")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Cannot open file")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "Title",
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: "Description",
                      prefixIcon: Icon(Icons.notes),
                    ),
                  ),

                  const SizedBox(height: 10),

                  if (pickedFiles.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Files",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),

                          ...pickedFiles.asMap().entries.map((entry) {
                            int index = entry.key;
                            String path = entry.value;
                            String name = path.split('/').last;

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(
                                Icons.insert_drive_file,
                                color: Colors.teal,
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(fontSize: 13),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () => removeFile(index),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: pickFile,
                          icon: const Icon(Icons.attach_file),
                          label: const Text("Pick Files"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: uploadNote,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text("Upload"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : notes.isEmpty
                ? const Center(child: Text("No notes uploaded"))
                : ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final n = notes[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.file_copy_sharp,
                            color: Colors.red,
                          ),
                          title: Text(n.title),
                          subtitle: Text(n.description),
                          trailing: const Icon(Icons.open_in_new),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteDetailScreen(note: n),
                              ),
                            );
                          },
                          onLongPress: () async {
                            bool confirm = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Note"),
                                content: const Text("Are you sure?"),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text("Delete"),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              bool success = await NoteService.deleteNote(n.id);
                              print("Deleting note id: ${n.id}");
                              if (success) {
                                loadNotes();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Deleted")),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Delete failed"),
                                  ),
                                );
                              }
                            }
                          },
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

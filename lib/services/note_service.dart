import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/notes_model.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NoteService {
  static const baseUrl = "http://10.23.145.89:3000";
  static const storage = FlutterSecureStorage();

  static Future<String?> uploadNote(
    String title,
    String desc,
    List<String> filePaths,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_file'),
    );

    String? token = await storage.read(key: "accessToken");
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['title'] = title;
    request.fields['description'] = desc;

    for (String path in filePaths) {
      request.files.add(await http.MultipartFile.fromPath('files', path));
    }

    var response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return null;
    } else {
      try {
        final data = jsonDecode(respStr);
        return data["error"] ?? "Upload failed";
      } catch (e) {
        return "Upload failed";
      }
    }
  }

  static Future<List<Note>> getNotes() async {

    String? token = await storage.read(key: "accessToken");

    final res = await http.get(
      Uri.parse('$baseUrl/notes'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      return data.map((e) => Note.fromJson(e)).toList();
    } else {
      print(res.body);
      throw Exception('Failed to load notes');
    }
  }

  static Future<bool> deleteNote(String id) async {

    String? token = await storage.read(key: "accessToken");

    final res = await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      print(res.body);
      return false;
    }
  }
}

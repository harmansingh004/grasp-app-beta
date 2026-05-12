import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/course_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.23.145.89:3000';
  static const storage = FlutterSecureStorage();

  // HEADERS
  static Future<Map<String, String>> _headers() async {
    String? token = await storage.read(key: "accessToken");

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  // HANDLE RESPONSE
  static Future<dynamic> _handleResponse(
      http.Response response, BuildContext context) async {

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data["success"] == true) {
        return data["data"];
      } else {
        throw Exception(data["error"] ?? "Unknown error");
      }
    }

    if (response.statusCode == 401) {
      await AuthService.handleUnauthorized(context);
      throw Exception("Session expired");
    }

    throw Exception(data["error"] ?? "Server error");
  }

  // GENERATE COURSE
  static Future<Course> generateCourse(
      String topic, BuildContext context) async {

    final response = await http.post(
      Uri.parse('$baseUrl/courses/generate'),
      headers: await _headers(),
      body: jsonEncode({'topic': topic}),
    ).timeout(const Duration(seconds: 60));

    final data = await _handleResponse(response, context);
    return Course.fromJson(data);
  }

  // GET COURSE HISTORY
  static Future<List<Course>> getCourseHistory(
      BuildContext context) async {

    final response = await http.get(
      Uri.parse('$baseUrl/courses'),
      headers: await _headers(),
    );

    final data = await _handleResponse(response, context);

    final List<dynamic> list = data;
    return list.map((json) => Course(
      id: json['id'],
      topic: json['topic'],
      chapters: [],
    )).toList();
  }

  // GET CHAPTERS
  static Future<List<Chapter>> getCourseChapters(
      String courseId, BuildContext context) async {

    final response = await http.get(
      Uri.parse('$baseUrl/courses/$courseId'),
      headers: await _headers(),
    );

    final data = await _handleResponse(response, context);

    List list = data;
    return list.map((json) => Chapter.fromJson(json)).toList();
  }

  // ASK AI
  static Future<String> askAI(
      String question,
      String courseContent,
      BuildContext context,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ai/ask'),
      headers: await _headers(),
      body: jsonEncode({
        "question": question,
        "courseContent": courseContent,
      }),
    );

    final data = await _handleResponse(response, context);
    return data;
  }
}
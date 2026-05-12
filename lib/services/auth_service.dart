import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/login_screen.dart';

class AuthService {
  static final storage = const FlutterSecureStorage();

  static Future<void> handleUnauthorized(BuildContext context) async {
    await storage.deleteAll();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }
}
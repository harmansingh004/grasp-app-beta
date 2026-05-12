import 'package:Grasp/screens/login_screen.dart';
import 'package:Grasp/screens/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/downloads_screen.dart';
import 'screens/settings_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  final storage = const FlutterSecureStorage();
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const HistoryScreen(),
    const DownloadsScreen(),
    const NotesScreen(),
    const SettingsScreen(),
  ];

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2);

    return Scaffold(
        extendBody: true,
        body: _screens[_selectedIndex],

        bottomNavigationBar: SafeArea(
          child: Container(
            height: 70,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            decoration: BoxDecoration(
              color: navColor,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_rounded, "Home", 0),
                _buildNavItem(Icons.history_rounded, "Courses", 1),
                _buildNavItem(Icons.download_rounded, "Saved", 2),
                _buildNavItem(Icons.note_rounded, "Notes", 3),
                _buildNavItem(Icons.settings_rounded, "Settings", 4),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
            : const EdgeInsets.all(10),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.teal.withOpacity(0.5), width: 1.5),
        )
            : BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.teal : Colors.grey,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
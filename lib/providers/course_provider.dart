import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';

class CourseNotifier extends StateNotifier<AsyncValue<Course?>> {
  final ApiService _apiService;

  CourseNotifier(this._apiService) : super(const AsyncValue.data(null));

  Future<void> generateCourse(BuildContext context,String topic) async {
    state = const AsyncValue.loading();

    try {
      final course = await ApiService.generateCourse(topic , context);
      state = AsyncValue.data(course);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final courseProvider = StateNotifierProvider<CourseNotifier, AsyncValue<Course?>>((ref) {
  return CourseNotifier(ApiService());
});
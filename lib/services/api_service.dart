import 'dart:convert';

import '../models/task.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();

  Future<List<Task>> getTasks() async {
    final response = await _authService.authenticatedGet('/tasks/');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    }

    throw Exception('Failed to load tasks.');
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required String category,
    required DateTime dueAt,
    required String priority,
    required bool completed,
  }) async {
    final response = await _authService.authenticatedPost(
      '/tasks/',
      body: {
        'title': title,
        'description': description,
        'category': category,
        'due_at': dueAt.toIso8601String(),
        'priority': priority,
        'completed': completed,
      },
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create task.');
  }

  Future<Task> updateTask(Task task) async {
    final response = await _authService.authenticatedPut(
      '/tasks/${task.id}/',
      body: {
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'due_at': task.dueAt.toIso8601String(),
        'priority': task.priority,
        'completed': task.completed,
      },
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update task.');
  }

  Future<void> deleteTask(int taskId) async {
    final response = await _authService.authenticatedDelete('/tasks/$taskId/');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task.');
    }
  }
}

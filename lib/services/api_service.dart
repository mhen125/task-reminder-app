import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'auth_service.dart';

class ApiService {
  // static const String baseUrl = 'http://67.217.244.6/api';
  static const String baseUrl = 'http://localhost:8001/api';
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final String? token = await _authService.getAccessToken();

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _authorizedRequest(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    Map<String, String> headers = await _getHeaders();
    http.Response response = await request(headers);

    if (response.statusCode == 401) {
      final bool refreshed = await _authService.refreshAccessToken();

      if (refreshed) {
        headers = await _getHeaders();
        response = await request(headers);
      }
    }

    return response;
  }

  Future<List<Task>> getTasks() async {
    final Uri url = Uri.parse('$baseUrl/tasks/');

    final http.Response response = await _authorizedRequest(
      (headers) => http.get(url, headers: headers),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    }

    throw Exception('Failed to load tasks: ${response.body}');
  }

  Future<Task> createTask({
    required String title,
    String? description,
    required DateTime dueAt,
    required String priority,
    required bool completed,
  }) async {
    final Uri url = Uri.parse('$baseUrl/tasks/');

    final http.Response response = await _authorizedRequest(
      (headers) => http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'title': title,
          'description': description,
          'due_at': dueAt.toIso8601String(),
          'priority': priority,
          'completed': completed,
        }),
      ),
    );

    if (response.statusCode == 201) {
      return Task.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to create task: ${response.body}');
  }

  Future<Task> updateTask(Task task) async {
    final Uri url = Uri.parse('$baseUrl/tasks/${task.id}/');

    final http.Response response = await _authorizedRequest(
      (headers) => http.put(
        url,
        headers: headers,
        body: jsonEncode({
          'title': task.title,
          'description': task.description,
          'due_at': task.dueAt.toIso8601String(),
          'priority': task.priority,
          'completed': task.completed,
        }),
      ),
    );

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    }

    throw Exception('Failed to update task: ${response.body}');
  }

  Future<void> deleteTask(int taskId) async {
    final Uri url = Uri.parse('$baseUrl/tasks/$taskId/');

    final http.Response response = await _authorizedRequest(
      (headers) => http.delete(url, headers: headers),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}
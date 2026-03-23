import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Task> tasks = await _apiService.getTasks();

      if (!mounted) {
        return;
      }

      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestTask() async {
    try {
      await _apiService.createTask(
        title: 'Test Task from Flutter',
        description: 'This task was created through the Flutter app.',
        dueAt: DateTime.now().add(const Duration(hours: 2)),
        priority: 'low',
        completed: false,
      );

      await _loadTasks();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create failed: $e')),
      );
    }
  }

  Future<void> _toggleTaskCompleted(Task task) async {
    try {
      final Task updatedTask = task.copyWith(completed: !task.completed);
      await _apiService.updateTask(updatedTask);
      await _loadTasks();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e')),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _apiService.deleteTask(task.id);
      await _loadTasks();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy h:mm a').format(dateTime.toLocal());
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            onPressed: _loadTasks,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createTestTask,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_errorMessage!),
                  ),
                )
              : _tasks.isEmpty
                  ? const Center(
                      child: Text('No tasks found.'),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final Task task = _tasks[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (task.description != null &&
                                    task.description!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(task.description!),
                                  ),
                                const SizedBox(height: 6),
                                Text('Due: ${_formatDate(task.dueAt)}'),
                                const SizedBox(height: 4),
                                Text(
                                  'Priority: ${task.priority}',
                                  style: TextStyle(
                                    color: _priorityColor(task.priority),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  task.completed ? 'Completed' : 'Incomplete',
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'toggle') {
                                  _toggleTaskCompleted(task);
                                } else if (value == 'delete') {
                                  _deleteTask(task);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem<String>(
                                  value: 'toggle',
                                  child: Text(
                                    task.completed
                                        ? 'Mark Incomplete'
                                        : 'Mark Complete',
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
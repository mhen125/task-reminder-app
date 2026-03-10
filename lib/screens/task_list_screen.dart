import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/firestore_task_service.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_list_tile.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirestoreTaskService _taskService = FirestoreTaskService();

  TaskCategory? _selectedCategory;
  Priority? _selectedPriority;
  bool _showCompletedTasks = false;

  List<Task> _applyFilters(List<Task> tasks) {
    List<Task> filtered = List<Task>.from(tasks);

    if (_selectedCategory != null) {
      filtered =
          filtered.where((task) => task.category == _selectedCategory).toList();
    }

    if (_selectedPriority != null) {
      filtered =
          filtered.where((task) => task.priority == _selectedPriority).toList();
    }

    if (!_showCompletedTasks) {
      filtered = filtered.where((task) => !task.isDone).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (newTask) async {
          if (task == null) {
            await _taskService.addTask(newTask);
          } else {
            await _taskService.updateTask(newTask);
          }
        },
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return Colors.green;
      case Priority.medium:
        return Colors.orange;
      case Priority.high:
        return Colors.red;
      case Priority.urgent:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 2,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                if (value == 'show_completed') {
                  _showCompletedTasks = !_showCompletedTasks;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'show_completed',
                child: Row(
                  children: [
                    Icon(
                      _showCompletedTasks
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    const SizedBox(width: 8),
                    const Text('Show Completed'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _taskService.streamTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Error loading tasks:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final allTasks = snapshot.data ?? <Task>[];
          final filteredTasks = _applyFilters(allTasks);

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ...TaskCategory.values.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category.label),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? category : null;
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    ...Priority.values.map((priority) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(priority.label),
                          selected: _selectedPriority == priority,
                          onSelected: (selected) {
                            setState(() {
                              _selectedPriority = selected ? priority : null;
                            });
                          },
                          backgroundColor:
                              _getPriorityColor(priority).withValues(alpha: 0.2),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredTasks.length} ${filteredTasks.length == 1 ? 'task' : 'tasks'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_selectedCategory != null || _selectedPriority != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCategory = null;
                            _selectedPriority = null;
                          });
                        },
                        icon: const Icon(Icons.clear, size: 16),
                        label: const Text('Clear filters'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.task_alt,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              allTasks.isEmpty
                                  ? 'No tasks yet.\nTap + to add one!'
                                  : 'No tasks match your filters',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];

                          return TaskListTile(
                            task: task,
                            onToggle: () => _taskService.toggleTaskCompletion(task),
                            onDelete: () => _taskService.deleteTask(task.id),
                            onEdit: () => _showTaskDialog(context, task: task),
                            onPriorityChange: (newPriority) =>
                                _taskService.updateTaskPriority(task, newPriority),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
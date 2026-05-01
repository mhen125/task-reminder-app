import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'task_form_screen.dart';

enum SortOption { newest, oldest, priorityDesc, priorityAsc, dueDate }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  String? _username;

  SortOption _selectedSort = SortOption.newest;
  Set<String> _selectedCategories = {};
  bool _showCompleted = false;

  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadTasks();
  }

  List<String> _getAllCategories() {
    return _tasks.map((task) => task.category).toSet().toList()..sort();
  }

  void _redirectToLoginWithSessionMessage([String? message]) {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          sessionMessage:
              message ?? 'Your session expired. Please sign in again.',
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _loadUsername() async {
    final username = await _authService.getUsername();
    if (!mounted) return;

    setState(() {
      _username = username;
    });
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
    } on SessionExpiredException catch (e) {
      await _authService.logout();

      if (!mounted) {
        return;
      }

      _redirectToLoginWithSessionMessage(e.message);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Unable to load tasks right now. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddTaskScreen() async {
    final bool? changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const TaskFormScreen()));

    if (changed == true) {
      await _loadTasks();
    }
  }

  Future<void> _openEditTaskScreen(Task task) async {
    final bool? changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)));

    if (changed == true) {
      await _loadTasks();
    }
  }

  Future<void> _toggleTaskCompleted(Task task) async {
    try {
      final Task updatedTask = task.copyWith(completed: !task.completed);
      await _apiService.updateTask(updatedTask);
      await _loadTasks();
    } on SessionExpiredException catch (e) {
      await _authService.logout();

      if (!mounted) {
        return;
      }

      _redirectToLoginWithSessionMessage(e.message);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update the task. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteTask(Task task) async {
    try {
      await _apiService.deleteTask(task.id);
      await _loadTasks();
    } on SessionExpiredException catch (e) {
      await _authService.logout();

      if (!mounted) {
        return;
      }

      _redirectToLoginWithSessionMessage(e.message);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to delete the task. Please try again.'),
        ),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
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

  bool _isOverdue(Task task) {
    return !task.completed && task.dueAt.isBefore(DateTime.now());
  }

  int _priorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 3;
      case 'medium':
        return 2;
      case 'low':
        return 1;
      default:
        return 0;
    }
  }

  String _capitalizeWords(String text) {
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _getFilterButtonText() {
    int count = _selectedCategories.length;

    if (_showCompleted) {
      count += 1;
    }

    if (count == 0) {
      return 'Filter';
    }

    return 'Filter ($count)';
  }

  List<Task> _processTasks(List<Task> tasks) {
    List<Task> result = List.from(tasks);

    // ✅ FILTER: categories
    if (_selectedCategories.isNotEmpty) {
      result = result
          .where((task) => _selectedCategories.contains(task.category))
          .toList();
    }

    // ✅ FILTER: completed
    if (!_showCompleted) {
      result = result.where((task) => !task.completed).toList();
    }

    // ✅ SORTING
    switch (_selectedSort) {
      case SortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case SortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case SortOption.priorityDesc:
        result.sort(
          (a, b) =>
              _priorityValue(b.priority).compareTo(_priorityValue(a.priority)),
        );
        break;

      case SortOption.priorityAsc:
        result.sort(
          (a, b) =>
              _priorityValue(a.priority).compareTo(_priorityValue(b.priority)),
        );
        break;

      case SortOption.dueDate:
        result.sort((a, b) => a.dueAt.compareTo(b.dueAt));
        break;
    }

    return result;
  }

  void _openFilterDialog() {
    final categories = _getAllCategories();
    final tempSelected = Set<String>.from(_selectedCategories);
    bool tempShowCompleted = _showCompleted;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Filter Tasks'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Categories'),
                    const SizedBox(height: 8),

                    ...categories.map((category) {
                      return CheckboxListTile(
                        value: tempSelected.contains(category),
                        title: Text(category),
                        onChanged: (checked) {
                          setModalState(() {
                            if (checked == true) {
                              tempSelected.add(category);
                            } else {
                              tempSelected.remove(category);
                            }
                          });
                        },
                      );
                    }),

                    const Divider(),

                    SwitchListTile(
                      title: const Text('Show completed tasks'),
                      value: tempShowCompleted,
                      onChanged: (value) {
                        setModalState(() {
                          tempShowCompleted = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategories = tempSelected;
                      _showCompleted = tempShowCompleted;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<SortOption>(
              value: _selectedSort,
              decoration: const InputDecoration(
                labelText: 'Sort',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: const [
                DropdownMenuItem(
                  value: SortOption.newest,
                  child: Text('Newest'),
                ),
                DropdownMenuItem(
                  value: SortOption.oldest,
                  child: Text('Oldest'),
                ),
                DropdownMenuItem(
                  value: SortOption.priorityDesc,
                  child: Text('Priority ▼'),
                ),
                DropdownMenuItem(
                  value: SortOption.priorityAsc,
                  child: Text('Priority ▲'),
                ),
                DropdownMenuItem(
                  value: SortOption.dueDate,
                  child: Text('Upcoming'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedSort = value;
                });
              },
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: _openFilterDialog,
              child: Text(_getFilterButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    final processedTasks = _processTasks(_tasks);

    if (processedTasks.isEmpty) {
      return const Center(child: Text('No tasks found.'));
    }

    return ListView.builder(
      itemCount: processedTasks.length,
      itemBuilder: (context, index) {
        final Task task = processedTasks[index];
        // 👇 keep your existing ListTile code here
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              // Priority color bar
              Container(
                width: 15,
                constraints: const BoxConstraints(minHeight: 72),
                decoration: BoxDecoration(
                  color: task.completed
                      ? Colors.transparent
                      : _priorityColor(task.priority),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              Expanded(
                child: ListTile(
                  title: Text(
                    _capitalizeWords(task.title),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.description != null &&
                          task.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            _capitalizeFirst(task.description!),
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text(task.category),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      task.completed
                          ? const Text(
                              'Completed',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            )
                          : Text(
                              _formatDate(task.dueAt),
                              style: TextStyle(
                                color: _isOverdue(task)
                                    ? Colors.red
                                    : task.dueAt
                                              .difference(DateTime.now())
                                              .inHours <
                                          24
                                    ? const Color.fromARGB(255, 230, 138, 0)
                                    : null,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ],
                  ),
                  onTap: () => _openEditTaskScreen(task),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditTaskScreen(task);
                      } else if (value == 'toggle') {
                        _toggleTaskCompleted(task);
                      } else if (value == 'delete') {
                        _deleteTask(task);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem<String>(
                        value: 'toggle',
                        child: Text(
                          task.completed ? 'Mark Incomplete' : 'Mark Complete',
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _username == null
              ? 'My Tasks'
              : '${_capitalizeFirst(_username!)} Tasks',
        ),
        actions: [
          IconButton(onPressed: _loadTasks, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTaskScreen,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _buildControlBar(),
          Expanded(child: _buildBodyContent()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late DateTime _selectedDueAt;
  late String _selectedPriority;

  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();

    final Task? task = widget.task;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: task?.category ?? 'General',
    );

    _selectedDueAt =
        task?.dueAt ?? DateTime.now().add(const Duration(hours: 1));
    _selectedPriority = task?.priority ?? 'low';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
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

  Future<void> _pickDateTime() async {
    final DateTime initialDate = _selectedDueAt;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null || !mounted) {
      return;
    }

    final TimeOfDay initialTime = TimeOfDay.fromDateTime(_selectedDueAt);

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedDueAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        final Task originalTask = widget.task!;

        final Task updatedTask = originalTask.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          category: _categoryController.text.trim().isEmpty
              ? 'General'
              : _categoryController.text.trim(),
          dueAt: _selectedDueAt,
          priority: _selectedPriority,
          completed: originalTask.completed,
        );

        await _apiService.updateTask(updatedTask);
      } else {
        await _apiService.createTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          dueAt: _selectedDueAt,
          priority: _selectedPriority,
          completed: false,
          category: _categoryController.text.trim().isEmpty
              ? 'General'
              : _categoryController.text.trim(),
        );
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
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
        _errorMessage = 'Unable to save the task. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _formatDueAt(DateTime value) {
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    final String year = value.year.toString();
    final String hour = value.hour.toString().padLeft(2, '0');
    final String minute = value.minute.toString().padLeft(2, '0');

    return '$month/$day/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Task' : 'Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due Date & Time'),
                subtitle: Text(_formatDueAt(_selectedDueAt)),
                trailing: ElevatedButton(
                  onPressed: _pickDateTime,
                  child: const Text('Choose'),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedPriority = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTask,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Save Changes' : 'Create Task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

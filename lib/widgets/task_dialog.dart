import 'package:flutter/material.dart';

import '../models/task.dart';

class TaskDialog extends StatefulWidget {
  final Task? task;
  final Future<void> Function(Task) onSave;

  const TaskDialog({
    super.key,
    this.task,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _selectedCategory;
  late Priority _selectedPriority;
  DateTime? _selectedDueDate;
  bool _agingEnabled = true;
  int _escalationThresholdDays = 3;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedCategory = widget.task?.category ?? TaskCategory.personal;
    _selectedPriority = widget.task?.priority ?? Priority.medium;
    _selectedDueDate = widget.task?.dueDate;
    _agingEnabled = widget.task?.agingEnabled ?? true;
    _escalationThresholdDays = widget.task?.escalationThresholdDays ?? 3;
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final newTask = Task(
      id: widget.task?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      priority: _selectedPriority,
      createdAt: widget.task?.createdAt ?? DateTime.now(),
      dueDate: _selectedDueDate,
      isDone: widget.task?.isDone ?? false,
      completedAt: widget.task?.completedAt,
      agingEnabled: _agingEnabled,
      escalationThresholdDays: _escalationThresholdDays,
      lastEscalatedAt: widget.task?.lastEscalatedAt,
    );

    await widget.onSave(newTask);

    if (!mounted) return;
    Navigator.pop(context);
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
    return AlertDialog(
      title: Text(widget.task == null ? 'New Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: TaskCategory.values.map((category) {
                return DropdownMenuItem<TaskCategory>(
                  value: category,
                  child: Text(category.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Priority>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: Priority.values.map((priority) {
                return DropdownMenuItem<Priority>(
                  value: priority,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: _getPriorityColor(priority),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(priority.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable automatic aging'),
              value: _agingEnabled,
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _agingEnabled = value;
                      });
                    },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _escalationThresholdDays,
              decoration: const InputDecoration(
                labelText: 'Escalate every N days',
                border: OutlineInputBorder(),
              ),
              items: const [1, 2, 3, 5, 7, 14].map((days) {
                return DropdownMenuItem<int>(
                  value: days,
                  child: Text('$days day${days == 1 ? '' : 's'}'),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() {
                        _escalationThresholdDays = value;
                      });
                    },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isSaving
                  ? null
                  : () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          _selectedDueDate = date;
                        });
                      }
                    },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDueDate == null
                    ? 'Set due date'
                    : 'Due: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
              ),
            ),
            if (_selectedDueDate != null)
              TextButton.icon(
                onPressed: _isSaving
                    ? null
                    : () {
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear due date'),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _save,
          child: Text(_isSaving ? 'Saving...' : 'Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
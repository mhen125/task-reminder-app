import 'package:flutter/material.dart';

import '../controllers/reminders_controller.dart';
import '../routes.dart';

class ViewRemindersPage extends StatefulWidget {
  final RemindersController controller;

  const ViewRemindersPage({super.key, required this.controller});

  @override
  State<ViewRemindersPage> createState() => _ViewRemindersPageState();
}

class _ViewRemindersPageState extends State<ViewRemindersPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  void _goHomeResetStack(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  void _cancelGoBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _goToAddReminder(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.addReminder);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return Scaffold(
      appBar: AppBar(title: const Text('View Reminders')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.reminders.isEmpty) {
            return const Center(
              child: Text(
                'No reminders yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.reminders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final r = controller.reminders[index];
              return Card(
                child: ListTile(
                  title: Text(r.title),
                  subtitle: Text('Created: ${r.createdAt}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => controller.deleteReminder(r.id),
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goHomeResetStack(context),
                  child: const Text('Return Home (Reset Stack)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelGoBack(context),
                  child: const Text('Cancel (Go Back)'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonal(
                  onPressed: () => _goToAddReminder(context),
                  child: const Text('Add a Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
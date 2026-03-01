import 'package:flutter/material.dart';
import '../routes.dart';

class ViewRemindersPage extends StatelessWidget {
  const ViewRemindersPage({super.key});

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
    return Scaffold(
      appBar: AppBar(title: const Text('View Reminders')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reminders',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goHomeResetStack(context),
                  child: const Text('Return Home (Reset Stack)'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelGoBack(context),
                  child: const Text('Cancel (Go Back)'),
                ),
              ),
              const SizedBox(height: 12),
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
import 'package:flutter/material.dart';
import '../routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goToViewReminders(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.viewReminders);
  }

  void _goToAddReminder(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.addReminder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Home',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goToViewReminders(context),
                  child: const Text('View Reminders'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
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
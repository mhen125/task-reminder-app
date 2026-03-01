import 'package:flutter/material.dart';
import '../routes.dart';

class AddReminderPage extends StatelessWidget {
  const AddReminderPage({super.key});

  void _goBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _goHomeResetStack(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a Reminder')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add a Reminder',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _goBack(context),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _goHomeResetStack(context),
                  child: const Text('Home (Reset Stack)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
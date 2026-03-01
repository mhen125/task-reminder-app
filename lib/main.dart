import 'package:flutter/material.dart';

import 'controllers/reminders_controller.dart';
import 'data/in_memory_reminder_repository.dart';
import 'routes.dart';

void main() {
  final repo = InMemoryReminderRepository();
  final controller = RemindersController(repository: repo);

  runApp(TaskReminderApp(controller: controller));
}

class TaskReminderApp extends StatelessWidget {
  final RemindersController controller;

  const TaskReminderApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes(controller),
    );
  }
}
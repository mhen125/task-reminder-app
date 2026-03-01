import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/view_reminders_page.dart';
import 'pages/add_reminder_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String viewReminders = '/view-reminders';
  static const String addReminder = '/add-reminder';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const HomePage(),
        viewReminders: (context) => const ViewRemindersPage(),
        addReminder: (context) => const AddReminderPage(),
      };
}
import 'package:flutter/material.dart';

import 'controllers/reminders_controller.dart';
import 'pages/add_reminder_page.dart';
import 'pages/home_page.dart';
import 'pages/view_reminders_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String viewReminders = '/view-reminders';
  static const String addReminder = '/add-reminder';

  static Map<String, WidgetBuilder> routes(RemindersController controller) => {
        home: (context) => HomePage(controller: controller),
        viewReminders: (context) => ViewRemindersPage(controller: controller),
        addReminder: (context) => AddReminderPage(controller: controller),
      };
}
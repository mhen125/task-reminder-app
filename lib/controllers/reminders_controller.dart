import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/reminder_repository.dart';
import '../models/reminder.dart';

class RemindersController extends ChangeNotifier {
  final ReminderRepository repository;

  RemindersController({required this.repository});

  List<Reminder> _reminders = [];
  List<Reminder> get reminders => List<Reminder>.unmodifiable(_reminders);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _reminders = await repository.getAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(String title) async {
    final reminder = Reminder(
      id: _simpleId(),
      title: title,
      createdAt: DateTime.now(),
    );

    await repository.add(reminder);
    await load();
  }

  Future<void> deleteReminder(String id) async {
    await repository.deleteById(id);
    await load();
  }

  String _simpleId() {
    // For now: lightweight random ID.
    // Later with Firestore, you'll probably use doc.id.
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = Random();
    return List.generate(20, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}
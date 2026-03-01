import '../models/reminder.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAll();
  Future<void> add(Reminder reminder);
  Future<void> deleteById(String id);
}
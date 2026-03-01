import '../models/reminder.dart';
import 'reminder_repository.dart';

class InMemoryReminderRepository implements ReminderRepository {
  final List<Reminder> _items = [];

  @override
  Future<List<Reminder>> getAll() async {
    // Return a copy so callers can’t mutate internal state.
    return List<Reminder>.unmodifiable(_items);
  }

  @override
  Future<void> add(Reminder reminder) async {
    _items.add(reminder);
  }

  @override
  Future<void> deleteById(String id) async {
    _items.removeWhere((r) => r.id == id);
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import 'auth_service.dart';

class FirestoreTaskService {
  FirestoreTaskService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String get _uid {
    final uid = AuthService.instance.currentUid;
    if (uid == null) {
      throw StateError('No authenticated user is available.');
    }
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('users').doc(_uid).collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final tasks = snapshot.docs.map(Task.fromDocument).toList();

          await _applyAgingIfNeeded(tasks);

          return tasks;
        });
  }

  Future<void> addTask(Task task) async {
    final docRef = _tasksCollection.doc();
    final taskWithId = task.copyWith(id: docRef.id);
    await docRef.set(taskWithId.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(
      isDone: !task.isDone,
      completedAt: !task.isDone ? DateTime.now() : null,
    );

    await updateTask(updatedTask);
  }

  Future<void> updateTaskPriority(Task task, Priority newPriority) async {
    final updatedTask = task.copyWith(priority: newPriority);
    await updateTask(updatedTask);
  }

  Future<void> _applyAgingIfNeeded(List<Task> tasks) async {
    final batch = _firestore.batch();
    var hasChanges = false;

    for (final task in tasks) {
      final escalated = task.escalatedIfNeeded();
      if (escalated != null) {
        batch.update(_tasksCollection.doc(task.id), escalated.toMap());
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await batch.commit();
    }
  }
}

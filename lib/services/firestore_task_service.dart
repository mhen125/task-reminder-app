import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';

class FirestoreTaskService {
  FirestoreTaskService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No authenticated user.');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('users').doc(_uid).collection('tasks');

  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Task.fromDocument).toList());
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
}

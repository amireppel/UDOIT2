import 'package:flutter/material.dart';
import './activities_provider.dart';

class NewActivityProvider with ChangeNotifier {
  String _activityName = '';
  List<Task> _tasks = [];
  ValueNotifier<String> activityNameNotifier = ValueNotifier<String>('');
  ValueNotifier<List<Task>> tasksNotifier = ValueNotifier<List<Task>>([]);

  String get activityName => _activityName;
  List<Task> get tasks => _tasks;

  void updateActivityName(String name) {
    _activityName = name;
    activityNameNotifier.value = name;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    tasksNotifier.value = List.from(_tasks);
    notifyListeners();
  }

  void clearTasks() {
    _tasks.clear();
    tasksNotifier.value = List.from(_tasks);
    notifyListeners();
  }
}
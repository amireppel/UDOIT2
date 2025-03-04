import 'package:flutter/material.dart';
import './activities_provider.dart';

class NewActivityProvider with ChangeNotifier {
  String _activityName = '';
  List<Task> _tasks = [];
  ValueNotifier<String> activityNameNotifier = ValueNotifier<String>('');
  ValueNotifier<List<Task>> tasksNotifier = ValueNotifier<List<Task>>([]);
  Task? _editingTask;
  int? _editingActivityIndex;

  String get activityName => _activityName;
  List<Task> get tasks => _tasks;
  Task? get editingTask => _editingTask;
  int? get editingActivityIndex => _editingActivityIndex;

  void updateActivityName(String name) {
    _activityName = name;
    activityNameNotifier.value = name;
    notifyListeners();
  }

  void addTask(Task task) {
    if (_editingTask != null) {
      int index = _tasks.indexOf(_editingTask!);
      _tasks[index] = task;
      _editingTask = null;
    } else {
      _tasks.add(task);
    }
    tasksNotifier.value = List.from(_tasks);
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    tasksNotifier.value = List.from(_tasks);
    notifyListeners();
  }

  void editTask(Task task) {
    _editingTask = task;
    notifyListeners();
  }

  void clearTasks() {
    _tasks.clear();
    tasksNotifier.value = List.from(_tasks);
    notifyListeners();
  }

  void clearEditingTask() {
    _editingTask = null;
    notifyListeners();
  }

  void startEditingActivity(int index, Activity activity) {
    _editingActivityIndex = index;
    _activityName = activity.name;
    _tasks = List.from(activity.tasks);
    activityNameNotifier.value = activity.name;
    tasksNotifier.value = List.from(activity.tasks);
    notifyListeners();
  }

  void stopEditingActivity() {
    _editingActivityIndex = null;
    _activityName = '';
    _tasks = [];
    activityNameNotifier.value = '';
    tasksNotifier.value = [];
    notifyListeners();
  }
}
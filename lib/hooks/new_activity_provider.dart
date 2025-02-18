import 'package:flutter/material.dart';
import './activities_provider.dart';


class NewActivityProvider with ChangeNotifier {
  String _activityName = '';
  List<Task> _tasks = [];

  String get activityName => _activityName;
  List<Task> get tasks => _tasks;

  void updateActivityName(String name) {
    _activityName = name;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }
}
import 'package:flutter/material.dart';

class Task {
  String name;
  int durationInSeconds;
  String soundFile;

  Task({required this.name, required this.durationInSeconds, this.soundFile = ''});
}

class Activity {
  String name;
  List<Task> tasks;

  Activity({required this.name, required this.tasks});
}

class ActivitiesProvider with ChangeNotifier {
 List<Activity> _activities = [
    Activity(
      name: 'Example',
      tasks: [
        Task(name: 'Jump', durationInSeconds: 30),
        Task(name: 'Rest', durationInSeconds: 20),
      ],
    ),
  ];

  List<Activity> get activities => _activities;

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void addTaskToActivity(String activityName, Task task) {
    final activity = _activities.firstWhere((activity) => activity.name == activityName);
    activity.tasks.add(task);
    notifyListeners();
  }
}
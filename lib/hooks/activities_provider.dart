import 'package:flutter/material.dart';
import 'dart:developer'; // Import the developer package for logging
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Import for JSON encoding and decoding

class Task {
  String name;
  int durationInSeconds;
  String soundFile;

  Task({required this.name, required this.durationInSeconds, this.soundFile = ''});

  Map<String, dynamic> toJson() => {
        'name': name,
        'durationInSeconds': durationInSeconds,
        'soundFile': soundFile,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        durationInSeconds: json['durationInSeconds'],
        soundFile: json['soundFile'],
      );
}

class Activity {
  String name;
  List<Task> tasks;

  Activity({required this.name, required this.tasks});

  Map<String, dynamic> toJson() => {
        'name': name,
        'tasks': tasks.map((task) => task.toJson()).toList(),
      };

  static Activity fromJson(Map<String, dynamic> json) => Activity(
        name: json['name'],
        tasks: List<Task>.from(json['tasks'].map((task) => Task.fromJson(task))),
      );
}

class ActivitiesProvider with ChangeNotifier {
  List<Activity> _activities = [];

  List<Activity> get activities => _activities;

  ActivitiesProvider() {
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesString = prefs.getString('activities');
    if (activitiesString != null) {
      final activitiesJson = json.decode(activitiesString) as List;
      _activities = activitiesJson.map((json) => Activity.fromJson(json)).toList();
    } else {
      _activities = [];
    }
    notifyListeners();
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final activitiesJson = _activities.map((activity) => activity.toJson()).toList();
    final activitiesString = json.encode(activitiesJson);
    await prefs.setString('activities', activitiesString);
  }

  void addActivity(Activity activity) {
    log('Activity added: ${activity.name}');
    for (var task in activity.tasks) {
      log('Task Name: ${task.name}, Duration: ${task.durationInSeconds} seconds');
    }
    _activities.add(activity);
    _saveActivities();
    notifyListeners();
  }

  void updateActivity(int index, Activity updatedActivity) {
    _activities[index] = updatedActivity;
    _saveActivities();
    notifyListeners();
  }

  void addTaskToActivity(String activityName, Task task) {
    final activity = _activities.firstWhere((activity) => activity.name == activityName);
    activity.tasks.add(task);
    _saveActivities();
    notifyListeners();
  }
}
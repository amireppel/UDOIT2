import 'package:flutter/material.dart';

class RunningActivityProvider with ChangeNotifier {
  bool _isRunningActivity = false;

  bool get isRunningActivity => _isRunningActivity;

  void setRunningActivity(bool isRunning) {
    _isRunningActivity = isRunning;
    notifyListeners();
  }
}
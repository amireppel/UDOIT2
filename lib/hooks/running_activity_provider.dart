import 'package:flutter/material.dart';

class RunningActivityProvider with ChangeNotifier {
  bool _isRunningActivity = false;
  int? _runningActivityIndex;

  bool get isRunningActivity => _isRunningActivity;
  int? get runningActivityIndex => _runningActivityIndex;

  void setRunningActivity(bool isRunning, {int? index}) {
    _isRunningActivity = isRunning;
    _runningActivityIndex = index;
    notifyListeners();
  }
}
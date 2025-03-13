// Add the following imports if not already present
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:io';
import 'dart:async';
import '../../hooks/activities_provider.dart';
import '../../hooks/running_activity_provider.dart';
import '../../hooks/settings_provider.dart';

import './progress_bar.dart';

class RunningActivity extends StatefulWidget {
  final int? loopCount;

  RunningActivity({this.loopCount});

  @override
  _RunningActivityState createState() => _RunningActivityState();
}

class _RunningActivityState extends State<RunningActivity> {
  FlutterSoundPlayer? _player;
  int _currentTaskIndex = 0;
  int _remainingTime = 0;
  int _currentLoop = 1;
  Timer? _timer;
  late Duration taskDuration;
  late double progress = 1.0;
  bool _isRunning = true; // Track if the countdown is running
  bool _isSkipmode = false; // Track if the skip mode is enabled

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    progress = 1.0; // Initialize progress here
    _player!.openPlayer().then((_) {
      _startNextTask();
    });
    WakelockPlus.enable(); // Enable wakelock
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _player = null;
    _timer?.cancel();
    WakelockPlus.disable(); // Disable wakelock
    super.dispose();
  }

  Future<String> _loadAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile.uri.toString();
  }

  void _startNextTask() async {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(
      context,
      listen: false,
    );
    final activitiesProvider = Provider.of<ActivitiesProvider>(
      context,
      listen: false,
    );
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );

    if (runningActivityProvider.runningActivityIndex == null) return;

    final activity =
        activitiesProvider.activities[runningActivityProvider
            .runningActivityIndex!];
    if (_currentTaskIndex >= activity.tasks.length) {
      if (widget.loopCount != null && _currentLoop < widget.loopCount!) {
        _currentLoop++;
        _currentTaskIndex = 0;
        _startNextTask();
      } else {
        _finishActivity();
      }
      return;
    }

    final task = activity.tasks[_currentTaskIndex];
    setState(() {
      _remainingTime = task.durationInSeconds;
      taskDuration = Duration(seconds: task.durationInSeconds);
      progress = 1.0;
      _isRunning = true; // Reset running state
    });

    if (task.soundFile.isNotEmpty && settingsProvider.playRecording) {
      _player!
          .startPlayer(
            fromURI: task.soundFile,
            codec: Codec.aacADTS,
            whenFinished: () {
              _playStartSound().then((_) {
                _startCountdown();
              });
            },
          )
          .catchError((error) {
            print('Error playing task sound: $error');
            _playStartSound().then((_) {
              _startCountdown();
            });
          });
    } else {
      _playStartSound().then((_) {
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          progress = _remainingTime / taskDuration.inSeconds;
        } else {
          timer.cancel();
          _playCompletionSound().then((_) {
            if (_currentTaskIndex < _getTotalTasks() - 1) {
              _currentTaskIndex++;
              _startNextTask();
            } else {
              if (widget.loopCount != null &&
                  _currentLoop < widget.loopCount!) {
                _currentLoop++;
                _currentTaskIndex = 0;
                _startNextTask();
              } else {
                _finishActivity();
              }
            }
          });
        }
      });
    });
  }

  Future<void> _playStartSound() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (settingsProvider.playStartSound) {
      String soundPath = await _loadAsset(settingsProvider.startSoundFile.path);
      Completer<void> completer = Completer<void>();
      await _player!
          .startPlayer(
            fromURI: soundPath,
            codec: Codec.aacADTS,
            whenFinished: () {
              completer.complete();
            },
          )
          .catchError((error) {
            print('Error playing start sound: $error');
            completer.complete();
          });
      return completer.future;
    }
  }

  Future<void> _playCompletionSound() async {
    final settingsProvider = Provider.of<SettingsProvider>(
      context,
      listen: false,
    );
    if (settingsProvider.playEndSound) {
      String soundPath = await _loadAsset(settingsProvider.endSoundFile.path);
      Completer<void> completer = Completer<void>();
      await _player!
          .startPlayer(
            fromURI: soundPath,
            codec: Codec.aacADTS,
            whenFinished: () {
              completer.complete();
            },
          )
          .catchError((error) {
            print('Error playing completion sound: $error');
            completer.complete();
          });
      return completer.future;
    }
  }

  void _finishActivity() {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(
      context,
      listen: false,
    );
    runningActivityProvider.setRunningActivity(false, index: null);
    Navigator.pop(context); // Navigate back to the previous screen
    WakelockPlus.disable(); // Disable wakelock when activity ends
  }

  int _getTotalTasks() {
    final activitiesProvider = Provider.of<ActivitiesProvider>(
      context,
      listen: false,
    );
    final runningActivityProvider = Provider.of<RunningActivityProvider>(
      context,
      listen: false,
    );
    final activity =
        activitiesProvider.activities[runningActivityProvider
            .runningActivityIndex!];
    return activity.tasks.length;
  }

  void _stopCountdown() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _continueCountdown() {
    if (_isSkipmode) {
      setState(() {
        _isSkipmode = false;
      });

      _startNextTask();
      return;
    }
    setState(() {
      _isRunning = true;
    });
    _startCountdown();
  }

  void _moveToTask(int index) {
    final activitiesProvider = Provider.of<ActivitiesProvider>(
      context,
      listen: false,
    );
    final runningActivityProvider = Provider.of<RunningActivityProvider>(
      context,
      listen: false,
    );
    final duration =
        activitiesProvider
            .activities[runningActivityProvider.runningActivityIndex!]
            .tasks[index]
            .durationInSeconds;
    setState(() {
      _timer?.cancel();
      _remainingTime = duration;
      taskDuration = Duration(seconds: duration);
      progress = 1.0;
      _currentTaskIndex = index;
      _isRunning = false;
      _isSkipmode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(
      context,
    );
    final activitiesProvider = Provider.of<ActivitiesProvider>(context);

    if (runningActivityProvider.runningActivityIndex == null)
      return Container();

    final activity =
        activitiesProvider.activities[runningActivityProvider
            .runningActivityIndex!];
    final task = activity.tasks[_currentTaskIndex];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _finishActivity();
      },

      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              _finishActivity();
            },
            child: Text('Exit'),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.loopCount != null)
                    Column(
                      children: [
                        Text(
                          'Number of Loops: ${widget.loopCount}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Current Loop: $_currentLoop/${widget.loopCount}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Text(
                    task.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ProgressBar(
                    progress: progress,
                    duration: Duration(seconds: _remainingTime),
                  ),
                  SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        onPressed:
                            _currentTaskIndex == 0
                                ? null
                                : () {
                                  _moveToTask(_currentTaskIndex - 1);
                                },

                        child: Icon(
                          Icons.navigate_before,
                          size: 60,
                          color:
                              _currentTaskIndex != 0
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 10, height: 10),
                      ElevatedButton(
                        onPressed:
                            _isRunning && !_isSkipmode
                                ? _stopCountdown
                                : _continueCountdown,
                        child: Icon(
                          _isRunning ? Icons.pause : Icons.play_arrow,
                          size: 60,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            _currentTaskIndex + 1 == activity.tasks.length
                                ? null
                                : () {
                                  _moveToTask(_currentTaskIndex + 1);
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                        // Add functionality for next button here
                        child: Icon(
                          Icons.navigate_next,
                          size: 60,
                          color:
                              _currentTaskIndex + 1 != activity.tasks.length
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Add other UI elements here
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

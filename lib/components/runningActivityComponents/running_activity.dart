// File: lib/running_activity.dart
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

import './progress_bar.dart';

class RunningActivity extends StatefulWidget {
  @override
  _RunningActivityState createState() => _RunningActivityState();
}

class _RunningActivityState extends State<RunningActivity> {
  FlutterSoundPlayer? _player;
  int _currentTaskIndex = 0;
  int _remainingTime = 0;
  Timer? _timer;
  late Duration taskDuration;
  late double progress = 1.0;
  bool _isRunning = true; // Track if the countdown is running

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
    final File tempFile = File('${tempDir.path}/dixie_horn.wav');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile.uri.toString();
  }

  void _startNextTask() async {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context, listen: false);
    final activitiesProvider = Provider.of<ActivitiesProvider>(context, listen: false);

    if (runningActivityProvider.runningActivityIndex == null) return;

    final activity = activitiesProvider.activities[runningActivityProvider.runningActivityIndex!];
    if (_currentTaskIndex >= activity.tasks.length) {
      _finishActivity();
      return;
    }

    final task = activity.tasks[_currentTaskIndex];
    setState(() {
      _remainingTime = task.durationInSeconds;
      taskDuration = Duration(seconds: task.durationInSeconds);
      progress = 1.0;
      _isRunning = true; // Reset running state
    });

    if (task.soundFile.isNotEmpty) {
      _player!.startPlayer(
        fromURI: task.soundFile,
        codec: Codec.aacADTS,
        whenFinished: () {
          _startCountdown();
        },
      ).catchError((error) {
        print('Error playing task sound: $error');
        _startCountdown();
      });
    } else {
      _startCountdown();
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
              _finishActivity();
            
            }
          });
        }
      });
    });
  }

  Future<void> _playCompletionSound() async {
    String soundPath = await _loadAsset('assets/sounds/dixie_horn.wav');
    Completer<void> completer = Completer<void>();
    await _player!.startPlayer(
      fromURI: soundPath,
      codec: Codec.aacADTS,
      whenFinished: () {
        completer.complete();
      },
    ).catchError((error) {
      print('Error playing completion sound: $error');
      completer.complete();
    });
    return completer.future;
  }

  void _finishActivity() {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context, listen: false);
    runningActivityProvider.setRunningActivity(false, index: null);
    Navigator.pop(context); // Navigate back to the previous screen
    WakelockPlus.disable(); // Disable wakelock when activity ends
  }

  int _getTotalTasks() {
    final activitiesProvider = Provider.of<ActivitiesProvider>(context, listen: false);
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context, listen: false);
    final activity = activitiesProvider.activities[runningActivityProvider.runningActivityIndex!];
    return activity.tasks.length;
  }

  void _stopCountdown() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _continueCountdown() {
    setState(() {
      _isRunning = true;
    });
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context);
    final activitiesProvider = Provider.of<ActivitiesProvider>(context);

    if (runningActivityProvider.runningActivityIndex == null) return Container();

    final activity = activitiesProvider.activities[runningActivityProvider.runningActivityIndex!];
    final task = activity.tasks[_currentTaskIndex];

    return WillPopScope(
      onWillPop: () async {
        _finishActivity();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: () {
              _finishActivity();
            },
            child: Text('Running Activity'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                task.name,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ProgressBar(
                progress: progress,
                duration: Duration(seconds: _remainingTime),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isRunning ? _stopCountdown : _continueCountdown,
                child: Text(_isRunning ? '||' : '▶'),
              ),
              // Add other UI elements here
            ],
          ),
        ),
      ),
    );
  }
}
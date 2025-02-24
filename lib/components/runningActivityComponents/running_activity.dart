import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../hooks/activities_provider.dart';
import '../../hooks/running_activity_provider.dart';
import 'dart:async';

class RunningActivity extends StatefulWidget {
  @override
  _RunningActivityState createState() => _RunningActivityState();
}

class _RunningActivityState extends State<RunningActivity> {
  FlutterSoundPlayer? _player;
  int _currentTaskIndex = 0;
  int _remainingTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _player!.openPlayer().then((_) {
      _startNextTask();
    });
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _player = null;
    _timer?.cancel();
    super.dispose();
  }

  Future<String> _loadAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_sound.wav');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return tempFile.path;
  }

  void _startNextTask() async {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context, listen: false);
    final activitiesProvider = Provider.of<ActivitiesProvider>(context, listen: false);

    if (runningActivityProvider.runningActivityIndex == null) return;

    final activity = activitiesProvider.activities[runningActivityProvider.runningActivityIndex!];
    if (_currentTaskIndex >= activity.tasks.length) {
      runningActivityProvider.setRunningActivity(false, index: null);
      Navigator.pop(context); // Navigate back to the previous screen
      return;
    }

    final task = activity.tasks[_currentTaskIndex];
    _remainingTime = task.durationInSeconds;

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
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
          _playCompletionSound();
        }
      });
    });
  }

  void _playCompletionSound() async {
    final soundFilePath = await _loadAsset('assets/sounds/dixie_horn.wav');
    _player!.startPlayer(
      fromURI: soundFilePath,
      codec: Codec.pcm16WAV,
      whenFinished: () {
        _currentTaskIndex++;
        _startNextTask();
      },
    ).catchError((error) {
      print('Error playing completion sound: $error');
      _currentTaskIndex++;
      _startNextTask();
    });
  }

  @override
  Widget build(BuildContext context) {
    final runningActivityProvider = Provider.of<RunningActivityProvider>(context);
    final activitiesProvider = Provider.of<ActivitiesProvider>(context);

    if (runningActivityProvider.runningActivityIndex == null) return Container();

    final activity = activitiesProvider.activities[runningActivityProvider.runningActivityIndex!];
    final task = activity.tasks[_currentTaskIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Running Activity'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Task: ${task.name}',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0),
            Text(
              'Remaining Time: $_remainingTime seconds',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
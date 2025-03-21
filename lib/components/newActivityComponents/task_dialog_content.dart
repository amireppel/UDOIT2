import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../hooks/new_activity_provider.dart';
import '../../hooks/activities_provider.dart'; // Import the file where Task is defined

class AddTaskDialogContent extends StatefulWidget {
  final TextEditingController taskNameController;
  final TextEditingController taskDurationController;
  final NewActivityProvider newActivityProvider;
  final Task? editingTask;

  const AddTaskDialogContent({
    super.key,
    required this.taskNameController,
    required this.taskDurationController,
    required this.newActivityProvider,
    this.editingTask,
  });

  @override
  _AddTaskDialogContentState createState() => _AddTaskDialogContentState();
}

class _AddTaskDialogContentState extends State<AddTaskDialogContent> {
  String? errorMessage;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
    _recordedFilePath = widget.editingTask?.soundFile;
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    if (await Permission.microphone.request().isGranted) {
      // Microphone permission granted
    } else {
      // Microphone permission denied
    }
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.aac';
    String tempPath = '${tempDir.path}/$uniqueFileName';
    await _recorder!.startRecorder(toFile: tempPath, codec: Codec.aacADTS);
    setState(() {
      _isRecording = true;
      _recordedFilePath = tempPath;
    });

    // Stop recording after 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      if (_isRecording) {
        _stopRecording();
      }
    });
  }

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> _playRecording() async {
    if (_recordedFilePath != null) {
      await _player!.startPlayer(
        fromURI: _recordedFilePath,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
          });
        },
      );
      setState(() {
        _isPlaying = true;
      });
    }
  }

  Future<void> _stopPlaying() async {
    await _player!.stopPlayer();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    _recorder = null;
    _player = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.taskNameController,
            decoration: InputDecoration(labelText: 'Task Name'),
          ),
          TextField(
            controller: widget.taskDurationController,
            decoration: InputDecoration(labelText: 'Duration (seconds)'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                4,
              ), // Limit input length to 4 digits
            ],
          ),
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(errorMessage!, style: TextStyle(color: Colors.red)),
            ),
          SizedBox(
            height: 15,
          ), //Add space between the duration input and the record button
          ElevatedButton(
            onPressed: _isRecording ? null : _startRecording,
            child: Text(_isRecording ? 'Recording...' : 'Record Voice Message'),
          ),
          if (_isRecording)
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Finish Recording'),
            ),
          if (!_isRecording && _recordedFilePath != null)
            ElevatedButton(
              onPressed: _isPlaying ? _stopPlaying : _playRecording,
              child: Text(_isPlaying ? 'Stop Playing' : 'Play Recording'),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.newActivityProvider.clearEditingTask();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final taskName = widget.taskNameController.text;
                  final taskDuration =
                      int.tryParse(widget.taskDurationController.text) ?? -1;
                  if (taskName.isEmpty) {
                    setState(() {
                      errorMessage = 'Please enter a name';
                    });
                  } else if (taskDuration < 0 || taskDuration > 1000) {
                    setState(() {
                      errorMessage =
                          'Please enter a valid duration between 0 and 1000 seconds';
                    });
                  } else {
                    final newTask = Task(
                      name: taskName,
                      durationInSeconds: taskDuration,
                      soundFile: _recordedFilePath ?? '',
                    );
                    widget.newActivityProvider.addTask(newTask);
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.editingTask == null ? 'Add' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

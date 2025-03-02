import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer'; // Import the developer package for logging
import 'package:flutter_sound/flutter_sound.dart';
import '../hooks/new_activity_provider.dart';
import '../hooks/activities_provider.dart';
import './newActivityComponents/show_add_task_dialog.dart';

class NewActivity extends StatefulWidget {
  final VoidCallback onSaveActivity;

  NewActivity({required this.onSaveActivity});

  @override
  _NewActivityState createState() => _NewActivityState();
}

class _NewActivityState extends State<NewActivity> {
  FlutterSoundPlayer? _player;
  String? _currentlyPlaying;
  late TextEditingController _activityNameController;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
    _activityNameController = TextEditingController();
    _activityNameController.addListener(() {
      Provider.of<NewActivityProvider>(context, listen: false)
          .updateActivityName(_activityNameController.text);
    });
  }

  @override
  void dispose() {
    _player!.closePlayer();
    _player = null;
    _activityNameController.dispose();
    super.dispose();
  }

  Future<void> _playRecording(String filePath) async {
    await _player!.startPlayer(
      fromURI: filePath,
      codec: Codec.aacADTS,
      whenFinished: () {
        setState(() {
          _currentlyPlaying = null;
        });
      },
    );
    setState(() {
      _currentlyPlaying = filePath;
    });
  }

  Future<void> _stopPlaying() async {
    await _player!.stopPlayer();
    setState(() {
      _currentlyPlaying = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewActivityProvider, ActivitiesProvider>(
      builder: (context, newActivityProvider, activitiesProvider, child) {
        if (_activityNameController.text != newActivityProvider.activityName) {
          _activityNameController.text = newActivityProvider.activityName;
        }
        return WillPopScope(
          onWillPop: () async {
            newActivityProvider.stopEditingActivity();
            Navigator.pop(context);
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(newActivityProvider.editingActivityIndex != null
                  ? 'Edit Activity'
                  : 'Create New Activity'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Activity Name'),
                    controller: _activityNameController,
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: newActivityProvider.tasks.length,
                      itemBuilder: (context, index) {
                        final task = newActivityProvider.tasks[index];
                        return ListTile(
                          title: Text(task.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Duration: ${task.durationInSeconds} seconds'),
                              if (task.soundFile.isNotEmpty)
                                ElevatedButton(
                                  onPressed: _currentlyPlaying == task.soundFile
                                      ? _stopPlaying
                                      : () => _playRecording(task.soundFile),
                                  child: Text(_currentlyPlaying == task.soundFile
                                      ? 'Stop Playing'
                                      : 'Play Recording'),
                                ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              newActivityProvider.editTask(task);
                              showAddTaskDialog(context, newActivityProvider, task: task);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder(
                    valueListenable: newActivityProvider.activityNameNotifier,
                    builder: (context, activityName, child) {
                      return activityName.isNotEmpty
                          ? ElevatedButton(
                              onPressed: () {
                                showAddTaskDialog(context, newActivityProvider);
                              },
                              child: Text('Add Task'),
                            )
                          : Container();
                    },
                  ),
                  SizedBox(height: 16.0),
                  ValueListenableBuilder(
                    valueListenable: newActivityProvider.tasksNotifier,
                    builder: (context, tasks, child) {
                      return tasks.isNotEmpty
                          ? ElevatedButton(
                              onPressed: () {
                                final newActivity = Activity(
                                  name: newActivityProvider.activityName,
                                  tasks: List<Task>.from(newActivityProvider.tasks),
                                );
                                if (newActivityProvider.editingActivityIndex != null) {
                                  activitiesProvider.updateActivity(
                                    newActivityProvider.editingActivityIndex!,
                                    newActivity,
                                  );
                                  newActivityProvider.stopEditingActivity();
                                } else {
                                  activitiesProvider.addActivity(newActivity);
                                }
                                newActivityProvider.updateActivityName('');
                                newActivityProvider.clearTasks();
                                widget.onSaveActivity();
                              },
                              child: Text('Save Activity'),
                            )
                          : Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
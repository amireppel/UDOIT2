import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:developer'; // Import the developer package for logging
import '../hooks/new_activity_provider.dart';
import '../hooks/activities_provider.dart';
import './newActivityComponents/show_add_task_dialog.dart';

class NewActivity extends StatelessWidget {
  final VoidCallback onSaveActivity;

  NewActivity({required this.onSaveActivity});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NewActivityProvider, ActivitiesProvider>(
      builder: (context, newActivityProvider, activitiesProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Create New Activity'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(labelText: 'Activity Name'),
                  onChanged: (value) {
                    newActivityProvider.updateActivityName(value);
                  },
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: newActivityProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = newActivityProvider.tasks[index];
                      return ListTile(
                        title: Text(task.name),
                        subtitle: Text('Duration: ${task.durationInSeconds} seconds'),
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
                                tasks:  List<Task>.from(newActivityProvider.tasks),
                              );
                              // Log the activity details
                             for (var task in newActivity.tasks) {
                                print('Task Name: ${task.name}, Duration: ${task.durationInSeconds} seconds');
                              }
                              activitiesProvider.addActivity(newActivity);
                              newActivityProvider.updateActivityName('');
                              newActivityProvider.clearTasks();
                              onSaveActivity();
                            },
                            child: Text('Save Activity'),
                          )
                        : Container();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
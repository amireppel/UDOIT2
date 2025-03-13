import 'package:flutter/material.dart';
import '../../hooks/new_activity_provider.dart';
import '../../hooks/activities_provider.dart'; // Import the file where Task is defined
import './task_dialog_content.dart'; // Import the AddTaskDialogContent class

void showAddTaskDialog(
  BuildContext context,
  NewActivityProvider newActivityProvider, {
  Task? task,
}) {
  final taskNameController = TextEditingController(text: task?.name ?? '');
  final taskDurationController = TextEditingController(
    text: task?.durationInSeconds.toString() ?? '',
  );

  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing the dialog by tapping outside
    builder: (context) {
      return AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: AddTaskDialogContent(
          taskNameController: taskNameController,
          taskDurationController: taskDurationController,
          newActivityProvider: newActivityProvider,
          editingTask: task,
        ),
        contentPadding: EdgeInsets.all(16.0),
      );
    },
  );
}

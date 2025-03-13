import 'package:flutter/material.dart';
import 'dart:io';
import '../../hooks/new_activity_provider.dart';
import '../../hooks/activities_provider.dart'; // Import Task from activities_provider.dart

void showCopyTaskDialog(
  BuildContext context,
  NewActivityProvider newActivityProvider,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      Task? selectedTask;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Select a Task to Copy'),
            content: SizedBox(
              width: double.maxFinite,
              height: 200.0, // Set a fixed height for the list
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: newActivityProvider.tasks.length,
                itemBuilder: (BuildContext context, int index) {
                  final task = newActivityProvider.tasks[index];
                  return RadioListTile<Task>(
                    title: Text(task.name),
                    value: task,
                    groupValue: selectedTask,
                    onChanged: (Task? value) {
                      setState(() {
                        selectedTask = value;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  if (selectedTask != null) {
                    String? copiedSoundFile;
                    if (selectedTask!.soundFile.isNotEmpty) {
                      final originalFile = File(selectedTask!.soundFile);
                      final copiedFile = File(
                        '${selectedTask!.soundFile}_copy',
                      );
                      await originalFile.copy(copiedFile.path);
                      copiedSoundFile = copiedFile.path;
                    }

                    final copiedTask = Task(
                      name: selectedTask!.name,
                      durationInSeconds: selectedTask!.durationInSeconds,
                      soundFile: copiedSoundFile ?? '',
                    );
                    newActivityProvider.addTask(copiedTask);
                    Navigator.of(context).pop();
                  }
                },
                child: Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}

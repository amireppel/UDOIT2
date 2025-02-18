import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hooks/activities_provider.dart';
import '../hooks/running_activity_provider.dart';
import 'activitiesComponents/new_activity_button.dart';

class ActivitiesList extends StatelessWidget {
  final VoidCallback onNewActivityPressed;

  ActivitiesList({required this.onNewActivityPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ActivitiesProvider, RunningActivityProvider>(
      builder: (context, activitiesProvider, runningActivityProvider, child) {
        return Column(
          children: [
            NewActivityButton(onPressed: onNewActivityPressed),
            SwitchListTile(
              title: Text('Is Running Activity'),
              value: runningActivityProvider.isRunningActivity,
              onChanged: (bool value) {
                runningActivityProvider.setRunningActivity(value);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: activitiesProvider.activities.length,
                itemBuilder: (context, index) {
                  final activity = activitiesProvider.activities[index];
                  return ListTile(
                    title: Text(activity.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: activity.tasks.map((task) {
                        return Text('${task.name} - ${task.durationInSeconds} seconds');
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NewActivityButton(onPressed: onNewActivityPressed),
            ),
            SwitchListTile(
              title: Text(
                'Is Running Activity',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              value: runningActivityProvider.isRunningActivity,
              onChanged: (bool value) {
                runningActivityProvider.setRunningActivity(value);
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: activitiesProvider.activities.map((activity) {
                    final totalTime = activity.tasks.fold(0, (total, task) => total + task.durationInSeconds);
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(
                          activity.name,
                          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 8.0),
                            Text(
                              'Total Time: $totalTime seconds',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.arrow_forward_ios),
                            SizedBox(width: 4.0),
                            Text('play'),
                          ],
                        ),
                        onTap: () {
                          // Handle activity tap
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
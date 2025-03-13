import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hooks/activities_provider.dart';
import '../hooks/running_activity_provider.dart';
import '../hooks/settings_provider.dart';
import '../hooks/new_activity_provider.dart';
import 'activitiesComponents/new_activity_button.dart';
import 'runningActivityComponents/running_activity.dart';
import 'runningActivityComponents/loop_count_modal.dart';
import 'new_activity.dart';

class ActivitiesList extends StatelessWidget {
  final VoidCallback onNewActivityPressed;

  const ActivitiesList({super.key, required this.onNewActivityPressed});

  @override
  Widget build(BuildContext context) {
    return Consumer4<
      ActivitiesProvider,
      RunningActivityProvider,
      SettingsProvider,
      NewActivityProvider
    >(
      builder: (
        context,
        activitiesProvider,
        runningActivityProvider,
        settingsProvider,
        newActivityProvider,
        child,
      ) {
        return Column(
          children: [
            if (!runningActivityProvider.isRunningActivity)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: NewActivityButton(onPressed: onNewActivityPressed),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Your activities',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ),
            if (runningActivityProvider.isRunningActivity &&
                runningActivityProvider.runningActivityIndex != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Running!!! ${activitiesProvider.activities[runningActivityProvider.runningActivityIndex!].name}',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        activitiesProvider.activities.map((activity) {
                          final totalTime = activity.tasks.fold(
                            0,
                            (total, task) => total + task.durationInSeconds,
                          );
                          final activityIndex = activitiesProvider.activities
                              .indexOf(activity);
                          return Card(
                            margin: EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10.0),
                              title: Text(
                                activity.name,
                                style: TextStyle(
                                  fontSize: 18.0,

                                  fontWeight: FontWeight.bold,
                                ),
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
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => LoopCountModal(
                                              onProceed: (loopCount) {
                                                runningActivityProvider
                                                    .setRunningActivity(
                                                      true,
                                                      index: activityIndex,
                                                    );
                                                Navigator.of(
                                                  context,
                                                  rootNavigator: true,
                                                ).pop(); // Close the modal
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            RunningActivity(
                                                              loopCount:
                                                                  loopCount,
                                                            ),
                                                  ),
                                                );
                                              },
                                            ),
                                      );
                                    },
                                    child: Text('Loop'),
                                  ),
                                  SizedBox(width: 8.0),
                                  ElevatedButton(
                                    onPressed:
                                        runningActivityProvider
                                                .isRunningActivity
                                            ? null
                                            : () {
                                              runningActivityProvider
                                                  .setRunningActivity(
                                                    true,
                                                    index: activityIndex,
                                                  );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          RunningActivity(
                                                            loopCount: null,
                                                          ),
                                                ),
                                              );
                                            },
                                    child: Text('Play'),
                                  ),
                                  SizedBox(width: 8.0),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      newActivityProvider.startEditingActivity(
                                        activityIndex,
                                        activity,
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => NewActivity(
                                                onSaveActivity: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                        ),
                                      );
                                    },
                                  ),
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

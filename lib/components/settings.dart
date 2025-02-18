import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hooks/running_activity_provider.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RunningActivityProvider>(
      builder: (context, runningActivityProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Settings Screen'),
            ],
          ),
        );
      },
    );
  }
}
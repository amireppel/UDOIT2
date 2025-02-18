import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hooks/new_activity_provider.dart';

class NewActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewActivityProvider>(
      builder: (context, newActivityProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('New Activity Screen'),
              TextField(
                decoration: InputDecoration(labelText: 'Activity Name'),
                onChanged: (text) {
                  newActivityProvider.updateActivityName(text);
                },
              ),
              // Add more widgets here as needed
            ],
          ),
        );
      },
    );
  }
}
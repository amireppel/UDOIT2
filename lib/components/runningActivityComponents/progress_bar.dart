import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Duration duration;

  ProgressBar({required this.progress, required this.duration});

  String getFormattedTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 40, // Thicker progress bar
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(20), // Rounded corners
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20), // Rounded corners
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ),
        Text(
          getFormattedTime(duration),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
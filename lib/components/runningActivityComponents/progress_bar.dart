import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Duration duration;

  const ProgressBar({super.key, required this.progress, required this.duration});

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
        SizedBox(
          height: 200,
          width: 200,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                strokeWidth: 14.0,
              );
            },
          ),
        ),
        Text(
          getFormattedTime(duration),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
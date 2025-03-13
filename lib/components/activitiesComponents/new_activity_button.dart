import 'package:flutter/material.dart';

class NewActivityButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewActivityButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text('New Activity'));
  }
}

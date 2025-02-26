import 'package:flutter/material.dart';

class LoopCountModal extends StatefulWidget {
  final Function(int) onProceed;

  LoopCountModal({required this.onProceed});

  @override
  _LoopCountModalState createState() => _LoopCountModalState();
}

class _LoopCountModalState extends State<LoopCountModal> {
  int _loopCount = 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Loop Count'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Enter the number of loops:'),
          SizedBox(height: 8.0),
          TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                _loopCount = int.tryParse(value) ?? 1;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '1',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onProceed(_loopCount);
          },
          child: Text('Proceed'),
        ),
      ],
    );
  }
}
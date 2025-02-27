import 'package:flutter/material.dart';
import '../../hooks/settings_provider.dart';

class SoundWheel extends StatelessWidget {
  final List<SoundFile> soundFiles;
  final int initialIndex;
  final ValueChanged<int> onSelectedItemChanged;

  SoundWheel({
    required this.soundFiles,
    required this.initialIndex,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Center(
              child: Text(soundFiles[index].name),
            );
          },
          childCount: soundFiles.length,
        ),
      ),
    );
  }
}

void showSoundWheel(BuildContext context, List<SoundFile> soundFiles, int initialIndex, ValueChanged<int> onSelectedItemChanged) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return SoundWheel(
        soundFiles: soundFiles,
        initialIndex: initialIndex,
        onSelectedItemChanged: onSelectedItemChanged,
      );
    },
  );
}
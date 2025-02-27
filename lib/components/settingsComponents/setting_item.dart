import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SettingItem extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? soundPath;
  final String? soundName;
  final TextStyle? textStyle;

  SettingItem({
    required this.title,
    required this.value,
    required this.onChanged,
    this.soundPath,
    this.soundName,
    this.textStyle,
  });

  Future<String> _loadAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/${assetPath.split('/').last}');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return tempFile.path;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(title, style: textStyle),
              ),
            ),
          ),
          if (soundPath != null)
            Row(
              children: [
                Text(soundName ?? ''),
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () async {
                    final player = FlutterSoundPlayer();
                    try {
                      await player.openPlayer();
                      String path = await _loadAsset(soundPath!);
                      await player.startPlayer(
                        fromURI: path,
                        whenFinished: () async {
                          await player.closePlayer();
                        },
                      );
                    } catch (e) {
                      print('Error playing sound: $e');
                      await player.closePlayer();
                    }
                  },
                ),
              ],
            ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
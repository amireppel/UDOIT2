import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../hooks/settings_provider.dart';
import 'settingsComponents/setting_item.dart';
import 'settingsComponents/sound_wheel.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _showSoundWheel = false;
  bool _isStartSoundWheel = false;

  void _toggleSoundWheel(bool isStartSound) {
    setState(() {
      if (_showSoundWheel && _isStartSoundWheel == isStartSound) {
        _showSoundWheel = false;
      } else {
        _showSoundWheel = true;
        _isStartSoundWheel = isStartSound;
      }
    });
  }

  void _closeSoundWheel() {
    setState(() {
      _showSoundWheel = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 50.0,
          ), // Adjust the top padding as needed
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Settings Screen'),
                TextButton(
                  onPressed: _closeSoundWheel,
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: SettingItem(
                    title: 'Play All',
                    value: settingsProvider.playAll,
                    onChanged: (bool value) {
                      settingsProvider.setPlayAll(value);
                    },
                    textStyle: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _toggleSoundWheel(true),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _showSoundWheel && _isStartSoundWheel
                            ? Colors.blue
                            : Colors.black,
                  ),
                  child: SettingItem(
                    title: 'Play Start Sound',
                    value: settingsProvider.playStartSound,
                    onChanged: (bool value) {
                      settingsProvider.setPlayStartSound(
                        value,
                        settingsProvider.startSoundFileIndex,
                      );
                    },
                    soundPath: settingsProvider.startSoundFile.path,
                    soundName: settingsProvider.startSoundFile.name,
                    textStyle: TextStyle(
                      color:
                          _showSoundWheel && _isStartSoundWheel
                              ? Colors.blue
                              : Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _toggleSoundWheel(false),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        _showSoundWheel && !_isStartSoundWheel
                            ? Colors.blue
                            : Colors.black,
                  ),
                  child: SettingItem(
                    title: 'Play End Sound',
                    value: settingsProvider.playEndSound,
                    onChanged: (bool value) {
                      settingsProvider.setPlayEndSound(
                        value,
                        settingsProvider.endSoundFileIndex,
                      );
                    },
                    soundPath: settingsProvider.endSoundFile.path,
                    soundName: settingsProvider.endSoundFile.name,
                    textStyle: TextStyle(
                      color:
                          _showSoundWheel && !_isStartSoundWheel
                              ? Colors.blue
                              : Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _closeSoundWheel,
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: SettingItem(
                    title: 'Play Recording',
                    value: settingsProvider.playRecording,
                    onChanged: (bool value) {
                      settingsProvider.setPlayRecording(value);
                    },
                    textStyle: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (_showSoundWheel)
                  SoundWheel(
                    soundFiles: settingsProvider.availableSoundFiles,
                    initialIndex:
                        _isStartSoundWheel
                            ? settingsProvider.startSoundFileIndex
                            : settingsProvider.endSoundFileIndex,
                    onSelectedItemChanged: (int index) {
                      if (_isStartSoundWheel) {
                        settingsProvider.setPlayStartSound(
                          settingsProvider.playStartSound,
                          index,
                        );
                      } else {
                        settingsProvider.setPlayEndSound(
                          settingsProvider.playEndSound,
                          index,
                        );
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

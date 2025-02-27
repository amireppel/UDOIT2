import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundFile {
  final String name;
  final String path;

  SoundFile(this.name, this.path);
}

class SettingsProvider with ChangeNotifier {
  bool _playAll = true;
  bool _playStartSound = true;
  int _startSoundFileIndex = 1;
  int get startSoundFileIndex => _startSoundFileIndex;
  bool _playEndSound = true;
  int _endSoundFileIndex = 1;
  int get endSoundFileIndex => _endSoundFileIndex;
  bool _playRecording = true;

  final List<SoundFile> _availableSoundFiles = [
    SoundFile('cheer', 'assets/sounds/cheer.wav'),
    SoundFile('dixie_horn', 'assets/sounds/dixie_horn.wav'),
    SoundFile('intro', 'assets/sounds/intro.wav'),
    SoundFile('meadow lark', 'assets/sounds/meadowlark.wav'),
    SoundFile('rooster', 'assets/sounds/rooster.wav'),
    SoundFile('service bell', 'assets/sounds/service_bell.wav'),
    SoundFile('sos morse', 'assets/sounds/sos.wav'),
    SoundFile('splash', 'assets/sounds/splash.wav'),
    SoundFile('timer', 'assets/sounds/timer.wav'),
    SoundFile('zen', 'assets/sounds/zen.wav'),
  ];

  SettingsProvider() {
    _loadSettings();
  }

  bool get playAll => _playAll;
  bool get playStartSound => _playStartSound;
  SoundFile get startSoundFile => _availableSoundFiles[_startSoundFileIndex];
  bool get playEndSound => _playEndSound;
  SoundFile get endSoundFile => _availableSoundFiles[_endSoundFileIndex];
  bool get playRecording => _playRecording;
  List<SoundFile> get availableSoundFiles => _availableSoundFiles;

  void setPlayAll(bool value) {
    _playAll = value;
    _playStartSound = value;
    _playEndSound = value;
    _playRecording = value;
    _saveSettings();
    notifyListeners();
  }

  void setPlayStartSound(bool value, int soundFileIndex) {
    _playStartSound = value;
    _startSoundFileIndex = soundFileIndex;
    _saveSettings();
    notifyListeners();
  }

  void setPlayEndSound(bool value, int soundFileIndex) {
    _playEndSound = value;
    _endSoundFileIndex = soundFileIndex;
    _saveSettings();
    notifyListeners();
  }

  void setPlayRecording(bool value) {
    _playRecording = value;
    _saveSettings();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('playAll', _playAll);
    prefs.setBool('playStartSound', _playStartSound);
    prefs.setInt('startSoundFileIndex', _startSoundFileIndex);
    prefs.setBool('playEndSound', _playEndSound);
    prefs.setInt('endSoundFileIndex', _endSoundFileIndex);
    prefs.setBool('playRecording', _playRecording);
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _playAll = prefs.getBool('playAll') ?? true;
    _playStartSound = prefs.getBool('playStartSound') ?? true;
    _startSoundFileIndex = prefs.getInt('startSoundFileIndex') ?? 0;
    _playEndSound = prefs.getBool('playEndSound') ?? true;
    _endSoundFileIndex = prefs.getInt('endSoundFileIndex') ?? 1;
    _playRecording = prefs.getBool('playRecording') ?? true;
    notifyListeners();
  }

  List<SoundFile> getAllSoundFiles() {
    return _availableSoundFiles;
  }
}
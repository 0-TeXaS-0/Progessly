import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _hapticsEnabled = true;

  static const String _soundEnabledKey = 'sound_enabled';
  static const String _hapticsEnabledKey = 'haptics_enabled';

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _hapticsEnabled = prefs.getBool(_hapticsEnabledKey) ?? true;
  }

  // Sound control
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    _hapticsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsEnabledKey, enabled);
  }

  bool get soundEnabled => _soundEnabled;
  bool get hapticsEnabled => _hapticsEnabled;

  // Play sounds using system beep (no assets needed)
  Future<void> playTaskComplete() async {
    if (!_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> playTaskDelete() async {
    if (!_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.lightImpact();
    }
  }

  Future<void> playHabitComplete() async {
    if (!_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> playWaterLog() async {
    if (!_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> playMealLog() async {
    if (!_soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.mediumImpact();
    }
  }

  Future<void> playStreakMilestone() async {
    if (!_soundEnabled) return;
    // Play a sequence for celebration
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> playRecordBroken() async {
    if (!_soundEnabled) return;
    // Play celebration sequence
    await SystemSound.play(SystemSoundType.click);
    if (_hapticsEnabled) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.heavyImpact();
    }
  }

  Future<void> playButtonTap() async {
    if (_hapticsEnabled) {
      await HapticFeedback.selectionClick();
    }
  }

  Future<void> playError() async {
    if (_hapticsEnabled) {
      await HapticFeedback.vibrate();
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

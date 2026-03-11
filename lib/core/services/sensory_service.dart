// lib/core/services/sensory_service.dart

import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class SensoryService {
  static final _player = AudioPlayer();

  static Future<void> success() async {
    await Haptics.vibrate(HapticsType.success);
    try {
      await _player.play(AssetSource('sounds/success_beep.mp3'));
    } catch (_) {}
  }

  static Future<void> light() async {
    await Haptics.vibrate(HapticsType.light);
    try {
      await _player.play(AssetSource('sounds/light_beep.mp3'));
    } catch (_) {}
  }

  static Future<void> heavy() async {
    await Haptics.vibrate(HapticsType.heavy);
    try {
      await _player.play(AssetSource('sounds/heavy_beep.mp3'));
    } catch (_) {}
  }

  static Future<void> error() async {
    await Haptics.vibrate(HapticsType.error);
    try {
      await _player.play(AssetSource('sounds/error_beep.mp3'));
    } catch (_) {}
  }
}

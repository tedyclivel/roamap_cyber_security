import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final _player = AudioPlayer();

  /// Joue un haptic de succès (tâche complétée).
  static Future<void> taskComplete() async {
    await HapticFeedback.lightImpact();
  }

  /// Joue un son + haptic de célébration (check-in, niveau up).
  static Future<void> celebrate() async {
    try {
      await HapticFeedback.mediumImpact();
      // On privilégie désormais le son HUD success généré
      await _player.play(AssetSource('sounds/ui_success.wav'), volume: 0.6);
    } catch (_) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Petit beep pour les interactions standard.
  static Future<void> playBeep() async {
    try {
      await _player.play(AssetSource('sounds/ui_beep.wav'), volume: 0.3);
    } catch (_) {}
  }

  /// Glitch pour les erreurs ou transitions.
  static Future<void> playGlitch() async {
    try {
      await _player.play(AssetSource('sounds/ui_glitch.wav'), volume: 0.3);
    } catch (_) {}
  }

  /// Haptic écran check-in validé.
  static Future<void> checkIn() async {
    await HapticFeedback.heavyImpact();
    await playSuccess();
  }

  static Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('sounds/ui_success.wav'), volume: 0.5);
    } catch (_) {}
  }

  /// Dispose les ressources.
  static void dispose() => _player.dispose();
}

// lib/src/core/services/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memory_color/src/core/const.dart';

class SoundManager {
  final AudioPlayer _audioPlayer = AudioPlayer();

  void playSoundForColor(Color color) {
    final soundFile = colorSoundMap[color];
    if (soundFile != null) {
      _audioPlayer.play(AssetSource('sounds/$soundFile'));
    }
  }

  void playSoundForAction(String? actionSoud) {
    if (actionSoud != null && actionSoud != "") {
      _audioPlayer.play(AssetSource('sounds/$actionSoud.wav'));
    }
  }

  void disposePlay() {
    _audioPlayer.dispose();
  }
}

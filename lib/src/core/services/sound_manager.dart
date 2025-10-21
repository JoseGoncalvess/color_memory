// lib/src/core/services/sound_manager.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memory_color/src/core/helpers/const.dart';

class SoundManager {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future playSoundForColor(Color color) async {
    final soundFile = colorSoundMap[color];
    if (soundFile != null) {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    }
    await Future.delayed(Duration(milliseconds: 300));
  }

  Future playSoundForAction(String? actionSoud) async {
    if (actionSoud != null && actionSoud != "") {
      await _audioPlayer.play(AssetSource('sounds/$actionSoud.wav'));
    }
  }

  void disposePlay() {
    _audioPlayer.dispose();
  }
}

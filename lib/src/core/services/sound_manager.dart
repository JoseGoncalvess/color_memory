import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:material_ui/material_ui.dart';
import 'package:memory_color/src/core/helpers/const.dart';

class SoundManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Future<void> _pending = Future<void>.value();

  Future<void> playSoundForColor(Color color, {double playbackRate = 1.0}) {
    final soundFile = colorSoundMap[color];
    return soundFile == null ? Future<void>.value() : _play(soundFile, playbackRate: playbackRate);
  }

  Future<void> playSoundForAction(String? actionSound) {
    return actionSound == null || actionSound.isEmpty
        ? Future<void>.value()
        : _play('$actionSound.wav');
  }

  Future<void> _play(String soundFile, {double playbackRate = 1.0}) {
    final playback = _pending.then((_) async {
      final completed = Completer<void>();
      final subscription = _audioPlayer.onPlayerComplete.listen((_) {
        if (!completed.isCompleted) completed.complete();
      });
      try {
        await _audioPlayer.setPlaybackRate(playbackRate);
        await _audioPlayer.play(AssetSource('sounds/$soundFile'));
        await completed.future;
      } finally {
        await subscription.cancel();
      }
    });
    // Keep the queue usable if an asset or audio device fails.
    _pending = playback.catchError((Object error, StackTrace stack) {
      debugPrint('Não foi possível reproduzir $soundFile: $error');
    });
    return _pending;
  }

  void disposePlay() {
    _audioPlayer.dispose();
  }
}

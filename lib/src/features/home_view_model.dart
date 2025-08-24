import 'package:flutter/material.dart';
import 'package:memory_color/src/core/services/sound_manager.dart';

class HomeViewModel extends ChangeNotifier {
  final BuildContext context;
  final SoundManager _soundManager;

  HomeViewModel(this.context, this._soundManager);
  void pressedPLay() {
    _soundManager.playSoundForAction("click");
  }

  void navigateToGame(int numberOfColors) {
    _soundManager.playSoundForAction("click");
    Navigator.of(context).pushNamed('/game', arguments: numberOfColors);
  }

  void navigateToScore() {
    _soundManager.playSoundForAction("click");
    Navigator.of(context).pushNamed('/score');
  }
}

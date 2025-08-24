import 'package:flutter/material.dart';
import 'package:memory_color/src/core/enum/game_state.dart';
import 'package:memory_color/src/core/const.dart';
import 'package:memory_color/src/core/services/score_manager.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/core/services/sound_manager.dart';
import 'package:memory_color/src/core/services/vibrator_manager.dart';
import 'dart:math';

class GameViewModel extends ChangeNotifier {
  final BuildContext context;
  final _random = Random();
  final SoundManager _soundManager; // Referência para o SoundManager
  final VibratorManager _vibratorManager; // Referência para o VibratorManager
  final SettingsManager _settingsManager; // Referência para o SettingsManager
  final ScoreManager _scoreManager;

  GameViewModel(
    this.context,
    this._numberOfColors,
    this._soundManager,
    this._vibratorManager,
    this._settingsManager,
    this._scoreManager,
  );

  int _score = 0;
  Color? _activeColor;
  Color? _playerActiveColor;

  Color? get playerActiveColor => _playerActiveColor;
  Color? get activeColor => _activeColor;
  List<Color> _gameSequence = [];
  List<Color> _playerSequence = [];
  GameState _gameState = GameState.initForGame;

  int get score => _score;
  List<Color> get gameSequence => _gameSequence;
  GameState get gameState => _gameState;
  List<Color> get gameColors => _gameColors;

  final int _numberOfColors;
  List<Color> get _gameColors => allGameColors.sublist(0, _numberOfColors);

  void startGame() {
    _score = 0;
    _gameSequence.clear();
    _playerSequence.clear();
    _gameState = GameState.showingSequence;
    _addNewColorToSequence();
    notifyListeners();
  }

  Future _showSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));

    for (var color in gameSequence) {
      _activeColor = color;
      if (_settingsManager.isSoundEnabled) {
        _soundManager.playSoundForColor(color);
      }
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
      _activeColor = null;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    _gameState = GameState.waitingForPlayer;
    notifyListeners();
  }

  void _addNewColorToSequence() async {
    final newColor = _gameColors[_random.nextInt(_gameColors.length)];
    _gameSequence.add(newColor);
    _showSequence();
  }

  void handlePlayerTap(Color color) async {
    if (_gameState != GameState.waitingForPlayer) {
      return;
    }
    if (_settingsManager.isSoundEnabled) {
      _soundManager.playSoundForColor(color);
    }
    if (_settingsManager.isVibrationEnabled) {
      _vibratorManager.vibrateTap();
    }

    _playerActiveColor = color;
    notifyListeners();

    _playerSequence.add(color);

    await Future.delayed(const Duration(milliseconds: 200));

    _playerActiveColor = null;
    notifyListeners();

    _checkPlayerInput();
  }

  void _checkPlayerInput() async {
    int currentTapIndex = _playerSequence.length - 1;

    if (_playerSequence[currentTapIndex] != _gameSequence[currentTapIndex]) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_settingsManager.isSoundEnabled) {
        _soundManager.playSoundForAction("gameOver");
      }

      if (_settingsManager.isVibrationEnabled) {
        _vibratorManager.vibrateError(); // Vibração de erro
      }

      _endGame();
      return;
    }

    if (_playerSequence.length == _gameSequence.length) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_settingsManager.isSoundEnabled) {
        _soundManager.playSoundForAction("win");
      }

      _score++;

      _playerSequence.clear();
      _gameState = GameState.showingSequence;
      notifyListeners();

      Future.delayed(const Duration(seconds: 1), () {
        _addNewColorToSequence();
      });
    }
  }

  void exitGame() {
    _gameState = GameState.gameOver;
    notifyListeners();
  }

  void _endGame() {
    _gameState = GameState.gameOver;
    _scoreManager.checkAndSaveHighScore(_score);
    notifyListeners();
  }

  // TODO: Adicionar lógica para animação e display da sequência.
  // Isso pode ser uma stream ou um Future.delayed.
  // Vamos pensar na melhor forma de fazer isso.
}

import 'package:material_ui/material_ui.dart';
import 'package:memory_color/src/core/enum/game_state.dart';
import 'package:memory_color/src/core/helpers/const.dart';
import 'package:memory_color/src/core/services/ad_manager.dart';
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
  final AdManager _adManager;

  GameViewModel(
    this.context,
    this._numberOfColors,
    this._soundManager,
    this._vibratorManager,
    this._settingsManager,
    this._scoreManager,
    this._adManager,
  );

  bool _disposed = false;
  bool _handlingTap = false;
  int _round = 0;
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
  bool get canAcceptTap => _gameState == GameState.waitingForPlayer && !_handlingTap;

  final int _numberOfColors;
  List<Color> get _gameColors => allGameColors.sublist(0, _numberOfColors);

  void startGame() {
    _round++;
    _handlingTap = false;
    _activeColor = null;
    _playerActiveColor = null;
    _score = 0;
    _gameSequence.clear();
    _playerSequence.clear();
    _gameState = GameState.showingSequence;
    _addNewColorToSequence();
    notifyListeners();
  }

  Future _showSequence() async {
    final round = _round;
    final isFastSequence = _gameSequence.length > 10;
    final speed = isFastSequence ? _settingsManager.sequenceSpeed : 1.0;
    _gameState = GameState.showingSequence;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));

    if (_disposed || round != _round) return;
    for (var color in List<Color>.of(gameSequence)) {
      if (_disposed || round != _round) return;
      _activeColor = color;
      notifyListeners();
      if (_settingsManager.isSoundEnabled) {
        await _soundManager.playSoundForColor(
          color, playbackRate: speed,
        );
      } else {
        await _vibratorManager.vibrateToShow();
        await Future.delayed(Duration(milliseconds: isFastSequence ? (800 / speed).round() : 800));
      }
      if (_disposed || round != _round) return;
      _activeColor = null;
      notifyListeners();
      await Future.delayed(Duration(milliseconds: isFastSequence ? (525 / speed).round() : 1000));
    }
    if (_disposed || round != _round) return;
    _gameState = GameState.waitingForPlayer;
    notifyListeners();
  }

  void _addNewColorToSequence() async {
    final newColor = _gameColors[_random.nextInt(_gameColors.length)];
    _gameSequence.add(newColor);
    _showSequence();
  }

  void handlePlayerTap(Color color) {
    if (!canAcceptTap) return;
    _handlingTap = true;
    final round = _round;
    _playerSequence.add(color);
    _playerActiveColor = color;
    notifyListeners();
    if (_settingsManager.isVibrationEnabled) {
      _vibratorManager.vibrateTap();
    }
    _finishPlayerTap(color, round);
  }

  Future<void> _finishPlayerTap(Color color, int round) async {
    if (_settingsManager.isSoundEnabled) {
      await _soundManager.playSoundForColor(color);
    } else {
      await Future.delayed(const Duration(milliseconds: 200));
    }
    if (_disposed || round != _round) return;
    _playerActiveColor = null;
    await _checkPlayerInput();
    if (_disposed || round != _round) return;
    _handlingTap = false;
    notifyListeners();
  }

  Future<void> _checkPlayerInput() async {
    final round = _round;
    int currentTapIndex = _playerSequence.length - 1;

    if (_playerSequence[currentTapIndex] != _gameSequence[currentTapIndex]) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_disposed || round != _round) return;
      if (_settingsManager.isSoundEnabled) {
        await _soundManager.playSoundForAction("gameOver");
        if (_disposed || round != _round) return;
      }

      _endGame();
      return;
    }

    if (_playerSequence.length == _gameSequence.length) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_disposed || round != _round) return;
      if (_settingsManager.isSoundEnabled) {
        await _soundManager.playSoundForAction("win");
        if (_disposed || round != _round) return;
      }

      _score++;

      _playerSequence.clear();
      _gameState = GameState.showingSequence;
      notifyListeners();

      Future.delayed(const Duration(seconds: 1), () {
        if (!_disposed && round == _round) _addNewColorToSequence();
      });
    }
  }

  void exitGame() {
    _round++;
    _gameState = GameState.gameOver;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _round++;
    super.dispose();
  }

  void _endGame() {
    _gameState = GameState.gameOver;
    _scoreManager.saveGame(_score, _numberOfColors);

    if (_settingsManager.isVibrationEnabled) {
      _vibratorManager.vibrateError();
    }

    bool previewAd = _settingsManager.adPresentView();
    if (previewAd) {
      _adManager.showInterstitialAd();
    }

    notifyListeners();
  }
}

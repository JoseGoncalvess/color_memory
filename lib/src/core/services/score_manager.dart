import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  const ScoreEntry(this.score, this.colors, this.playedAt);
  final int score;
  final int colors;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => {
    'score': score, 'colors': colors, 'playedAt': playedAt.toIso8601String(),
  };
}

class ScoreManager extends ChangeNotifier {
  static const _highScoreKey = 'high_score';
  static const _historyKey = 'score_history_v1';
  int _highScore = 0;
  final List<ScoreEntry> _history = [];
  late SharedPreferences _prefs;

  int get highScore => _highScore;
  List<ScoreEntry> get history => List.unmodifiable(_history);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _highScore = _prefs.getInt(_highScoreKey) ?? 0;
    for (final raw in _prefs.getStringList(_historyKey) ?? <String>[]) {
      try {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        _history.add(ScoreEntry(data['score'] as int, data['colors'] as int,
            DateTime.parse(data['playedAt'] as String)));
      } catch (_) {
        // Ignore a damaged entry without losing the remaining history.
      }
    }
    notifyListeners();
  }

  Future<void> saveGame(int score, int colors) async {
    if (score <= 0) return;
    _history.insert(0, ScoreEntry(score, colors, DateTime.now()));
    if (_history.length > 20) _history.removeRange(20, _history.length);
    if (score > _highScore) {
      _highScore = score;
      await _prefs.setInt(_highScoreKey, score);
    }
    await _prefs.setStringList(_historyKey,
        _history.map((entry) => jsonEncode(entry.toJson())).toList());
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:memory_color/src/core/services/score_manager.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/core/services/sound_manager.dart';
import 'package:memory_color/src/core/services/vibrator_manager.dart';
import 'package:memory_color/src/core/theme/app_themes.dart';
import 'package:memory_color/src/core/theme/theme_manager.dart';
import 'package:memory_color/src/features/game/game_view.dart';
import 'package:memory_color/src/features/game/game_view_model.dart';
import 'package:memory_color/src/features/home_view.dart';
import 'package:memory_color/src/features/home_view_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final soundManager = SoundManager();
  final settingsManager = SettingsManager();
  await settingsManager.init();
  final vibratorManager = VibratorManager(settingsManager);
  final scoreManager = ScoreManager();
  await scoreManager.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider.value(value: settingsManager),
        ChangeNotifierProvider.value(value: scoreManager),
      ],

      child: MainApp(
        soundManager: soundManager,
        vibratorManager: vibratorManager,
      ),
    ),
  );
}

class MainApp extends StatelessWidget {
  final SoundManager soundManager;
  final VibratorManager vibratorManager;
  const MainApp({
    super.key,
    required this.soundManager,
    required this.vibratorManager,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeManager>(
      builder: (context, themeManager, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Memória Colorida",
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeManager.themeMode,
        routes: {
          '/': (context) => ChangeNotifierProvider(
            create: (context) => HomeViewModel(context, soundManager),
            child: HomeView(),
          ),
          '/game': (context) {
            final arguments = ModalRoute.of(context)?.settings.arguments;
            final numberOfColors = (arguments is int) ? arguments : 4;

            return ChangeNotifierProvider(
              create: (context) => GameViewModel(
                context,
                numberOfColors,
                soundManager,
                vibratorManager,
                Provider.of<SettingsManager>(context, listen: false),
                Provider.of<ScoreManager>(context, listen: false),
              ),
              child: GameView(),
            );
          },
        },
        initialRoute: '/',
      ),
    );
  }
}

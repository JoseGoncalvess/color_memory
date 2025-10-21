import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_color/src/core/helpers/ad_helper.dart';
import 'package:memory_color/src/core/services/score_manager.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/core/theme/theme_manager.dart';
import 'package:memory_color/src/features/home_view_model.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<HomeViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Memory'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<ScoreManager>(
              builder: (context, scoreManager, child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Recorde: ${scoreManager.highScore}',
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () => {
                  viewModel.pressedPLay(),
                  _showDifficultyDialog(context),
                },

                child: const Text('Jogar'),
              ),
            ),
          ],
        ),
      ),
      // BANER AD
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: AdWidget(
            ad: BannerAd(
              adUnitId:
                  AdHelper.bannerAdUnitId, // Usa o ID de teste do seu helper
              size: AdSize.banner,
              request: const AdRequest(),
              listener: const BannerAdListener(),
            )..load(),
          ),
        ),
      ),
    );
  }
}

void _showDifficultyDialog(BuildContext context) {
  final homeViewModel = Provider.of<HomeViewModel>(context, listen: false);
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Escolha a Dificuldade', textAlign: TextAlign.center),
        alignment: Alignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                // Passamos 4 cores para a navegação
                homeViewModel.navigateToGame(4);
              },
              child: const Text('Fácil (4 cores)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                // Passamos 8 cores para a navegação
                homeViewModel.navigateToGame(8);
              },
              child: const Text('Médio (8 cores)'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                // Passamos 10 cores para a navegação
                homeViewModel.navigateToGame(12);
              },
              child: const Text('Difícil (12 cores)'),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildSettingSwitch(
  BuildContext context,
  String title,
  bool value,
  VoidCallback onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Switch(
          value: value,
          onChanged: (val) => onChanged(),
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    ),
  );
}

void _showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Configurações', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<SettingsManager>(
              builder: (context, sManager, child) => _buildSettingSwitch(
                context,
                'Sons',
                sManager.isSoundEnabled,
                sManager.toggleSound,
              ),
            ),
            Consumer<SettingsManager>(
              builder: (context, sManager, child) => _buildSettingSwitch(
                context,
                'Vibração',
                sManager.isVibrationEnabled,
                sManager.toggleVibration,
              ),
            ),

            const SizedBox(height: 16),
            Consumer<ThemeManager>(
              builder: (context, tManager, child) =>
                  _buildThemeButton(tManager),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildThemeButton(ThemeManager themeManager) {
  final bool isDark = themeManager.themeMode == ThemeMode.dark;
  return ElevatedButton(
    onPressed: () {
      themeManager.toggleTheme(!isDark);
    },
    child: Text(isDark ? 'Modo Claro' : 'Modo Escuro'),
  );
}

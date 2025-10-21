// lib/src/features/game/game_view.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:memory_color/src/core/enum/game_state.dart';
import 'package:memory_color/src/core/helpers/ad_helper.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/features/game/game_view_model.dart';
import 'package:provider/provider.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameViewModel>(
      builder: (context, viewModel, child) {
        return PopScope(
          canPop:
              viewModel.gameState == GameState.gameOver ||
              viewModel.gameState == GameState.initForGame,

          onPopInvokedWithResult: (bool didPop, dynamic result) {
            if (!didPop) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    'Se você sair agora perderá a pontuação atual!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Color Memory'),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app_outlined),
                  onPressed: () {
                    viewModel.exitGame();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 20,
              children: [
                SizedBox(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: AdWidget(
                    ad: BannerAd(
                      adUnitId: AdHelper
                          .bannerAdUnitId, // Usa o ID de teste do seu helper
                      size: AdSize.banner,
                      request: const AdRequest(),
                      listener: const BannerAdListener(),
                    )..load(),
                  ),
                ),
                Consumer<GameViewModel>(
                  builder: (context, viewModel, child) {
                    return Text(
                      'Score: ${viewModel.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                Consumer<GameViewModel>(
                  builder: (context, viewModel, child) {
                    String textToShow = '';
                    Color textColor =
                        Theme.of(context).textTheme.bodyLarge?.color ??
                        Colors.grey;

                    // Define o texto e a cor com base no estado do jogo
                    switch (viewModel.gameState) {
                      case GameState.showingSequence:
                        textToShow = viewModel.gameSequence.length >= 10
                            ? "Atenção esta ficando difícil..."
                            : 'Observe a Sequência...';
                        textColor = Colors.blueAccent;
                        break;
                      case GameState.waitingForPlayer:
                        textToShow = 'Vamos lá, é a sua vez!';
                        textColor = Colors.green;
                        break;
                      case GameState.gameOver:
                        textToShow = 'Ops! Game Over!';
                        textColor = Colors.redAccent;
                      case GameState.initForGame:
                        textToShow = '';
                        break;
                    }

                    // AnimatedSwitcher cuida da animação de fade entre os textos
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Text(
                        textToShow,
                        // A Key é essencial para o AnimatedSwitcher saber
                        // que o widget mudou e que ele deve animar.
                        key: ValueKey<String>(textToShow),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),

                Consumer<GameViewModel>(
                  builder: (context, value, child) => Expanded(
                    // height: 350,
                    // width: 350,
                    child: GridView.builder(
                      itemCount: viewModel.gameColors.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: viewModel.gameColors.length <= 4
                            ? 2
                            : 4,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),

                      itemBuilder: (context, index) {
                        final color = viewModel.gameColors[index];
                        return _buildColorSquare(
                          viewModel,
                          color,
                          Provider.of<SettingsManager>(context),
                        );
                      },
                    ),
                  ),
                ),

                Consumer<GameViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.gameState == GameState.gameOver) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: ElevatedButton(
                          onPressed: () => viewModel.startGame(),
                          child: const Text('Tentar Novamente'),
                        ),
                      );
                    } else if (viewModel.gameState == GameState.initForGame) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 50.0),
                        child: ElevatedButton(
                          onPressed: () => viewModel.startGame(),
                          child: const Text('Iniciar Jogo'),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSquare(
    GameViewModel viewModel,
    Color color,
    SettingsManager settingsManager,
  ) {
    final bool isGameActive = viewModel.activeColor == color;
    final bool isPlayerActive = viewModel.playerActiveColor == color;

    final bool isHighlighted = isGameActive || isPlayerActive;
    final colorToUse = isHighlighted
        ? color
        : settingsManager.isColorDimmingEnabled
        ? color.withOpacity(0.3)
        : color;

    final bool canTap = viewModel.gameState == GameState.waitingForPlayer;
    return GestureDetector(
      onTap: canTap ? () => viewModel.handlePlayerTap(color) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 180,
        height: 180,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: colorToUse,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isHighlighted)
              BoxShadow(color: color, blurRadius: 15, spreadRadius: 3),
          ],
        ),
      ),
    );
  }
}

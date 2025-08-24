// lib/src/features/game/game_view.dart

import 'package:flutter/material.dart';
import 'package:memory_color/src/core/enum/game_state.dart';
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
                    'Você não pode sair durante uma partida!',
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
              title: const Text('Memória colorida'),
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
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 20,
                children: [
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
                    builder: (context, value, child) => SizedBox(
                      height: 350,
                      width: 350,
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
                        return ElevatedButton(
                          onPressed: () => viewModel.startGame(),
                          child: const Text('Tentar Novamente'),
                        );
                      } else if (viewModel.gameState == GameState.initForGame) {
                        return ElevatedButton(
                          onPressed: () => viewModel.startGame(),
                          child: const Text('Iniciar Jogo'),
                        );
                      }
                      return Container();
                    },
                  ),
                ],
              ),
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
        ? color.withOpacity(0.5)
        : color;

    final bool canTap = viewModel.gameState == GameState.waitingForPlayer;
    return GestureDetector(
      onTap: canTap ? () => viewModel.handlePlayerTap(color) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 200,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorToUse,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (isHighlighted)
              BoxShadow(
                color: color.withOpacity(0.8),
                blurRadius: 15,
                spreadRadius: 5,
              ),
          ],
        ),
      ),
    );
  }
}

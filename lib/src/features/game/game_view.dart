import 'package:material_ui/material_ui.dart';
import 'package:memory_color/src/core/enum/game_state.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/features/game/game_view_model.dart';
import 'package:memory_color/src/features/widgets/banner_ad_view.dart';
import 'package:memory_color/src/features/widgets/game_modals.dart';
import 'package:provider/provider.dart';

class GameView extends StatelessWidget {
  const GameView({super.key});
  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameViewModel>();
    final settings = context.watch<SettingsManager>();
    final scheme = Theme.of(context).colorScheme;
    final status = switch (model.gameState) {
      GameState.initForGame => 'Preparado para começar?',
      GameState.showingSequence => 'Observe a sequência',
      GameState.waitingForPlayer => model.canAcceptTap
          ? 'Sua vez! Repita as cores'
          : 'Aguarde o próximo toque',
      GameState.gameOver => 'Fim de jogo!',
    };
    return PopScope(
      canPop:
          model.gameState == GameState.gameOver ||
          model.gameState == GameState.initForGame,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Use o botão de sair para encerrar a partida.'),
            ),
          );
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Color Memory',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Sair da partida',
              icon: const Icon(Icons.close),
              onPressed: () async {
                if (model.gameState == GameState.showingSequence ||
                    model.gameState == GameState.waitingForPlayer) {
                  final leave = await showExitConfirmation(context);
                  if (leave != true || !context.mounted) return;
                }
                model.exitGame();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) Navigator.of(context).pop();
                });
              },
            ),
          ],
        ),
        bottomNavigationBar: const BannerAdView(),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PONTUAÇÃO',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                          ),
                          Text(
                            '${model.score}',
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              status,
                              key: ValueKey(status),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 28),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: model.gameColors.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: model.gameColors.length <= 4
                                      ? 2
                                      : 4,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                ),
                            itemBuilder: (context, index) {
                              final color = model.gameColors[index];
                              final active =
                                  model.activeColor == color ||
                                  model.playerActiveColor == color;
                              return Semantics(
                                button: true,
                                label: 'Cor ${index + 1}',
                                enabled:
                                    model.canAcceptTap,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(22),
                                    onTap:
                                        model.canAcceptTap
                                        ? () => model.handlePlayerTap(color)
                                        : null,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            active ||
                                                !settings.isColorDimmingEnabled
                                            ? color
                                            : color.withValues(alpha: 0.42),
                                        borderRadius: BorderRadius.circular(22),
                                        border: Border.all(
                                          color: active
                                              ? scheme.onSurface
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 28),
                          if (model.gameState == GameState.initForGame ||
                              model.gameState == GameState.gameOver)
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: model.startGame,
                                child: Text(
                                  model.gameState == GameState.gameOver
                                      ? 'Jogar novamente'
                                      : 'Começar',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

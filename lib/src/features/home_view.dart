import 'package:material_ui/material_ui.dart';
import 'package:memory_color/src/core/services/score_manager.dart';
import 'package:memory_color/src/features/home_view_model.dart';
import 'package:memory_color/src/features/widgets/banner_ad_view.dart';
import 'package:memory_color/src/features/widgets/game_modals.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final scores = context.watch<ScoreManager>();
    final model = context.read<HomeViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Color Memory', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(tooltip: 'Configurações', onPressed: () => showGameSettings(context),
          icon: const Icon(Icons.settings_outlined))]),
      bottomNavigationBar: const BannerAdView(),
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: ListView(padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), children: [
          Wrap(spacing: 8, children: [
            _dot(const Color(0xFFFF6C79)), _dot(const Color(0xFF6B8CFF)),
            _dot(const Color(0xFF42BFA2)), _dot(const Color(0xFFFFC55C)),
          ]),
          const SizedBox(height: 24),
          Text('Sua memória,\numa cor por vez.', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.12)),
          const SizedBox(height: 12),
          Text('Observe a sequência e repita. Até onde você consegue chegar?', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 28),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(
            color: scheme.primaryContainer, borderRadius: BorderRadius.circular(24)),
            child: Row(children: [Icon(Icons.emoji_events_outlined, color: scheme.onPrimaryContainer, size: 32),
              const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Seu recorde', style: TextStyle(color: scheme.onPrimaryContainer)),
                Text('${scores.highScore} pontos', style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 25, fontWeight: FontWeight.w800)),
              ]))])),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: () { model.pressedPLay(); showGameDifficulty(context, model); },
            icon: const Icon(Icons.play_arrow_rounded), label: const Text('Jogar agora')),
          const SizedBox(height: 36),
          Text('Partidas recentes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (scores.history.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 20), child: Text('Suas pontuações aparecerão aqui após a primeira partida.', style: TextStyle(color: scheme.onSurfaceVariant)))
          else ...scores.history.map((entry) => ListTile(contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(backgroundColor: scheme.secondaryContainer, child: Icon(Icons.history, color: scheme.onSecondaryContainer)),
            title: Text('${entry.score} pontos', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${entry.colors} cores · ${entry.playedAt.day.toString().padLeft(2, '0')}/${entry.playedAt.month.toString().padLeft(2, '0')}/${entry.playedAt.year}'),
          )),
        ]),
      ))),
    );
  }
  Widget _dot(Color color) => Container(width: 20, height: 20, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(7)));
}

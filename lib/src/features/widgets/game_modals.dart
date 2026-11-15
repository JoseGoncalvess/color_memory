import 'package:material_ui/material_ui.dart';
import 'package:memory_color/src/core/services/settings_manager.dart';
import 'package:memory_color/src/core/theme/theme_manager.dart';
import 'package:memory_color/src/core/theme/app_themes.dart';
import 'package:memory_color/src/features/home_view_model.dart';
import 'package:provider/provider.dart';

Future<void> _showGameSheet(BuildContext context, Widget child) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    sheetAnimationStyle: AnimationStyle(
      duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
      reverseDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
    ),
    builder: (context) => Consumer<ThemeManager>(
      builder: (context, theme, _) {
        final data = theme.themeMode == ThemeMode.dark
            ? AppThemes.darkTheme : AppThemes.lightTheme;
        return Theme(
          data: data,
          child: Material(
            color: data.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
                child: SingleChildScrollView(
                  child: Center(child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Padding(padding: const EdgeInsets.fromLTRB(24, 4, 24, 28), child: child),
                  )),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

Future<void> showGameDifficulty(BuildContext context, HomeViewModel model) {
  return _showGameSheet(context, Builder(builder: (sheet) {
    final scheme = Theme.of(sheet).colorScheme;
    final levels = [
      (4, 'Fácil', 'Para começar com calma', Icons.looks_one_outlined),
      (8, 'Médio', 'Um desafio a mais', Icons.looks_two_outlined),
      (12, 'Difícil', 'Para testar sua memória', Icons.looks_3_outlined),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('Escolha a dificuldade', style: Theme.of(sheet).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Quantas cores você quer memorizar?', style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 20),
      for (final level in levels)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Material(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          child: ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Icon(level.$4, color: scheme.primary),
            title: Text(level.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${level.$1} cores · ${level.$3}'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () { Navigator.pop(sheet); model.navigateToGame(level.$1); },
          ),
        )),
    ]);
  }));
}

Future<void> showGameSettings(BuildContext context) {
  return _showGameSheet(context, Builder(builder: (sheet) {
    final scheme = Theme.of(sheet).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text('Configurações', style: Theme.of(sheet).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text('Deixe o jogo do seu jeito.', style: TextStyle(color: scheme.onSurfaceVariant)),
      const SizedBox(height: 20),
      Consumer<SettingsManager>(builder: (_, settings, __) => Column(children: [
        _SettingTile(icon: Icons.volume_up_outlined, title: 'Sons', subtitle: 'Sons das cores e ações', value: settings.isSoundEnabled, onChanged: (_) => settings.toggleSound()),
        _SettingTile(icon: Icons.vibration_outlined, title: 'Vibração', subtitle: 'Resposta ao tocar nas cores', value: settings.isVibrationEnabled, onChanged: (_) => settings.toggleVibration()),
        _SettingTile(icon: Icons.highlight_outlined, title: 'Destacar cor ativa', subtitle: 'Escurecer as outras cores', value: settings.isColorDimmingEnabled, onChanged: (_) => settings.toggleColorDimming()),
      ])),
      Consumer<SettingsManager>(builder: (_, settings, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Velocidade da sequência', style: Theme.of(sheet).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Aplicada a partir de 11 cores.', style: Theme.of(sheet).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final speed in SettingsManager.sequenceSpeeds)
              ChoiceChip(label: Text('${speed.toStringAsFixed(1).replaceAll('.', ',')}×'),
                selected: settings.sequenceSpeed == speed,
                onSelected: (_) => settings.setSequenceSpeed(speed)),
          ]),
        ]),
      )),
      Consumer<ThemeManager>(builder: (_, theme, __) => _SettingTile(
        icon: Icons.dark_mode_outlined, title: 'Modo escuro', subtitle: 'Alterar a aparência do aplicativo',
        value: theme.themeMode == ThemeMode.dark, onChanged: theme.toggleTheme)),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, child: FilledButton.tonal(onPressed: () => Navigator.pop(sheet), child: const Text('Concluído'))),
    ]);
  }));
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, required this.value, required this.onChanged});
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: scheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

Future<bool?> showExitConfirmation(BuildContext context) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
    pageBuilder: (dialog, animation, secondaryAnimation) {
      final scheme = Theme.of(dialog).colorScheme;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.exit_to_app_rounded, color: scheme.onErrorContainer)),
            const SizedBox(height: 20),
            Text('Sair da partida?', style: Theme.of(dialog).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('A pontuação desta partida será perdida.', style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(dialog, false), child: const Text('Continuar jogando'))),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: TextButton(onPressed: () => Navigator.pop(dialog, true), child: const Text('Sair da partida'))),
          ]),
        )),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(opacity: curve, child: ScaleTransition(scale: Tween<double>(begin: 0.96, end: 1).animate(curve), child: child));
    },
  );
}

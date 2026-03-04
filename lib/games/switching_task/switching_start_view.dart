import 'package:flutter/material.dart';

import 'switching_game_state.dart';

class SwitchingStartView extends StatelessWidget {
  final SwitchingGameState state;

  const SwitchingStartView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.swap_vert, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Task Switching', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Wechsle blitzschnell zwischen zwei Regeln je nach Position der Zahl.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Rules explanation
              _ruleCard(
                context,
                icon: Icons.arrow_upward,
                title: 'Oben: Gerade / Ungerade',
                subtitle: 'Ist die Zahl gerade oder ungerade?',
              ),
              const SizedBox(height: 12),
              _ruleCard(
                context,
                icon: Icons.arrow_downward,
                title: 'Unten: Kleiner / Größer als 5',
                subtitle: 'Ist die Zahl kleiner oder größer als 5?',
              ),
              const SizedBox(height: 32),

              // Trials
              Align(alignment: Alignment.centerLeft, child: Text('DURCHGÄNGE',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => state.setTrials(-10),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${state.totalTrials}', style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    IconButton(
                      onPressed: () => state.setTrials(10),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56)),
                child: const Text('Starten', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruleCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(subtitle, style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

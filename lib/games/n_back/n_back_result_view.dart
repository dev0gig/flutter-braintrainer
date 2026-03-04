import 'package:flutter/material.dart';

import 'n_back_game_state.dart';

class NBackResultView extends StatelessWidget {
  final NBackGameState state;

  const NBackResultView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final acc = state.accuracy;

    IconData icon;
    Color iconColor;
    if (acc >= 80) {
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (acc >= 50) {
      icon = Icons.trending_up;
      iconColor = Colors.orange;
    } else {
      icon = Icons.refresh;
      iconColor = colorScheme.error;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 16),
              Text(
                '${state.nLevel}-Back Ergebnis',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text(
                      '$acc%',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Genauigkeit',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2x2 stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Treffer',
                            value: state.hits,
                            color: Colors.green,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: 'Verpasst',
                            value: state.misses,
                            color: Colors.red,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Fehlalarm',
                            value: state.falseAlarms,
                            color: Colors.red.shade300,
                            colorScheme: colorScheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatTile(
                            label: 'Korrekt abgelehnt',
                            value: state.correctRejections,
                            color: Colors.green.shade300,
                            colorScheme: colorScheme,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: state.startGame,
                icon: const Icon(Icons.replay),
                label: const Text('Nochmal spielen'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.returnToStart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Zurück zum Menü'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final ColorScheme colorScheme;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

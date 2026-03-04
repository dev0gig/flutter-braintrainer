import 'package:flutter/material.dart';

import 'math_game_state.dart';

class MathResultView extends StatelessWidget {
  final MathGameState state;

  const MathResultView({super.key, required this.state});

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
              Text('Zeit abgelaufen!', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 24),

              // Score card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text(
                      'ERGEBNIS',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.score}',
                      style: textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    Text(
                      'Aufgaben gelöst',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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

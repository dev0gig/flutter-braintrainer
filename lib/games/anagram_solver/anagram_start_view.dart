import 'package:flutter/material.dart';

import 'anagram_game_state.dart';

class AnagramStartView extends StatelessWidget {
  final AnagramGameState state;

  const AnagramStartView({super.key, required this.state});

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
              Icon(
                Icons.spellcheck,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text('Anagramm', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Ordne die durcheinander gewürfelten Buchstaben zum richtigen Wort.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Difficulty selector
              Text(
                'SCHWIERIGKEIT',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<Difficulty>(
                segments: const [
                  ButtonSegment(value: Difficulty.easy, label: Text('Leicht')),
                  ButtonSegment(value: Difficulty.medium, label: Text('Mittel')),
                  ButtonSegment(value: Difficulty.hard, label: Text('Schwer')),
                ],
                selected: {state.difficulty},
                onSelectionChanged: (s) => state.setDifficulty(s.first),
              ),
              const SizedBox(height: 8),
              Text(
                state.instructions,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Example
              Transform.rotate(
                angle: -0.02,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final letter in ['L', 'M', 'U', 'B', 'E'])
                        Container(
                          width: 32,
                          height: 36,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: Text(letter, style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                        ),
                      const SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: colorScheme.onSurfaceVariant, size: 20),
                      const SizedBox(width: 8),
                      Text('BLUME', style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Start button
              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Starten', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

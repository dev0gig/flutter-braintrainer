import 'package:flutter/material.dart';

import 'sequence_game_state.dart';

class SequenceStartView extends StatelessWidget {
  final SequenceGameState state;

  const SequenceStartView({super.key, required this.state});

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
              Icon(Icons.repeat, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Sequenz', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Merke dir die Regel und führe die Sequenz fort.\nBeispiel: Start 10 | Regel +4 → 14, 18, 22...',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Difficulty
              Align(alignment: Alignment.centerLeft, child: Text('SCHWIERIGKEIT',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5))),
              const SizedBox(height: 12),
              SegmentedButton<SeqDifficulty>(
                segments: const [
                  ButtonSegment(value: SeqDifficulty.easy, label: Text('Leicht')),
                  ButtonSegment(value: SeqDifficulty.medium, label: Text('Mittel')),
                  ButtonSegment(value: SeqDifficulty.hard, label: Text('Schwer')),
                ],
                selected: {state.difficulty},
                onSelectionChanged: (s) => state.setDifficulty(s.first),
              ),
              const SizedBox(height: 24),

              // Rounds
              Align(alignment: Alignment.centerLeft, child: Text('ANZAHL SCHRITTE',
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
                      onPressed: () => state.adjustRounds(-5),
                      icon: const Icon(Icons.remove),
                    ),
                    Text('${state.maxRounds}', style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                    IconButton(
                      onPressed: () => state.adjustRounds(5),
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
}

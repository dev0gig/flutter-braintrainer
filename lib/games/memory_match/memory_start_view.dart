import 'package:flutter/material.dart';

import 'memory_game_state.dart';

class MemoryStartView extends StatelessWidget {
  final MemoryGameState state;

  const MemoryStartView({super.key, required this.state});

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
                Icons.style,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text('Paare finden', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Finde alle Paare so schnell wie möglich.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Example pair
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 2; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text('★', style: TextStyle(
                        fontSize: 28,
                        color: colorScheme.onSurface,
                      )),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              // Difficulty
              Text(
                'SCHWIERIGKEIT',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<MemoryDifficulty>(
                segments: const [
                  ButtonSegment(
                    value: MemoryDifficulty.easy,
                    label: Text('Leicht'),
                  ),
                  ButtonSegment(
                    value: MemoryDifficulty.medium,
                    label: Text('Mittel'),
                  ),
                  ButtonSegment(
                    value: MemoryDifficulty.hard,
                    label: Text('Schwer'),
                  ),
                ],
                selected: {state.difficulty},
                onSelectionChanged: (s) => state.setDifficulty(s.first),
              ),
              const SizedBox(height: 8),
              Text(
                switch (state.difficulty) {
                  MemoryDifficulty.easy => '4×3 Karten, 6 Paare',
                  MemoryDifficulty.medium => '4×4 Karten, 8 Paare',
                  MemoryDifficulty.hard => '5×6 Karten, 15 Paare',
                },
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

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

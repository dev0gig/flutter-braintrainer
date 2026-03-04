import 'package:flutter/material.dart';

import 'stroop_game_state.dart';

class StroopStartView extends StatelessWidget {
  final StroopGameState state;

  const StroopStartView({super.key, required this.state});

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
              Icon(Icons.palette, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Stroop Test', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                state.difficulty == StroopDifficulty.normal
                    ? 'Wähle die Farbe, in der das Wort angezeigt wird – ignoriere den Text!'
                    : 'Mal nach der Farbe, mal nach dem Text fragen – lies die Anweisung genau!',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Example
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text('Beispiel:', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text('ROT',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text('→ Richtig: BLAU (Farbe des Textes)',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Difficulty
              Align(alignment: Alignment.centerLeft, child: Text('SCHWIERIGKEIT',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5))),
              const SizedBox(height: 12),
              SegmentedButton<StroopDifficulty>(
                segments: const [
                  ButtonSegment(value: StroopDifficulty.normal, label: Text('Normal')),
                  ButtonSegment(value: StroopDifficulty.hard, label: Text('Schwer')),
                ],
                selected: {state.difficulty},
                onSelectionChanged: (s) => state.setDifficulty(s.first),
              ),
              const SizedBox(height: 24),

              // Rounds
              Align(alignment: Alignment.centerLeft, child: Text('ANZAHL RUNDEN',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final r in [10, 20, 30])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('$r'),
                        selected: state.maxRounds == r,
                        onSelected: (_) => state.setMaxRounds(r),
                      ),
                    ),
                ],
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

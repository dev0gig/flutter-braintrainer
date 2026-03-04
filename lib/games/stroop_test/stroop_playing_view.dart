import 'package:flutter/material.dart';

import 'stroop_game_state.dart';

class StroopPlayingView extends StatelessWidget {
  final StroopGameState state;

  const StroopPlayingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final round = state.round!;

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              IconButton(
                onPressed: state.returnToStart,
                icon: const Icon(Icons.close),
                tooltip: 'Abbrechen',
              ),
              const Spacer(),
              Text('Runde ', style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant)),
              Text('${state.currentRound + 1}/${state.maxRounds}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
        ),

        // Word display area
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Instruction
                Text(
                  round.askForColor
                      ? 'Welche FARBE hat das Wort?'
                      : 'Was STEHT dort geschrieben?',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                // The stroop word
                Text(
                  round.wordText,
                  style: textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: round.wordColor,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                // Feedback indicator
                if (state.feedback != null)
                  Icon(
                    state.feedback! ? Icons.check_circle : Icons.cancel,
                    size: 48,
                    color: state.feedback! ? Colors.green : Colors.red,
                  ),
              ],
            ),
          ),
        ),

        // Answer buttons (2x2 grid)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var row = 0; row < 2; row++)
                    Padding(
                      padding: EdgeInsets.only(bottom: row == 0 ? 12 : 0),
                      child: Row(
                        children: [
                          for (var col = 0; col < 2; col++) ...[
                            if (col > 0) const SizedBox(width: 12),
                            Expanded(
                              child: _buildOptionButton(
                                round.options[row * 2 + col],
                                row * 2 + col,
                                colorScheme,
                                textTheme,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton(
    StroopColor option, int index, ColorScheme cs, TextTheme tt) {
    Color borderColor = cs.outlineVariant;
    double borderWidth = 1;

    if (state.feedback != null) {
      if (index == state.round!.correctIndex) {
        borderColor = Colors.green;
        borderWidth = 3;
      } else if (index == state.selectedIndex && !state.feedback!) {
        borderColor = Colors.red;
        borderWidth = 3;
      }
    }

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => state.selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: option.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(option.label, style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: cs.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class StroopGameoverView extends StatelessWidget {
  final StroopGameState state;

  const StroopGameoverView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final ratio = state.correctCount / state.maxRounds;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                ratio >= 0.8 ? Icons.emoji_events
                    : ratio >= 0.5 ? Icons.trending_up : Icons.refresh,
                size: 64,
                color: ratio >= 0.8 ? Colors.amber
                    : ratio >= 0.5 ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Ergebnis', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text('Richtige Antworten', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.correctCount} / ${state.maxRounds}',
                      style: textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace', color: colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${(ratio * 100).round()}%',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
                child: const Text('Nochmal'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.returnToStart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
                child: const Text('Zurück zum Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

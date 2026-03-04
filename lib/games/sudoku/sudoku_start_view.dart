import 'package:flutter/material.dart';

import 'sudoku_game_state.dart';

class SudokuStartView extends StatelessWidget {
  final SudokuGameState state;

  const SudokuStartView({super.key, required this.state});

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
              Icon(Icons.grid_on, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Sudoku', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Fülle das 9×9 Gitter so aus, dass jede Zeile, Spalte und '
                'jeder 3×3 Block die Zahlen 1-9 genau einmal enthält.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('SCHWIERIGKEIT', style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),

              _DifficultyButton(
                label: 'Leicht',
                hint: '~42 Zahlen vorgegeben',
                onTap: () => state.startGame(SudokuDifficulty.easy),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),
              _DifficultyButton(
                label: 'Mittel',
                hint: '~32 Zahlen vorgegeben',
                onTap: () => state.startGame(SudokuDifficulty.medium),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),
              _DifficultyButton(
                label: 'Schwer',
                hint: '~24 Zahlen vorgegeben',
                onTap: () => state.startGame(SudokuDifficulty.hard),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _DifficultyButton({
    required this.label,
    required this.hint,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              Text(hint, style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

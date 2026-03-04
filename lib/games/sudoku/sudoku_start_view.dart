import 'package:flutter/material.dart';

import '../../services/game_state_service.dart';
import 'sudoku_game_state.dart';

class SudokuStartView extends StatefulWidget {
  final SudokuGameState state;

  const SudokuStartView({super.key, required this.state});

  @override
  State<SudokuStartView> createState() => _SudokuStartViewState();
}

class _SudokuStartViewState extends State<SudokuStartView> {
  bool _hasSavedState = false;
  String? _savedDifficulty;

  @override
  void initState() {
    super.initState();
    _checkSavedState();
  }

  Future<void> _checkSavedState() async {
    final data = await GameStateService.loadState('sudoku');
    if (mounted) {
      setState(() {
        _hasSavedState = data != null;
        if (data != null) {
          _savedDifficulty = switch (data['difficulty'] as String?) {
            'easy' => 'Leicht',
            'medium' => 'Mittel',
            'hard' => 'Schwer',
            _ => null,
          };
        }
      });
    }
  }

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

              if (_hasSavedState) ...[
                FilledButton.icon(
                  onPressed: () => widget.state.tryResume(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text('Weiterspielen${_savedDifficulty != null ? ' ($_savedDifficulty)' : ''}'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56)),
                ),
                const SizedBox(height: 24),
              ],

              Align(
                alignment: Alignment.centerLeft,
                child: Text('SCHWIERIGKEIT', style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),

              _DifficultyButton(
                label: 'Leicht',
                hint: '~42 Zahlen vorgegeben',
                onTap: () => widget.state.startGame(SudokuDifficulty.easy),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),
              _DifficultyButton(
                label: 'Mittel',
                hint: '~32 Zahlen vorgegeben',
                onTap: () => widget.state.startGame(SudokuDifficulty.medium),
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(height: 8),
              _DifficultyButton(
                label: 'Schwer',
                hint: '~24 Zahlen vorgegeben',
                onTap: () => widget.state.startGame(SudokuDifficulty.hard),
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

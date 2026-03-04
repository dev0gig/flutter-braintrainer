import 'package:flutter/material.dart';

import 'chess_game_state.dart';

class ChessStartView extends StatelessWidget {
  final ChessGameState state;

  const ChessStartView({super.key, required this.state});

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
              Icon(Icons.castle, size: 72,
                  color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Chess', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Klassisches Schach. Wähle Figuren per Klick und setze sie auf markierte Felder.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),

              // Mode selector
              Text('MODUS', style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              SegmentedButton<ChessGameMode>(
                segments: const [
                  ButtonSegment(
                    value: ChessGameMode.computer,
                    label: Text('vs Computer'),
                  ),
                  ButtonSegment(
                    value: ChessGameMode.puzzle,
                    label: Text('Puzzle'),
                  ),
                ],
                selected: {state.gameMode},
                onSelectionChanged: (s) => state.setGameMode(s.first),
              ),
              const SizedBox(height: 16),

              // Mode description
              SizedBox(
                height: 60,
                child: Center(
                  child: Text(
                    state.gameMode == ChessGameMode.computer
                        ? 'Du spielst Weiß gegen den Computer. Berechnung erfolgt lokal.'
                        : 'Löse taktische Schachpuzzles. Finde den besten Zug!',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Difficulty
              Text('SCHWIERIGKEIT', style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              const SizedBox(height: 12),

              if (state.gameMode == ChessGameMode.computer) ...[
                _DifficultyButton(
                  label: 'Leicht',
                  badge: '1 Zug voraus',
                  badgeColor: Colors.green,
                  selected: state.difficulty == ChessDifficulty.easy,
                  onTap: () => state.setDifficulty(ChessDifficulty.easy),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _DifficultyButton(
                  label: 'Mittel',
                  badge: '2 Züge voraus',
                  badgeColor: Colors.orange,
                  selected: state.difficulty == ChessDifficulty.medium,
                  onTap: () => state.setDifficulty(ChessDifficulty.medium),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _DifficultyButton(
                  label: 'Schwer',
                  badge: '3 Züge voraus',
                  badgeColor: Colors.red,
                  selected: state.difficulty == ChessDifficulty.hard,
                  onTap: () => state.setDifficulty(ChessDifficulty.hard),
                  colorScheme: colorScheme,
                ),
              ] else ...[
                _DifficultyButton(
                  label: 'Leicht',
                  badge: 'Matt in 1',
                  badgeColor: Colors.green,
                  selected: state.puzzleDifficulty == ChessDifficulty.easy,
                  onTap: () => state.setPuzzleDifficulty(ChessDifficulty.easy),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _DifficultyButton(
                  label: 'Mittel',
                  badge: 'Matt in 2',
                  badgeColor: Colors.orange,
                  selected: state.puzzleDifficulty == ChessDifficulty.medium,
                  onTap: () => state.setPuzzleDifficulty(ChessDifficulty.medium),
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _DifficultyButton(
                  label: 'Schwer',
                  badge: 'Taktik',
                  badgeColor: Colors.red,
                  selected: state.puzzleDifficulty == ChessDifficulty.hard,
                  onTap: () => state.setPuzzleDifficulty(ChessDifficulty.hard),
                  colorScheme: colorScheme,
                ),
              ],

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

class _DifficultyButton extends StatelessWidget {
  final String label;
  final String badge;
  final Color badgeColor;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _DifficultyButton({
    required this.label,
    required this.badge,
    required this.badgeColor,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: TextStyle(
                  fontSize: 12,
                  color: badgeColor,
                  fontWeight: FontWeight.w500,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

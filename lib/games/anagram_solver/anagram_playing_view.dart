import 'package:flutter/material.dart';

import 'anagram_game_state.dart';

class AnagramPlayingView extends StatelessWidget {
  final AnagramGameState state;

  const AnagramPlayingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Header bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Close button
              IconButton(
                onPressed: state.returnToStart,
                icon: const Icon(Icons.close),
                tooltip: 'Abbrechen',
              ),
              const SizedBox(width: 8),
              // Timer
              _TimerChip(
                timeLeft: state.timeLeft,
                isWarning: state.timeLeft <= 5,
                colorScheme: colorScheme,
              ),
              const Spacer(),
              // Round
              Text(
                '${state.currentRound}/${state.totalRounds}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 16),
              // Score
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${state.score}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Game content
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hint area
                    if (state.difficulty != Difficulty.hard) ...[
                      SizedBox(
                        height: 32,
                        child: state.showHint
                            ? Text(
                                state.currentWord.hint,
                                style: textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              )
                            : TextButton.icon(
                                onPressed: state.toggleHint,
                                icon: const Icon(Icons.lightbulb_outline, size: 16),
                                label: const Text('Hinweis anzeigen'),
                                style: TextButton.styleFrom(
                                  textStyle: textTheme.bodySmall,
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Answer slots
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (var i = 0; i < state.guessedLetters.length; i++)
                          _AnswerSlot(
                            tile: state.guessedLetters[i],
                            feedback: state.feedback,
                            onTap: () => state.removeLetter(i),
                            colorScheme: colorScheme,
                          ),
                      ],
                    ),

                    // Skipped solution
                    if (state.feedback == AnswerFeedback.skipped) ...[
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          children: [
                            const TextSpan(text: 'Lösung: '),
                            TextSpan(
                              text: state.currentWord.word,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Scrambled tiles
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tile in state.scrambledTiles)
                          _ScrambledTile(
                            tile: tile,
                            feedback: state.feedback,
                            onTap: () => state.selectTile(tile),
                            colorScheme: colorScheme,
                          ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Skip button
                    OutlinedButton(
                      onPressed: state.feedback != AnswerFeedback.none
                          ? null
                          : state.skipWord,
                      child: const Text('Überspringen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimerChip extends StatelessWidget {
  final int timeLeft;
  final bool isWarning;
  final ColorScheme colorScheme;

  const _TimerChip({
    required this.timeLeft,
    required this.isWarning,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning ? colorScheme.error : colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.timer, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '${timeLeft}s',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _AnswerSlot extends StatelessWidget {
  final LetterTile? tile;
  final AnswerFeedback feedback;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _AnswerSlot({
    required this.tile,
    required this.feedback,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color bgColor;
    Color textColor = colorScheme.onSurface;

    switch (feedback) {
      case AnswerFeedback.correct:
        borderColor = Colors.green;
        bgColor = tile != null ? Colors.green.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest;
        textColor = Colors.green;
      case AnswerFeedback.incorrect:
        borderColor = Colors.red;
        bgColor = tile != null ? Colors.red.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest;
        textColor = Colors.red;
      default:
        if (tile != null) {
          borderColor = colorScheme.primary;
          bgColor = colorScheme.primary.withValues(alpha: 0.1);
        } else {
          borderColor = colorScheme.outlineVariant;
          bgColor = colorScheme.surfaceContainerHighest;
        }
    }

    return GestureDetector(
      onTap: tile != null && feedback == AnswerFeedback.none ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 52,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          tile?.letter ?? '',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _ScrambledTile extends StatelessWidget {
  final LetterTile tile;
  final AnswerFeedback feedback;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ScrambledTile({
    required this.tile,
    required this.feedback,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !tile.used && feedback == AnswerFeedback.none ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: tile.used ? 0.2 : 1.0,
        child: Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Text(
            tile.letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

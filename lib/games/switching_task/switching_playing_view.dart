import 'package:flutter/material.dart';

import 'switching_game_state.dart';

class SwitchingPlayingView extends StatelessWidget {
  final SwitchingGameState state;

  const SwitchingPlayingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Color numberColor = colorScheme.onSurface;
    if (state.feedback == true) numberColor = Colors.green;
    if (state.feedback == false) numberColor = Colors.red;

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
              Text('${state.currentTrial}/${state.totalTrials} ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, fontFamily: 'monospace')),
              const SizedBox(width: 12),
              Icon(Icons.check, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text('${state.correctCount}', style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          ),
        ),

        // Game area: two halves
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                // TOP HALF: Gerade / Ungerade
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3))),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Gerade / Ungerade', style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                            letterSpacing: 1.5)),
                          const SizedBox(height: 16),
                          if (state.showNumber && state.currentPosition == Position.top)
                            Text(
                              '${state.currentNumber}',
                              style: textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 80,
                                color: numberColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                // BOTTOM HALF: < 5 / > 5
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Kleiner / Größer als 5', style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          letterSpacing: 1.5)),
                        const SizedBox(height: 16),
                        if (state.showNumber && state.currentPosition == Position.bottom)
                          Text(
                            '${state.currentNumber}',
                            style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 80,
                              color: numberColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Response buttons (2x2)
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Opacity(
                opacity: state.waitingForInput ? 1.0 : 0.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _answerBtn('Gerade', SwitchAnswer.even, colorScheme)),
                        const SizedBox(width: 12),
                        Expanded(child: _answerBtn('Ungerade', SwitchAnswer.odd, colorScheme)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _answerBtn('< 5', SwitchAnswer.less, colorScheme)),
                        const SizedBox(width: 12),
                        Expanded(child: _answerBtn('> 5', SwitchAnswer.greater, colorScheme)),
                      ],
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

  Widget _answerBtn(String label, SwitchAnswer answer, ColorScheme cs) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => state.handleResponse(answer),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
        ),
      ),
    );
  }
}

class SwitchingResultView extends StatelessWidget {
  final SwitchingGameState state;

  const SwitchingResultView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final acc = state.accuracy;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                acc >= 80 ? Icons.emoji_events
                    : acc >= 60 ? Icons.trending_up : Icons.refresh,
                size: 64,
                color: acc >= 80 ? Colors.amber
                    : acc >= 60 ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 12),
              Text(state.scoreRating, style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Score card
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
                    Text('${state.score}', style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary)),
                    Text('Punkte', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _statBox('${state.accuracy}%', 'Genauigkeit', colorScheme)),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox('${state.avgReactionTime}ms', 'Reaktionszeit', colorScheme)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Switch cost analysis
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    Text('SWITCH-KOSTEN', style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _statBoxColored(
                          '${state.avgNonSwitchTime}ms', 'Gleich', Colors.green, colorScheme)),
                        const SizedBox(width: 8),
                        Expanded(child: _statBoxColored(
                          '${state.avgSwitchTime}ms', 'Wechsel', Colors.orange, colorScheme)),
                        const SizedBox(width: 8),
                        Expanded(child: _statBoxColored(
                          '+${state.switchCost}ms', 'Differenz',
                          state.switchCost < 100 ? Colors.green
                              : state.switchCost < 200 ? Colors.orange : Colors.red,
                          colorScheme)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Geringere Differenz = besseres Task-Switching',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
                child: const Text('Nochmal spielen'),
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

  Widget _statBox(String value, String label, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _statBoxColored(String value, String label, Color color, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

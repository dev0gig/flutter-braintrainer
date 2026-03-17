import 'package:flutter/material.dart';

import 'math_game_state.dart';

class MathPlayingView extends StatelessWidget {
  final MathGameState state;

  const MathPlayingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              // Timer
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 20,
                    color: state.timeLeft <= 10
                        ? colorScheme.error
                        : colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${state.timeLeft}s',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: state.timeLeft <= 10
                          ? colorScheme.error
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Score
              Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(
                    '${state.score}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Question & input
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: state.chainMemorizing
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Merke dir die Startzahl!',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 24),
                          Text(
                            state.currentQuestion.text,
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: 48, height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3, color: colorScheme.primary),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Question
                          Text(
                            state.currentQuestion.text,
                            style: textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Answer box
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: 72,
                            decoration: BoxDecoration(
                              color: state.feedback == MathFeedback.incorrect
                                  ? colorScheme.error.withValues(alpha: 0.1)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: switch (state.feedback) {
                                  MathFeedback.correct => Colors.green,
                                  MathFeedback.incorrect => colorScheme.error,
                                  MathFeedback.none => colorScheme.outlineVariant,
                                },
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              state.userAnswer.isEmpty ? '?' : state.userAnswer,
                              style: textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                                color: state.userAnswer.isEmpty
                                    ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),

        // Numpad
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _Numpad(
                onNumber: state.appendNumber,
                onBackspace: state.backspace,
                onSubmit: state.submitAnswer,
                colorScheme: colorScheme,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Sequence views ---

class SequenceMemorizeView extends StatelessWidget {
  final MathGameState state;

  const SequenceMemorizeView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Merke dir Startzahl & Regel!',
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            Text('Start: ${state.sequenceStartNumber}',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(height: 16),
            Text('Regel: ${state.sequenceRule}',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: colorScheme.primary)),
            const SizedBox(height: 40),
            SizedBox(
              width: 48, height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3, color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class SequenceInputView extends StatelessWidget {
  final MathGameState state;

  const SequenceInputView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              Icon(
                Icons.timer,
                size: 20,
                color: state.sequenceTimeLeft <= 10
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.sequenceTimeLeft}s',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: state.sequenceTimeLeft <= 10
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 24),
              Text('Schritte: ', style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant)),
              Text('${state.score}', style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
        ),

        // Display area
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('NÄCHSTE ZAHL?', style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
                    const SizedBox(height: 16),
                    // Input display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(
                          color: colorScheme.primary.withValues(alpha: 0.5), width: 2)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        state.sequenceInput.isEmpty ? '|' : state.sequenceInput,
                        style: textTheme.displaySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: state.sequenceInput.isEmpty
                              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.3)
                              : colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Numpad
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _SequenceNumpad(state: state, colorScheme: colorScheme),
            ),
          ),
        ),
      ],
    );
  }
}

class SequenceGameoverView extends StatelessWidget {
  final MathGameState state;

  const SequenceGameoverView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final timedOut = state.sequenceTimeLeft <= 0;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                timedOut ? Icons.timer_off : Icons.error_outline,
                size: 64,
                color: timedOut ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                timedOut ? 'Zeit abgelaufen!' : 'Falsch!',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
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
                    Text('Erreichte Schritte', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.score}',
                      style: textTheme.titleLarge?.copyWith(
                        fontFamily: 'monospace', color: colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Regel war', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.sequenceRule}', style: textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: state.startGame,
                icon: const Icon(Icons.replay),
                label: const Text('Nochmal spielen'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
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

// --- Shared numpad widgets ---

class _Numpad extends StatelessWidget {
  final void Function(int) onNumber;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final ColorScheme colorScheme;

  const _Numpad({
    required this.onNumber,
    required this.onBackspace,
    required this.onSubmit,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _NumButton(
                      label: '${row[i]}',
                      onTap: () => onNumber(row[i]),
                      colorScheme: colorScheme,
                    ),
                  ),
                ],
              ],
            ),
          ),
        // Bottom row: backspace, 0, submit
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.backspace_outlined,
                onTap: onBackspace,
                color: colorScheme.error.withValues(alpha: 0.8),
                bgColor: colorScheme.surfaceContainerHighest,
                borderColor: colorScheme.outlineVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NumButton(
                label: '0',
                onTap: () => onNumber(0),
                colorScheme: colorScheme,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionButton(
                icon: Icons.check,
                onTap: onSubmit,
                color: Colors.white,
                bgColor: Colors.green.shade600,
                borderColor: Colors.green.shade500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SequenceNumpad extends StatelessWidget {
  final MathGameState state;
  final ColorScheme colorScheme;

  const _SequenceNumpad({required this.state, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final row in [[1,2,3],[4,5,6],[7,8,9]])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                for (var i = 0; i < row.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _NumButton(
                    label: '${row[i]}',
                    onTap: () => state.appendSequenceNumber(row[i]),
                    colorScheme: cs,
                  )),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(child: _NumButton(
              label: '±',
              onTap: state.toggleMinus,
              colorScheme: cs,
            )),
            const SizedBox(width: 8),
            Expanded(child: _NumButton(
              label: '0',
              onTap: () => state.appendSequenceNumber(0),
              colorScheme: cs,
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.backspace_outlined,
              onTap: state.backspaceSequence,
              color: cs.error.withValues(alpha: 0.8),
              bgColor: cs.surfaceContainerHighest,
              borderColor: cs.outlineVariant,
            )),
            const SizedBox(width: 8),
            Expanded(child: _ActionButton(
              icon: Icons.check,
              onTap: state.confirmSequenceInput,
              color: Colors.white,
              bgColor: Colors.green.shade600,
              borderColor: Colors.green.shade500,
            )),
          ],
        ),
      ],
    );
  }
}

class _NumButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _NumButton({
    required this.label,
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
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color bgColor;
  final Color borderColor;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: color),
        ),
      ),
    );
  }
}

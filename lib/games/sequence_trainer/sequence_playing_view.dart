import 'package:flutter/material.dart';

import 'sequence_game_state.dart';

class SequenceMemorizeView extends StatelessWidget {
  final SequenceGameState state;

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
            Text('Start: ${state.startNumber}',
              style: textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold, fontFamily: 'monospace')),
            const SizedBox(height: 16),
            Text('Regel: ${state.rule}',
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
  final SequenceGameState state;

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
                    Text('LETZTE ZAHL', style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text(
                      '${state.currentSequence.last}',
                      style: textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Icon(Icons.arrow_downward,
                        color: colorScheme.primary.withValues(alpha: 0.5), size: 28),
                    ),
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
                        state.userInput.isEmpty ? '|' : state.userInput,
                        style: textTheme.displaySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: state.userInput.isEmpty
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
              child: _buildNumpad(colorScheme),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumpad(ColorScheme cs) {
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
                  Expanded(child: _numBtn('${row[i]}', () => state.appendNumber(row[i]), cs)),
                ],
              ],
            ),
          ),
        Row(
          children: [
            Expanded(child: _actionBtn(Icons.backspace_outlined, state.backspace,
              cs.error.withValues(alpha: 0.8), cs.surfaceContainerHighest, cs.outlineVariant)),
            const SizedBox(width: 8),
            Expanded(child: _numBtn('0', () => state.appendNumber(0), cs)),
            const SizedBox(width: 8),
            Expanded(child: _actionBtn(Icons.check, state.confirmInput,
              Colors.white, Colors.green.shade600, Colors.green.shade500)),
          ],
        ),
      ],
    );
  }

  Widget _numBtn(String label, VoidCallback onTap, ColorScheme cs) {
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
            color: cs.onSurface)),
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, Color iconColor, Color bg, Color border) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 22, color: iconColor),
        ),
      ),
    );
  }
}

class SequenceGameoverView extends StatelessWidget {
  final SequenceGameState state;

  const SequenceGameoverView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final won = state.score >= state.maxRounds;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.error_outline,
                size: 64,
                color: won ? Colors.amber : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                won ? 'Geschafft!' : 'Falsch!',
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (won) ...[
                const SizedBox(height: 8),
                Text('Du hast alle ${state.maxRounds} Schritte gemeistert.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center),
              ],
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
                    Text('Erreichte Sequenz', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.score} / ${state.maxRounds}',
                      style: textTheme.titleLarge?.copyWith(
                        fontFamily: 'monospace', color: colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text('Regel war', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.rule}', style: textTheme.titleLarge?.copyWith(
                      fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

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

import 'package:flutter/material.dart';

import 'wcst_game_state.dart';

class WcstPlayingView extends StatelessWidget {
  final WcstGameState state;

  const WcstPlayingView({super.key, required this.state});

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
              Icon(Icons.timer_outlined, size: 16,
                color: state.remainingSeconds <= 10
                  ? Colors.red : colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(state.timerDisplay,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: state.remainingSeconds <= 10
                    ? Colors.red : colorScheme.onSurfaceVariant)),
              const SizedBox(width: 16),
              Text('${state.cardsPlayed}/${WcstGameState.totalCards} ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, fontFamily: 'monospace')),
              const SizedBox(width: 12),
              Icon(Icons.check, size: 16, color: Colors.green),
              const SizedBox(width: 4),
              Text('${state.correctCount}', style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(width: 12),
              Icon(Icons.close, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text('${state.errorCount}', style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.red)),
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Instruction
                    Text('Ordne die Karte einer Referenz zu',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 1)),
                    const SizedBox(height: 16),

                    // Reference cards (4 in a row)
                    Row(
                      children: [
                        for (var i = 0; i < 4; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: _referenceCard(i, colorScheme)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Feedback
                    SizedBox(
                      height: 32,
                      child: Center(
                        child: state.feedback == true
                            ? Text('Richtig!', style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold, color: Colors.green))
                            : state.feedback == false
                                ? Text('Falsch', style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold, color: Colors.red))
                                : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Current card to sort
                    _currentCardWidget(colorScheme),
                    const SizedBox(height: 24),

                    // Progress bar
                    SizedBox(
                      width: 200,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: state.cardsPlayed / WcstGameState.totalCards,
                          minHeight: 4,
                          color: colorScheme.primary,
                          backgroundColor: colorScheme.outlineVariant,
                        ),
                      ),
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

  Widget _referenceCard(int index, ColorScheme cs) {
    final ref = referenceCards[index];
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => state.selectReference(index),
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant, width: 2),
            ),
            child: _cardContent(ref, 22),
          ),
        ),
      ),
    );
  }

  Widget _currentCardWidget(ColorScheme cs) {
    final card = state.currentCard;
    Color borderColor = cs.primary;
    if (state.feedback == true) borderColor = Colors.green;
    if (state.feedback == false) borderColor = Colors.red;

    return Container(
      width: 130, height: 170,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(color: borderColor.withValues(alpha: 0.15), blurRadius: 12),
        ],
      ),
      child: _cardContent(card, 32),
    );
  }

  Widget _cardContent(WcstCard card, double iconSize) {
    final color = wcstColorValue(card.color);
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4,
        runSpacing: 4,
        children: [
          for (var i = 0; i < card.count; i++)
            _shapeIcon(card.shape, color, iconSize),
        ],
      ),
    );
  }

  Widget _shapeIcon(CardShape shape, Color color, double size) {
    switch (shape) {
      case CardShape.circle:
        return Container(
          width: size, height: size,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        );
      case CardShape.triangle:
        return CustomPaint(
          size: Size(size, size),
          painter: _TrianglePainter(color),
        );
      case CardShape.star:
        return Icon(Icons.star, size: size, color: color);
      case CardShape.cross:
        return Icon(Icons.close, size: size, color: color);
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}

class WcstResultView extends StatelessWidget {
  final WcstGameState state;

  const WcstResultView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final cats = state.categoriesCompleted;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                cats >= 4 ? Icons.emoji_events
                    : cats >= 2 ? Icons.trending_up : Icons.refresh,
                size: 64,
                color: cats >= 4 ? Colors.amber
                    : cats >= 2 ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 12),
              Text(state.flexibilityRating, style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Main stats
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
                    Row(
                      children: [
                        Expanded(child: _statBox('$cats', 'Kategorien', colorScheme)),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox('${state.accuracy}%', 'Genauigkeit', colorScheme)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _statBoxColored(
                          '${state.correctCount}', 'Richtig', Colors.green, colorScheme)),
                        const SizedBox(width: 8),
                        Expanded(child: _statBoxColored(
                          '${state.errorCount}', 'Fehler', Colors.red, colorScheme)),
                        const SizedBox(width: 8),
                        Expanded(child: _statBoxColored(
                          '${state.perseverativeErrors}', 'Perseverativ', Colors.orange, colorScheme)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Perseverative Fehler zeigen, wie oft du an einer alten Regel '
                'festgehalten hast, obwohl sich die Sortierregel geändert hat.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
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
            fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
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
            fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

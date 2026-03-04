import 'package:flutter/material.dart';

import 'wcst_game_state.dart';

class WcstStartView extends StatelessWidget {
  final WcstGameState state;

  const WcstStartView({super.key, required this.state});

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
              Icon(Icons.category, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('WCST', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Wisconsin Card Sorting Test', style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant)),
              const SizedBox(height: 16),
              Text(
                'Ordne Karten einer der vier Referenzkarten zu. '
                'Die Sortierregel (Farbe, Form oder Anzahl) ist verborgen '
                'und ändert sich automatisch nach einer Reihe richtiger Antworten.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // How it works
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _hintRow(Icons.search, 'Finde die aktuelle Regel durch Ausprobieren',
                      colorScheme.primary, colorScheme),
                    const SizedBox(height: 10),
                    _hintRow(Icons.check, 'Richtig / Falsch Feedback nach jeder Karte',
                      Colors.green, colorScheme),
                    const SizedBox(height: 10),
                    _hintRow(Icons.shuffle, 'Die Regel ändert sich automatisch',
                      Colors.orange, colorScheme),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Visual example
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Two red circles
                    Row(
                      children: [
                        _shapeDot(const Color(0xFFEF4444), 20),
                        const SizedBox(width: 4),
                        _shapeDot(const Color(0xFFEF4444), 20),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.arrow_forward,
                        size: 16, color: colorScheme.onSurfaceVariant),
                    ),
                    // Two green stars
                    Row(
                      children: [
                        Icon(Icons.star, size: 20, color: const Color(0xFF22C55E)),
                        Icon(Icons.star, size: 20, color: const Color(0xFF22C55E)),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text('Anzahl?', style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text('${WcstGameState.totalCards} Karten pro Durchgang',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
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

  Widget _hintRow(IconData icon, String text, Color iconColor, ColorScheme cs) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(
          fontSize: 13, color: cs.onSurfaceVariant))),
      ],
    );
  }

  Widget _shapeDot(Color color, double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

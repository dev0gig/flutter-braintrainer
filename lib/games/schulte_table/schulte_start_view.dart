import 'package:flutter/material.dart';

import 'schulte_game_state.dart';

class SchulteStartView extends StatelessWidget {
  final SchulteGameState state;

  const SchulteStartView({super.key, required this.state});

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
              Icon(Icons.apps, size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8)),
              const SizedBox(height: 16),
              Text('Schulte Table', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'Finde und klicke die Zahlen von '),
                    TextSpan(text: '1', style: TextStyle(
                      fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                    const TextSpan(text: ' bis '),
                    TextSpan(text: '${state.totalNumbers}',
                      style: TextStyle(fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface)),
                    const TextSpan(text: ' so schnell wie möglich.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Grid size
              Align(
                alignment: Alignment.centerLeft,
                child: Text('RASTER', style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: state.gridSize > 3
                          ? () => state.setGridSize(state.gridSize - 1) : null,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${state.gridSize}×${state.gridSize}',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold, color: colorScheme.primary),
                    ),
                    IconButton(
                      onPressed: state.gridSize < 7
                          ? () => state.setGridSize(state.gridSize + 1) : null,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Example
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: GridView.count(
                        crossAxisCount: 3, mainAxisSpacing: 3, crossAxisSpacing: 3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final n in [4, 1, 7, 3, 8, 5, 9, 2, 6])
                            Container(
                              decoration: BoxDecoration(
                                color: n == 1 ? Colors.green : colorScheme.surface,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              alignment: Alignment.center,
                              child: Text('$n', style: TextStyle(
                                fontSize: 10,
                                fontWeight: n == 1 ? FontWeight.bold : FontWeight.normal,
                                color: n == 1 ? Colors.white : colorScheme.onSurfaceVariant,
                              )),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('1 → 2 → 3 ...', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                  ],
                ),
              ),
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

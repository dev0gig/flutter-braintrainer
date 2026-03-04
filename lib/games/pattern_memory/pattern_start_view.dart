import 'package:flutter/material.dart';

import 'pattern_game_state.dart';

class PatternStartView extends StatelessWidget {
  final PatternGameState state;

  const PatternStartView({super.key, required this.state});

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
              Icon(
                Icons.grid_view,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text('Pattern Memory', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Text(
                'Ein Muster wird für kurze Zeit angezeigt. Merke es dir und klicke anschließend die markierten Felder an.',
                style: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Preview time
              _label('MERKZEIT', textTheme, colorScheme),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in [
                    (500, 'Sehr schnell'),
                    (1000, 'Schnell'),
                    (1500, 'Normal'),
                    (2000, 'Langsam'),
                  ])
                    _ChoiceChip(
                      label: entry.$2,
                      selected: state.previewTimeMs == entry.$1,
                      onTap: () => state.setPreviewTime(entry.$1),
                      colorScheme: colorScheme,
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Grid size
              _label('GRÖSSE', textTheme, colorScheme),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final entry in [
                    (5, 5, '5×5'),
                    (5, 7, '5×7'),
                    (5, 9, '5×9'),
                  ]) ...[
                    if (entry.$2 != 5) const SizedBox(width: 8),
                    Expanded(
                      child: _ChoiceChip(
                        label: entry.$3,
                        selected: state.gridRows == entry.$2,
                        onTap: () => state.setGridSize(entry.$1, entry.$2),
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),

              // Example
              _buildExample(context),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text('Starten', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExample(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewActive = {0, 4, 8}; // diagonal

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Preview grid
          Column(
            children: [
              _buildMiniGrid(colorScheme, previewActive, colorScheme.primary),
              const SizedBox(height: 4),
              Text('Merken...', style: TextStyle(
                fontSize: 9,
                color: colorScheme.onSurfaceVariant,
              )),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.arrow_forward, size: 18, color: colorScheme.onSurfaceVariant),
          ),
          // Recall grid
          Column(
            children: [
              _buildMiniGrid(colorScheme, previewActive, Colors.green),
              const SizedBox(height: 4),
              Text('Klicken!', style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniGrid(ColorScheme cs, Set<int> active, Color activeColor) {
    return SizedBox(
      width: 56,
      height: 56,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < 9; i++)
            Container(
              decoration: BoxDecoration(
                color: active.contains(i) ? activeColor : cs.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _label(String text, TextTheme textTheme, ColorScheme colorScheme) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
      ),
    ),
  );
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'n_back_game_state.dart';

class NBackStartView extends StatelessWidget {
  final NBackGameState state;

  const NBackStartView({super.key, required this.state});

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
                Icons.psychology,
                size: 72,
                color: colorScheme.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 16),
              Text('N-Back', style: textTheme.headlineMedium?.copyWith(
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
                    const TextSpan(text: 'Drücke '),
                    TextSpan(
                      text: 'MATCH',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const TextSpan(text: ', wenn die aktuelle Position mit der vor '),
                    TextSpan(
                      text: 'N',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: ' Schritten übereinstimmt.'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // N-Level
              _sectionLabel('N-LEVEL', textTheme, colorScheme),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var n = 1; n <= 4; n++) ...[
                    if (n > 1) const SizedBox(width: 8),
                    Expanded(
                      child: _OptionButton(
                        label: '$n-Back',
                        selected: state.nLevel == n,
                        onTap: () => state.setNLevel(n),
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Speed
              _sectionLabel('GESCHWINDIGKEIT', textTheme, colorScheme),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final entry in [
                    (1500, 'Schnell'),
                    (2500, 'Normal'),
                    (3500, 'Langsam'),
                  ]) ...[
                    if (entry.$1 != 1500) const SizedBox(width: 8),
                    Expanded(
                      child: _OptionButton(
                        label: entry.$2,
                        selected: state.speed == entry.$1,
                        onTap: () => state.setSpeed(entry.$1),
                        colorScheme: colorScheme,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),

              // Trials
              _sectionLabel('DURCHGÄNGE', textTheme, colorScheme),
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
                      onPressed: () => state.setTotalTrials(state.totalTrials - 5),
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '${state.totalTrials}',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    IconButton(
                      onPressed: () => state.setTotalTrials(state.totalTrials + 5),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

    return Transform.rotate(
      angle: -0.02,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMiniGrid(colorScheme, 0),
            const SizedBox(width: 12),
            Text('...', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(width: 12),
            _buildMiniGrid(colorScheme, 0),
            const SizedBox(width: 12),
            Text(
              'MATCH!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniGrid(ColorScheme cs, int activeIdx) {
    return SizedBox(
      width: 48,
      height: 48,
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var i = 0; i < 9; i++)
            Container(
              decoration: BoxDecoration(
                color: i == activeIdx ? cs.primary : cs.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _sectionLabel(String text, TextTheme textTheme, ColorScheme colorScheme) {
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

class _OptionButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _OptionButton({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'schulte_game_state.dart';

class SchultePlayingView extends StatelessWidget {
  final SchulteGameState state;

  const SchultePlayingView({super.key, required this.state});

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
              Text(
                '${state.timerDisplay} s',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: state.gameCompleted
                      ? Colors.green
                      : colorScheme.primary,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Status
        SizedBox(
          height: 32,
          child: Center(
            child: state.gameCompleted
                ? Text('Fertig!', style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.green))
                : state.isGameActive
                    ? RichText(
                        text: TextSpan(
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant),
                          children: [
                            const TextSpan(text: 'Suche: '),
                            TextSpan(text: '${state.nextNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: colorScheme.onSurface)),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(height: 8),

        // Grid
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildGrid(colorScheme, textTheme),
                ),
              ),
            ),
          ),
        ),

        // Controls
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: state.gameCompleted
                ? FilledButton.icon(
                    onPressed: state.resetGame,
                    icon: const Icon(Icons.replay),
                    label: const Text('Nochmal'),
                  )
                : OutlinedButton(
                    onPressed: state.resetGame,
                    child: const Text('Reset'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(ColorScheme colorScheme, TextTheme textTheme) {
    final size = state.gridSize;
    return GridView.count(
      crossAxisCount: size,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < state.cells.length; i++)
          _GridCell(
            number: state.cells[i],
            isCorrectFlash: state.lastCorrectCell == i,
            onTap: () => state.handleCellClick(state.cells[i], i),
            gridSize: size,
            colorScheme: colorScheme,
          ),
      ],
    );
  }
}

class _GridCell extends StatelessWidget {
  final int number;
  final bool isCorrectFlash;
  final VoidCallback onTap;
  final int gridSize;
  final ColorScheme colorScheme;

  const _GridCell({
    required this.number,
    required this.isCorrectFlash,
    required this.onTap,
    required this.gridSize,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isCorrectFlash ? Colors.green : colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isCorrectFlash ? Colors.green.shade600 : colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              fontSize: gridSize <= 5 ? 20 : 16,
              fontWeight: FontWeight.bold,
              color: isCorrectFlash ? Colors.white : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

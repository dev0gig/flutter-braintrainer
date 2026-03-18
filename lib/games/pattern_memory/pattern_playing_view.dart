import 'package:flutter/material.dart';

import 'pattern_game_state.dart';

class PatternPlayingView extends StatelessWidget {
  final PatternGameState state;

  const PatternPlayingView({super.key, required this.state});

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
              Text('Level ', style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant)),
              Text('${state.level}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: colorScheme.primary)),
            ],
          ),
        ),

        // Status message
        SizedBox(
          height: 32,
          child: Center(
            child: _buildStatusMessage(textTheme, colorScheme),
          ),
        ),

        // Grid
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: _buildGrid(colorScheme),
              ),
            ),
          ),
        ),

        // Info
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '${state.squaresCount} Felder',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(TextTheme textTheme, ColorScheme colorScheme) {
    switch (state.phase) {
      case PatternPhase.preview:
        return Text(
          'Muster merken...',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      case PatternPhase.recall:
        return Text(
          'Muster eingeben',
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        );
      case PatternPhase.result:
        if (state.wrongSelection == null) {
          return Text(
            'Richtig!',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          return Text(
            'Falsch! Neustart...',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          );
        }
    }
  }

  Widget _buildGrid(ColorScheme colorScheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = state.gridCols;
        final rows = state.gridRows;
        const spacing = 6.0;

        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        final cellWidth = (availableWidth - (cols - 1) * spacing) / cols;
        final cellHeight = (availableHeight - (rows - 1) * spacing) / rows;
        final cellSize = cellWidth < cellHeight ? cellWidth : cellHeight;

        final gridWidth = cellSize * cols + (cols - 1) * spacing;
        final gridHeight = cellSize * rows + (rows - 1) * spacing;

        return SizedBox(
          width: gridWidth,
          height: gridHeight,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var i = 0; i < state.gridSize; i++)
                GestureDetector(
                  onTap: () => state.handleCellTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: _cellColor(i, colorScheme),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _cellBorderColor(i, colorScheme),
                      ),
                      boxShadow: _cellShadow(i, colorScheme),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Color _cellColor(int index, ColorScheme cs) {
    final isTarget = state.targetPattern.contains(index);
    final isSelected = state.userSelection.contains(index);
    final isWrong = state.wrongSelection == index;

    switch (state.phase) {
      case PatternPhase.preview:
        return isTarget ? cs.primary : cs.surfaceContainerHighest;
      case PatternPhase.recall:
        if (isSelected && isTarget) return Colors.green;
        return cs.surfaceContainerHighest;
      case PatternPhase.result:
        if (isWrong) return Colors.red;
        if (isSelected && isTarget) return Colors.green;
        if (isTarget && !isSelected) {
          return cs.primary.withValues(alpha: 0.5);
        }
        return cs.surfaceContainerHighest;
    }
  }

  Color _cellBorderColor(int index, ColorScheme cs) {
    final isTarget = state.targetPattern.contains(index);
    final isSelected = state.userSelection.contains(index);
    final isWrong = state.wrongSelection == index;

    switch (state.phase) {
      case PatternPhase.recall:
        if (isSelected && isTarget) return Colors.green;
        return cs.outlineVariant;
      case PatternPhase.result:
        if (isWrong) return Colors.red;
        if (isSelected && isTarget) return Colors.green;
        return cs.outlineVariant;
      default:
        return cs.outlineVariant;
    }
  }

  List<BoxShadow>? _cellShadow(int index, ColorScheme cs) {
    if (state.phase == PatternPhase.preview &&
        state.targetPattern.contains(index)) {
      return [
        BoxShadow(
          color: cs.primary.withValues(alpha: 0.4),
          blurRadius: 12,
        ),
      ];
    }
    return null;
  }
}

class PatternGameoverView extends StatelessWidget {
  final PatternGameState state;

  const PatternGameoverView({super.key, required this.state});

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
                state.completedLevels >= 10 ? Icons.emoji_events
                    : state.completedLevels >= 5 ? Icons.trending_up : Icons.refresh,
                size: 64,
                color: state.completedLevels >= 10 ? Colors.amber
                    : state.completedLevels >= 5 ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 16),
              Text('Zeit abgelaufen!', style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold)),
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
                    Text('Geschaffte Level', style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text('${state.completedLevels}',
                      style: textTheme.displaySmall?.copyWith(
                        fontFamily: 'monospace', color: colorScheme.primary,
                        fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: state.startGame,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48)),
                child: const Text('Nochmal'),
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

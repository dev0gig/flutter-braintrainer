import 'package:flutter/material.dart';

import 'sudoku_game_state.dart';

class SudokuPlayingView extends StatelessWidget {
  final SudokuGameState state;

  const SudokuPlayingView({super.key, required this.state});

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
                state.difficultyLabel,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),

        // Status
        SizedBox(
          height: 28,
          child: Center(
            child: state.isComplete
                ? Text('Rätsel gelöst!', style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.green))
                : const SizedBox.shrink(),
          ),
        ),

        // Grid
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxBoard = (constraints.biggest.shortestSide - 24).clamp(200.0, 600.0);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxBoard),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildGrid(colorScheme, textTheme),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Controls
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Note mode + Clear
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        selected: state.isNoteMode,
                        onSelected: (_) => state.toggleNoteMode(),
                        label: const Text('Notizen'),
                        avatar: Icon(
                          state.isNoteMode ? Icons.edit : Icons.edit_outlined,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ActionChip(
                        onPressed: state.clearCell,
                        label: const Text('Löschen'),
                        avatar: const Icon(Icons.backspace_outlined, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Numpad 3x3
                  _buildNumpad(colorScheme, textTheme),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGrid(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.onSurface, width: 2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
        ),
        itemCount: 81,
        itemBuilder: (context, index) {
          return _buildCell(index, colorScheme, textTheme);
        },
      ),
    );
  }

  Widget _buildCell(int index, ColorScheme colorScheme, TextTheme textTheme) {
    final row = index ~/ 9;
    final col = index % 9;
    final value = state.grid[index];
    final isInitial = state.initialGrid[index];
    final isSelected = state.selectedCell == index;
    final isHighlighted = state.isHighlighted(index);
    final hasError = state.isError(index);
    final cellNotes = state.notes[index];

    // Border widths for 3x3 block boundaries
    final rightBorder = (col % 3 == 2 && col != 8) ? 1.5 : 0.5;
    final bottomBorder = (row % 3 == 2 && row != 8) ? 1.5 : 0.5;
    final leftBorder = col == 0 ? 0.0 : 0.0;
    final topBorder = row == 0 ? 0.0 : 0.0;

    Color bgColor;
    if (isSelected) {
      bgColor = colorScheme.primaryContainer;
    } else if (hasError) {
      bgColor = colorScheme.errorContainer;
    } else if (isHighlighted) {
      bgColor = colorScheme.primaryContainer.withValues(alpha: 0.4);
    } else {
      bgColor = colorScheme.surface;
    }

    Color textColor;
    if (hasError) {
      textColor = colorScheme.error;
    } else if (isInitial) {
      textColor = colorScheme.onSurface;
    } else {
      textColor = colorScheme.primary;
    }

    return GestureDetector(
      onTap: () => state.selectCell(index),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              width: topBorder,
            ),
            left: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              width: leftBorder,
            ),
            right: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: rightBorder > 1 ? 0.8 : 0.3),
              width: rightBorder,
            ),
            bottom: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: bottomBorder > 1 ? 0.8 : 0.3),
              width: bottomBorder,
            ),
          ),
        ),
        child: value != 0
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '$value',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                      color: textColor,
                    ),
                  ),
                ),
              )
            : cellNotes.isNotEmpty
                ? _buildNotesGrid(cellNotes, colorScheme)
                : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildNotesGrid(List<int> cellNotes, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(1),
      child: GridView.count(
        crossAxisCount: 3,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(9, (i) {
          final num = i + 1;
          return Center(
            child: cellNotes.contains(num)
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$num',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ),
    );
  }

  Widget _buildNumpad(ColorScheme colorScheme, TextTheme textTheme) {
    return GridView.count(
      crossAxisCount: 9,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      children: List.generate(9, (i) {
        final num = i + 1;
        return Material(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => state.inputNumber(num),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              alignment: Alignment.center,
              child: Text(
                '$num',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

import 'chess_game_state.dart';

const _pieceIcons = {
  'p': Symbols.chess_pawn,
  'n': Symbols.chess_knight,
  'b': Symbols.chess_bishop,
  'r': Symbols.chess_rook,
  'q': Symbols.chess_queen,
  'k': Symbols.chess_king_2,
};

class ChessPlayingView extends StatelessWidget {
  final ChessGameState state;

  const ChessPlayingView({super.key, required this.state});

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
                tooltip: 'Zurück',
              ),
              const Spacer(),
              _buildStatusText(colorScheme, textTheme),
              const Spacer(),
              _buildControls(colorScheme),
            ],
          ),
        ),

        // Puzzle rating badge
        if (state.gameMode == ChessGameMode.puzzle &&
            state.currentPuzzle != null &&
            state.puzzleStatus == 'playing')
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Rating: ${state.currentPuzzle!.rating}',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),

        // Board
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _buildBoard(colorScheme),
                ),
              ),
            ),
          ),
        ),

        // Promotion dialog
        if (state.showPromotion)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final type in ['q', 'r', 'b', 'n'])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () => state.promote(type),
                      style: OutlinedButton.styleFrom(
                        fixedSize: const Size(52, 52),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(_pieceIcons[type], size: 28,
                        color: colorScheme.onSurface),
                    ),
                  ),
              ],
            ),
          ),

        // Puzzle solved overlay
        if (state.gameMode == ChessGameMode.puzzle &&
            state.puzzleStatus == 'solved')
          _buildPuzzleSolved(colorScheme, textTheme),

        // Game over overlay (computer mode)
        if (state.gameMode == ChessGameMode.computer && state.chess.game_over)
          _buildGameOver(colorScheme, textTheme),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildStatusText(ColorScheme colorScheme, TextTheme textTheme) {
    if (state.gameMode == ChessGameMode.puzzle) {
      if (state.thinking) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Text('Gegner antwortet...',
                style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant)),
          ],
        );
      }
      if (state.puzzleFeedback == 'wrong') {
        return Text('Falsch – versuche es nochmal',
            style: textTheme.bodySmall?.copyWith(color: Colors.red));
      }
      if (state.puzzleFeedback == 'solved') {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text('Richtig!',
                style: textTheme.bodySmall?.copyWith(color: Colors.green)),
          ],
        );
      }
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Finde den besten Zug!',
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(width: 12),
          Text('${state.puzzleScore}/${state.puzzleTotal + 1}',
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
        ],
      );
    }

    // Computer mode
    if (state.thinking) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16, height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Text('Computer denkt...',
              style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
        ],
      );
    }
    final display = state.status.isNotEmpty ? state.status : state.turnLabel;
    return Text(display, style: textTheme.bodySmall?.copyWith(
        color: colorScheme.onSurfaceVariant));
  }

  Widget _buildControls(ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.gameMode == ChessGameMode.puzzle)
          TextButton(
            onPressed: state.puzzleStatus == 'solved' ? null : state.skipPuzzle,
            child: const Text('Überspringen'),
          )
        else
          IconButton(
            onPressed: state.undo,
            icon: const Icon(Icons.undo),
            tooltip: 'Rückgängig',
          ),
        IconButton(
          onPressed: state.returnToStart,
          icon: const Icon(Icons.restart_alt),
          tooltip: 'Neues Spiel',
        ),
      ],
    );
  }

  Widget _buildBoard(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final square = state.squareAt(index);
          final piece = state.pieceAt(square);
          final isLight = state.isLightSquare(index);
          final isSelected = state.isSelected(square);
          final isLegal = state.isLegal(square);
          final isLast = state.isLastMove(square);

          Color bgColor;
          if (isSelected) {
            bgColor = colorScheme.primary.withValues(alpha: 0.35);
          } else if (isLast) {
            bgColor = colorScheme.primary.withValues(alpha: 0.2);
          } else if (isLight) {
            bgColor = const Color(0xFFF0D9B5);
          } else {
            bgColor = const Color(0xFFB58863);
          }

          return GestureDetector(
            onTap: () => state.onClick(square),
            child: Container(
              color: bgColor,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (piece != null)
                    FittedBox(
                      fit: BoxFit.contain,
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          _pieceIcons[piece.type],
                          fill: 1,
                          color: piece.isWhite
                              ? const Color(0xFFFFF8E7)
                              : const Color(0xFF1A1A1A),
                          size: 32,
                          weight: 300,
                          shadows: piece.isWhite
                              ? const [
                                  Shadow(color: Color(0xAA000000), blurRadius: 0.5),
                                  Shadow(color: Color(0x66000000), blurRadius: 2),
                                ]
                              : const [
                                  Shadow(color: Color(0x33000000), blurRadius: 1),
                                ],
                        ),
                      ),
                    ),
                  if (isLegal && piece == null)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary.withValues(alpha: 0.4),
                      ),
                    ),
                  if (isLegal && piece != null)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.4),
                          width: 3,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPuzzleSolved(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 8),
          Text('Richtig!', style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${state.puzzleScore} von ${state.puzzleTotal + 1} gelöst',
              style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: state.nextPuzzle,
                child: const Text('Nächstes Puzzle'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: state.returnToStart,
                child: const Text('Menü'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 48, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(state.status, style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: state.startGame,
                child: const Text('Nochmal'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: state.returnToStart,
                child: const Text('Menü'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

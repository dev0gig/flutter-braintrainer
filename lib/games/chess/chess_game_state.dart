import 'dart:math';

import 'package:chess/chess.dart' as ch;
import 'package:flutter/foundation.dart';

import '../../services/game_state_service.dart';
import '../../services/score_service.dart';
import 'chess_puzzles.dart';

enum ChessGameMode { computer, puzzle }

enum ChessDifficulty { easy, medium, hard }

enum ChessPhase { start, playing }

/// Piece info: (type, isWhite) — type is one of p, n, b, r, q, k.
typedef PieceInfo = ({String type, bool isWhite});

const _pieceValues = {'p': 1, 'n': 3, 'b': 3, 'r': 5, 'q': 9, 'k': 0};

final _files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];

class ChessGameState extends ChangeNotifier {
  ch.Chess chess = ch.Chess();

  ChessPhase phase = ChessPhase.start;
  ChessGameMode gameMode = ChessGameMode.computer;
  ChessDifficulty difficulty = ChessDifficulty.medium;
  PuzzleCategory puzzleCategory = PuzzleCategory.mateIn1;
  Map<PuzzleCategory, List<ChessPuzzle>>? _puzzleData;

  String? selected;
  List<String> legalTargets = [];
  ({String from, String to})? lastMove;
  String status = '';
  bool showPromotion = false;
  ({String from, String to})? pendingPromotion;
  bool thinking = false;

  // Puzzle state
  ChessPuzzle? currentPuzzle;
  int puzzleSolutionIndex = 0;
  String puzzleStatus = 'playing'; // playing, solved, failed
  int puzzleScore = 0;
  int puzzleTotal = 0;
  String puzzleFeedback = '';
  String playerColor = 'w'; // 'w' or 'b'
  final List<int> _usedPuzzleIndices = [];

  bool get isFlipped => playerColor == 'b';

  // --- Board helpers ---

  String squareAt(int index) {
    final row = index ~/ 8;
    final col = index % 8;
    if (isFlipped) {
      return '${_files[7 - col]}${row + 1}';
    }
    return '${_files[col]}${8 - row}';
  }

  bool isLightSquare(int index) {
    final row = index ~/ 8;
    final col = index % 8;
    return (row + col) % 2 == 0;
  }

  PieceInfo? pieceAt(String square) {
    final p = chess.get(square);
    if (p == null) return null;
    return (type: p.type.toString().toLowerCase(), isWhite: p.color == ch.Color.WHITE);
  }

  bool isSelected(String square) => selected == square;
  bool isLegal(String square) => legalTargets.contains(square);

  bool isLastMove(String square) =>
      lastMove?.from == square || lastMove?.to == square;

  String get turnLabel =>
      chess.turn == ch.Color.WHITE ? 'Weiß am Zug' : 'Schwarz am Zug';

  // --- Click handling ---

  void onClick(String square) {
    if (showPromotion || thinking) return;

    if (gameMode == ChessGameMode.puzzle) {
      if (puzzleStatus != 'playing') return;
      final turnColor = chess.turn == ch.Color.WHITE ? 'w' : 'b';
      if (turnColor != playerColor) return;
    } else {
      if (chess.game_over) return;
      if (chess.turn != ch.Color.WHITE) return;
    }

    final p = chess.get(square);

    if (selected != null && legalTargets.contains(square)) {
      if (gameMode == ChessGameMode.puzzle) {
        _tryPuzzleMove(selected!, square);
      } else {
        _tryMove(selected!, square);
      }
      return;
    }

    if (p != null && p.color == chess.turn) {
      selected = square;
      final moves = chess.moves({'square': square, 'verbose': true});
      legalTargets = moves.map((m) => m['to'] as String).toList();
    } else {
      selected = null;
      legalTargets = [];
    }
    notifyListeners();
  }

  void _tryMove(String from, String to) {
    final p = chess.get(from);
    if (p != null &&
        p.type == ch.PieceType.PAWN &&
        (to[1] == '8' || to[1] == '1')) {
      pendingPromotion = (from: from, to: to);
      showPromotion = true;
      notifyListeners();
      return;
    }
    _makeMove(from, to);
  }

  void _makeMove(String from, String to, [String? promotion]) {
    final moveArgs = <String, String>{'from': from, 'to': to};
    if (promotion != null) moveArgs['promotion'] = promotion;
    final result = chess.move(moveArgs);
    if (result) lastMove = (from: from, to: to);
    selected = null;
    legalTargets = [];
    _updateStatus();

    if (gameMode == ChessGameMode.computer &&
        !chess.game_over &&
        chess.turn == ch.Color.BLACK) {
      thinking = true;
      notifyListeners();
      Future.delayed(const Duration(milliseconds: 300), () {
        _computerMove();
        thinking = false;
        if (chess.game_over) {
          GameStateService.clearState('chess');
        } else {
          _saveState();
        }
        notifyListeners();
      });
      return;
    }
    if (chess.game_over) {
      GameStateService.clearState('chess');
    } else {
      _saveState();
    }
    notifyListeners();
  }

  void promote(String piece) {
    if (pendingPromotion != null) {
      if (gameMode == ChessGameMode.puzzle) {
        _executePuzzleMove(
            pendingPromotion!.from, pendingPromotion!.to, piece);
      } else {
        _makeMove(pendingPromotion!.from, pendingPromotion!.to, piece);
      }
    }
    showPromotion = false;
    pendingPromotion = null;
    notifyListeners();
  }

  void _updateStatus() {
    if (chess.in_checkmate) {
      status = chess.turn == ch.Color.WHITE
          ? 'Schachmatt – Schwarz gewinnt!'
          : 'Schachmatt – Weiß gewinnt!';
    } else if (chess.in_draw) {
      status = 'Remis!';
    } else if (chess.in_check) {
      status = 'Schach!';
    } else {
      status = '';
    }
  }

  // --- Puzzle mode ---

  void _loadPuzzle() {
    final puzzles = _puzzleData![puzzleCategory]!;
    if (_usedPuzzleIndices.length >= puzzles.length) {
      _usedPuzzleIndices.clear();
    }

    final rng = Random();
    int idx;
    do {
      idx = rng.nextInt(puzzles.length);
    } while (_usedPuzzleIndices.contains(idx));

    _usedPuzzleIndices.add(idx);
    currentPuzzle = puzzles[idx];
    puzzleStatus = 'playing';
    puzzleFeedback = '';

    chess = ch.Chess.fromFEN(currentPuzzle!.fen);

    // Lichess puzzles: first move is the opponent's setup move.
    // Play it automatically, then the player solves from index 1.
    final setupUci = currentPuzzle!.moves[0];
    final from = setupUci.substring(0, 2);
    final to = setupUci.substring(2, 4);
    final promo = setupUci.length > 4 ? setupUci[4] : null;
    final moveArgs = <String, String>{'from': from, 'to': to};
    if (promo != null) moveArgs['promotion'] = promo;
    chess.move(moveArgs);
    lastMove = (from: from, to: to);
    puzzleSolutionIndex = 1;

    // Player plays the color that moves after the setup move
    playerColor = chess.turn == ch.Color.WHITE ? 'w' : 'b';
    selected = null;
    legalTargets = [];
    status = '';
  }

  void nextPuzzle() {
    puzzleTotal++;
    _loadPuzzle();
    notifyListeners();
  }

  void _tryPuzzleMove(String from, String to) {
    final p = chess.get(from);
    if (p != null &&
        p.type == ch.PieceType.PAWN &&
        (to[1] == '8' || to[1] == '1')) {
      pendingPromotion = (from: from, to: to);
      showPromotion = true;
      notifyListeners();
      return;
    }
    _executePuzzleMove(from, to);
  }

  void _executePuzzleMove(String from, String to, [String? promotion]) {
    if (currentPuzzle == null) return;

    final expectedUci = currentPuzzle!.moves[puzzleSolutionIndex];
    final moveUci = '$from$to${promotion ?? ''}';

    if (moveUci != expectedUci) {
      puzzleFeedback = 'wrong';
      selected = null;
      legalTargets = [];
      notifyListeners();
      return;
    }

    // Correct move
    puzzleFeedback = '';
    final moveArgs = <String, String>{'from': from, 'to': to};
    if (promotion != null) moveArgs['promotion'] = promotion;
    final result = chess.move(moveArgs);
    if (result) lastMove = (from: from, to: to);
    selected = null;
    legalTargets = [];
    puzzleSolutionIndex++;

    // Check if puzzle is complete
    if (puzzleSolutionIndex >= currentPuzzle!.moves.length) {
      puzzleStatus = 'solved';
      puzzleScore++;
      puzzleFeedback = 'solved';
      ScoreService.saveScore(ScoreEntry(
        gameId: 'chess',
        score: puzzleScore,
        date: DateTime.now(),
        difficulty: puzzleCategory.name,
        settings: {'mode': gameMode.name, 'category': puzzleCategory.name},
      ));
      notifyListeners();
      return;
    }

    // Auto-play opponent response
    thinking = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 400), () {
      _playPuzzleOpponentMove();
      thinking = false;
      notifyListeners();
    });
  }

  void _playPuzzleOpponentMove() {
    if (currentPuzzle == null) return;
    final opponentUci = currentPuzzle!.moves[puzzleSolutionIndex];

    final from = opponentUci.substring(0, 2);
    final to = opponentUci.substring(2, 4);
    final promotion = opponentUci.length > 4 ? opponentUci[4] : null;

    final moveArgs = <String, String>{'from': from, 'to': to};
    if (promotion != null) moveArgs['promotion'] = promotion;
    final result = chess.move(moveArgs);
    if (result) lastMove = (from: from, to: to);
    puzzleSolutionIndex++;

    // Check if puzzle complete after opponent move
    if (puzzleSolutionIndex >= currentPuzzle!.moves.length) {
      puzzleStatus = 'solved';
      puzzleScore++;
      puzzleFeedback = 'solved';
      ScoreService.saveScore(ScoreEntry(
        gameId: 'chess',
        score: puzzleScore,
        date: DateTime.now(),
        difficulty: puzzleCategory.name,
        settings: {'mode': gameMode.name, 'category': puzzleCategory.name},
      ));
    }
  }

  void skipPuzzle() {
    puzzleTotal++;
    _loadPuzzle();
    notifyListeners();
  }

  // --- Computer AI ---

  void _computerMove() {
    final depth = switch (difficulty) {
      ChessDifficulty.easy => 1,
      ChessDifficulty.medium => 2,
      ChessDifficulty.hard => 3,
    };

    final moves = chess.moves({'verbose': true});
    if (moves.isEmpty) return;

    var bestMove = moves[0];
    var bestScore = -999999.0;
    final rng = Random();

    for (final move in moves) {
      chess.move(move['san'] as String);
      final score = -_minimax(depth - 1, -999999.0, 999999.0, false);
      chess.undo();

      if (score > bestScore || (score == bestScore && rng.nextBool())) {
        bestScore = score;
        bestMove = move;
      }
    }

    chess.move(bestMove['san'] as String);
    lastMove = (from: bestMove['from'] as String, to: bestMove['to'] as String);
    _updateStatus();
  }

  double _minimax(int depth, double alpha, double beta, bool isMax) {
    if (depth == 0 || chess.game_over) return _evaluate();

    final moves = chess.moves({'verbose': true});

    if (isMax) {
      var max = -999999.0;
      for (final m in moves) {
        chess.move(m['san'] as String);
        max = _max(max, _minimax(depth - 1, alpha, beta, false));
        chess.undo();
        alpha = _max(alpha, max);
        if (beta <= alpha) break;
      }
      return max;
    } else {
      var min = 999999.0;
      for (final m in moves) {
        chess.move(m['san'] as String);
        min = _min(min, _minimax(depth - 1, alpha, beta, true));
        chess.undo();
        beta = _min(beta, min);
        if (beta <= alpha) break;
      }
      return min;
    }
  }

  double _max(double a, double b) => a > b ? a : b;
  double _min(double a, double b) => a < b ? a : b;

  double _evaluate() {
    if (chess.in_checkmate) {
      return chess.turn == ch.Color.BLACK ? 9999 : -9999;
    }
    if (chess.in_draw) return 0;

    var score = 0.0;
    // Iterate all 64 squares
    for (var r = 0; r < 8; r++) {
      for (var c = 0; c < 8; c++) {
        final square = '${_files[c]}${8 - r}';
        final p = chess.get(square);
        if (p == null) continue;
        final val = _pieceValues[p.type.toString().toLowerCase()] ?? 0;
        score += p.color == ch.Color.BLACK ? val : -val;
      }
    }
    return score;
  }

  // --- Controls ---

  void undo() {
    chess.undo(); // undo computer move
    chess.undo(); // undo player move
    lastMove = null;
    selected = null;
    legalTargets = [];
    _updateStatus();
    notifyListeners();
    _saveState();
  }

  Future<void> startGame() async {
    chess = ch.Chess();
    selected = null;
    legalTargets = [];
    lastMove = null;
    status = '';
    thinking = false;
    playerColor = 'w';
    phase = ChessPhase.playing;

    if (gameMode == ChessGameMode.puzzle) {
      puzzleScore = 0;
      puzzleTotal = 0;
      _usedPuzzleIndices.clear();
      _puzzleData ??= await loadPuzzles();
      _loadPuzzle();
    }
    notifyListeners();
    _saveState();
  }

  void returnToStart() {
    chess = ch.Chess();
    selected = null;
    legalTargets = [];
    lastMove = null;
    status = '';
    thinking = false;
    playerColor = 'w';
    currentPuzzle = null;
    puzzleStatus = 'playing';
    puzzleFeedback = '';
    phase = ChessPhase.start;
    notifyListeners();
  }

  Future<bool> tryResume() async {
    final data = await GameStateService.loadState('chess');
    if (data == null) return false;

    chess = ch.Chess.fromFEN(data['fen'] as String);
    difficulty = ChessDifficulty.values.byName(data['difficulty'] as String);
    gameMode = ChessGameMode.computer;
    playerColor = data['playerColor'] as String;
    if (data['lastMoveFrom'] != null) {
      lastMove = (from: data['lastMoveFrom'] as String, to: data['lastMoveTo'] as String);
    } else {
      lastMove = null;
    }
    selected = null;
    legalTargets = [];
    thinking = false;
    _updateStatus();
    phase = ChessPhase.playing;
    notifyListeners();
    return true;
  }

  void _saveState() {
    if (gameMode != ChessGameMode.computer) return;
    if (phase != ChessPhase.playing || chess.game_over) return;
    GameStateService.saveState('chess', {
      'fen': chess.fen,
      'difficulty': difficulty.name,
      'playerColor': playerColor,
      if (lastMove != null) 'lastMoveFrom': lastMove!.from,
      if (lastMove != null) 'lastMoveTo': lastMove!.to,
    });
  }

  void setGameMode(ChessGameMode mode) {
    gameMode = mode;
    notifyListeners();
  }

  void setDifficulty(ChessDifficulty d) {
    difficulty = d;
    notifyListeners();
  }

  void setPuzzleCategory(PuzzleCategory c) {
    puzzleCategory = c;
    notifyListeners();
  }
}

class ChessPuzzle {
  final String fen;
  final List<String> solution;
  final String? description;

  const ChessPuzzle({
    required this.fen,
    required this.solution,
    this.description,
  });
}

// Easy: Mate in 1 — single correct move delivers checkmate
const List<ChessPuzzle> easyPuzzles = [
  ChessPuzzle(
    fen: '6k1/5ppp/8/8/8/8/1Q6/K7 w - - 0 1',
    solution: ['b2g7'],
    description: 'Dame liefert Matt',
  ),
  ChessPuzzle(
    fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 0 1',
    solution: ['h5f7'],
    description: 'Schäfermatt',
  ),
  ChessPuzzle(
    fen: '6k1/5ppp/8/8/8/8/5PPP/4R1K1 w - - 0 1',
    solution: ['e1e8'],
    description: 'Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: 'rnbqkbnr/ppppp2p/6p1/5p1Q/4P3/8/PPPP1PPP/RNB1KBNR w KQkq - 0 1',
    solution: ['h5e8'],
    description: 'Dame matt auf e8',
  ),
  ChessPuzzle(
    fen: '5rk1/5ppp/8/8/8/2B5/5PPP/4R1K1 w - - 0 1',
    solution: ['e1e8'],
    description: 'Grundreihenmatt mit Turmopfer',
  ),
  ChessPuzzle(
    fen: 'r4rk1/ppp2ppp/8/8/8/8/PPP2PPP/R3R1K1 w - - 0 1',
    solution: ['e1e8'],
    description: 'Turm liefert Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: '6k1/pppppppp/8/8/8/8/PPPPPPPP/R5K1 w - - 0 1',
    solution: ['a1a8'],
    description: 'Turm-Matt auf offener Linie',
  ),
  ChessPuzzle(
    fen: 'k7/8/1K6/8/8/8/8/1R6 w - - 0 1',
    solution: ['b1a1'],
    description: 'Turm liefert Matt am Rand',
  ),
  ChessPuzzle(
    fen: '3qk3/8/8/8/8/5B2/8/3QK3 w - - 0 1',
    solution: ['d1d8'],
    description: 'Damentausch erzwingt Matt',
  ),
  ChessPuzzle(
    fen: '5r1k/6pp/8/8/8/8/1Q6/K7 w - - 0 1',
    solution: ['b2g7'],
    description: 'Dame matt auf g7',
  ),
  ChessPuzzle(
    fen: 'r1b1k2r/ppppqppp/2n2n2/2b5/8/8/PPPP1PPP/RNBQR1K1 w kq - 0 1',
    solution: ['e1e7'],
    description: 'Turm schlägt Dame mit Schach',
  ),
  ChessPuzzle(
    fen: '6rk/5Npp/8/8/8/8/8/7K w - - 0 1',
    solution: ['f7g5'],
    description: 'Springermatt – Ersticktes Matt',
  ),
  ChessPuzzle(
    fen: 'k7/pp6/8/8/8/8/8/1RK5 w - - 0 1',
    solution: ['b1b8'],
    description: 'Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: 'r2qk2r/ppp2ppp/2n5/3Np1Q1/2B5/8/PPP2PPP/R3K2R w KQkq - 0 1',
    solution: ['g5f6'],
    description: 'Dame auf f6 gibt Matt',
  ),
  ChessPuzzle(
    fen: '4k3/8/4K3/8/8/8/8/4R3 w - - 0 1',
    solution: ['e1e8'],
    description: 'Einfaches Turmmatt (Reihe 8 blockiert, König auf e6 kontrolliert)',
  ),
  ChessPuzzle(
    fen: '2kr4/ppp5/8/8/8/8/8/2KR4 w - - 0 1',
    solution: ['d1d8'],
    description: 'Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: 'r3k3/ppppp2r/5B2/8/8/8/8/4K2R w Kq - 0 1',
    solution: ['h1h7'],
    description: 'Turm schlägt Turm – Grundreihenmatt droht nicht, aber h7 matt',
  ),
  ChessPuzzle(
    fen: '5bk1/5p1p/4pPpQ/8/8/8/5PPP/6K1 w - - 0 1',
    solution: ['h6g7'],
    description: 'Dame auf g7 matt',
  ),
  ChessPuzzle(
    fen: 'r1bq1rk1/pppp1Qpp/2n2n2/2b1p3/2B1P3/8/PPPP1PPP/RNB1K1NR w KQ - 0 1',
    solution: ['f7g8'],
    description: 'Dame nimmt auf g8 – Matt (Dame gedeckt durch Lc4)',
  ),
  ChessPuzzle(
    fen: '6k1/5p1p/6pQ/8/8/8/5PPP/6K1 w - - 0 1',
    solution: ['h6g7'],
    description: 'Dame liefert Matt auf g7',
  ),
];

// Medium: Mate in 2 — player move → opponent response → player delivers mate
const List<ChessPuzzle> mediumPuzzles = [
  ChessPuzzle(
    fen: '2r3k1/5ppp/8/8/8/8/1Q3PPP/4R1K1 w - - 0 1',
    solution: ['b2b7', 'c8c1', 'e1c1'],
    description: 'Turmopfer auf Grundreihe',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/5Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 1',
    solution: ['f3f7', 'e8d8', 'f7f8'],
    description: 'Dame dringt ein über f7',
  ),
  ChessPuzzle(
    fen: '6k1/pp3ppp/8/8/1b6/8/PP1r1PPP/R2Q1RK1 w - - 0 1',
    solution: ['d1d2', 'b4d2', 'a1a8'],
    description: 'Abtausch führt zu Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: 'r4rk1/pppb1ppp/4p3/8/6q1/3B4/PPPQ1P1P/R4RK1 w - - 0 1',
    solution: ['d3h7', 'g8h7', 'd2h6'],
    description: 'Läuferopfer auf h7 eröffnet Matt',
  ),
  ChessPuzzle(
    fen: '6k1/5ppp/4p3/8/8/4B3/5PPP/2Q3K1 w - - 0 1',
    solution: ['c1c8', 'g8h8', 'e3g5'],
    description: 'Dame + Läufer Mattangriff',
  ),
  ChessPuzzle(
    fen: 'r1b1k1nr/ppppqppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 0 1',
    solution: ['h5f7', 'e7f7', 'c4f7'],
    description: 'Doppelangriff über f7',
  ),
  ChessPuzzle(
    fen: '3r2k1/pp3ppp/8/8/8/1B6/PP3PPP/4R1K1 w - - 0 1',
    solution: ['e1e8', 'd8e8', 'b3f7'],
    description: 'Turmabtausch und Matt mit Läufer',
  ),
  ChessPuzzle(
    fen: 'r3k2r/ppp2ppp/2nqbn2/2bpp3/8/3B1Q2/PPPP1PPP/RNB1K1NR w KQkq - 0 1',
    solution: ['f3f6', 'd6f6', 'd3h7'],
    description: 'Damentausch und Läufermatt',
  ),
  ChessPuzzle(
    fen: '2r1r1k1/5ppp/p7/1p6/8/1B6/PPP2PPP/2KR3R w - - 0 1',
    solution: ['d1d8', 'e8d8', 'h1d1'],
    description: 'Turmabtausch und Matt auf d-Linie',
  ),
  ChessPuzzle(
    fen: '6k1/5ppp/8/4N3/8/8/5PPP/2Q3K1 w - - 0 1',
    solution: ['e5f7', 'g8h8', 'c1c8'],
    description: 'Springerangriff eröffnet Matt',
  ),
  ChessPuzzle(
    fen: 'r3kb1r/ppppqppp/5n2/4N3/8/8/PPPPQPPP/RNB1KB1R w KQkq - 0 1',
    solution: ['e5f7', 'e7e2', 'f7d8'],
    description: 'Springergabel gewinnt Dame',
  ),
  ChessPuzzle(
    fen: 'r2qk2r/ppp1bppp/2n5/3pN3/3Pn3/8/PPP1QPPP/R1B1KB1R w KQkq - 0 1',
    solution: ['e5c6', 'b7c6', 'e2e4'],
    description: 'Springer räumt, Dame erobert',
  ),
  ChessPuzzle(
    fen: '2kr4/ppp3pp/8/3q4/8/2B5/PP3PPP/R4RK1 w - - 0 1',
    solution: ['a1a7', 'd5d1', 'f1d1'],
    description: 'Turm dringt ein',
  ),
  ChessPuzzle(
    fen: 'r3k2r/1pp2ppp/p1pb4/4p3/4P1b1/3P1N2/PPP1BPPP/RNBQK2R w KQkq - 0 1',
    solution: ['f3e5', 'd6e5', 'e2g4'],
    description: 'Springer öffnet Diagonale',
  ),
  ChessPuzzle(
    fen: 'r2q1rk1/pp2ppbp/2np2p1/8/2BNP3/2N5/PPP2PPP/R1BQR1K1 w - - 0 1',
    solution: ['d4f5', 'g6f5', 'e4f5'],
    description: 'Springeropfer öffnet Königsstellung',
  ),
  ChessPuzzle(
    fen: '5rk1/5p1p/4p1pQ/8/8/8/5PPP/4R1K1 w - - 0 1',
    solution: ['e1e6', 'f8f7', 'h6g6'],
    description: 'Turm hebt Deckung auf',
  ),
  ChessPuzzle(
    fen: '3rk3/ppp2ppp/8/3N4/8/8/PPP2PPP/3R2K1 w - - 0 1',
    solution: ['d5c7', 'e8e7', 'd1d8'],
    description: 'Springerschach und Grundreihenmatt',
  ),
  ChessPuzzle(
    fen: 'r2qr1k1/ppp2ppp/2n5/3p4/3P4/5N2/PPP2PPP/R1BQR1K1 w - - 0 1',
    solution: ['e1e8', 'd8e8', 'f3e5'],
    description: 'Turmabtausch und Springerangriff',
  ),
  ChessPuzzle(
    fen: 'r1bq1rk1/ppp2ppp/2np4/2b1p3/2B1P1n1/2NP1N2/PPP2PPP/R1BQR1K1 w - - 0 1',
    solution: ['c4f7', 'f8f7', 'f3g5'],
    description: 'Läuferopfer auf f7 mit Springernachspiel',
  ),
  ChessPuzzle(
    fen: 'r3k1nr/ppppqppp/2n5/2b1p3/2B1P3/2NP4/PPP1QPPP/R1B1K1NR w KQkq - 0 1',
    solution: ['e2f3', 'c6d4', 'f3f7'],
    description: 'Dame über f3 nach f7',
  ),
];

// Hard: Tactical combinations — forks, pins, skewers, winning material (2-3 moves)
const List<ChessPuzzle> hardPuzzles = [
  ChessPuzzle(
    fen: 'r1bqkb1r/pppp1ppp/2n5/4p3/2B1n3/5N2/PPPP1PPP/RNBQR1K1 w kq - 0 1',
    solution: ['d2d3', 'e4c5', 'f3e5'],
    description: 'Springer auf e4 vertreiben und e5 gewinnen',
  ),
  ChessPuzzle(
    fen: 'rnbqkb1r/pppppppp/5n2/8/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 1',
    solution: ['e4e5', 'f6d5', 'd2d4'],
    description: 'Zentrum besetzen und Springer vertreiben',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/2B1P3/2N2N2/PPPP1PPP/R1BQK2R w KQkq - 0 1',
    solution: ['f3e5', 'c6e5', 'd2d4'],
    description: 'Zentraler Springerangriff mit Bauernnachstoß',
  ),
  ChessPuzzle(
    fen: 'r2qk2r/ppp1bppp/2n1b3/3np3/8/1BN2N2/PPPP1PPP/R1BQR1K1 w kq - 0 1',
    solution: ['c3d5', 'e6d5', 'b3d5'],
    description: 'Springerabtausch und Läufer gewinnt Material',
  ),
  ChessPuzzle(
    fen: 'r1bqkbnr/pppp1ppp/2n5/4p3/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 1',
    solution: ['f1b5', 'a7a6', 'b5c6'],
    description: 'Spanische Partie – Springer pinnen',
  ),
  ChessPuzzle(
    fen: 'r3k2r/ppp1qppp/2n1bn2/3pp3/1bPP4/2NBPN2/PP3PPP/R1BQK2R w KQkq - 0 1',
    solution: ['d4d5', 'e6d5', 'c4d5'],
    description: 'Zentrumsvormarsch gewinnt Material',
  ),
  ChessPuzzle(
    fen: 'rnbqkb1r/ppp1pppp/5n2/3p4/3PP3/8/PPP2PPP/RNBQKBNR w KQkq - 0 1',
    solution: ['e4e5', 'f6e4', 'f1d3'],
    description: 'Springer vertreiben und entwickeln',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/ppppbppp/2n2n2/4p3/2BPP3/5N2/PPP2PPP/RNBQK2R w KQkq - 0 1',
    solution: ['d4e5', 'f6e4', 'c4f7'],
    description: 'Zentrum öffnen und f7 angreifen',
  ),
  ChessPuzzle(
    fen: 'r1b1kbnr/ppppqppp/2n5/4p3/2BPP3/5N2/PPP2PPP/RNBQK2R w KQkq - 0 1',
    solution: ['d4d5', 'c6d4', 'f3d4'],
    description: 'Bauernstoß verdrängt Springer',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/pppp1ppp/2n5/2b1p3/2BPn3/5N2/PPP2PPP/RNBQ1RK1 w kq - 0 1',
    solution: ['d4e5', 'c5f2', 'f1f2'],
    description: 'Zentrumsschlag und Material gewinnen',
  ),
  ChessPuzzle(
    fen: 'rnbq1rk1/ppp1ppbp/3p1np1/8/2PPP3/2N2N2/PP2BPPP/R1BQK2R w KQ - 0 1',
    solution: ['e4e5', 'd6e5', 'd4e5'],
    description: 'Zentrumsdurchbruch',
  ),
  ChessPuzzle(
    fen: 'r1bqkb1r/1ppppppp/p1n2n2/4P3/8/2N2N2/PPPP1PPP/R1BQKB1R w KQkq - 0 1',
    solution: ['e5f6', 'e7f6', 'd2d4'],
    description: 'En-passant-ähnlicher Schlag gewinnt Tempo',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/ppppbppp/2n2n2/4p3/4P1P1/2N2N2/PPPP1P1P/R1BQKB1R w KQkq - 0 1',
    solution: ['g4g5', 'f6e4', 'c3e4'],
    description: 'Bauernvormarsch vertreibt Springer',
  ),
  ChessPuzzle(
    fen: 'r1bqr1k1/pppp1ppp/2n2n2/2b1p3/2B1P3/3P1N2/PPP2PPP/RNBQ1RK1 w - - 0 1',
    solution: ['c1g5', 'h7h6', 'g5f6'],
    description: 'Läufer pinnt Springer und gewinnt ihn',
  ),
  ChessPuzzle(
    fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p3/4P3/2NB4/PPPP1PPP/R1BQK1NR w KQkq - 0 1',
    solution: ['f2f4', 'e5f4', 'e4e5'],
    description: 'Königsgambit – Zentrum dominieren',
  ),
  ChessPuzzle(
    fen: 'rnbqk2r/pppp1ppp/4pn2/8/1bPP4/2N5/PP2PPPP/R1BQKBNR w KQkq - 0 1',
    solution: ['e2e3', 'b4c3', 'b2c3'],
    description: 'Nimzo-Indisch Läufertausch akzeptieren',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/pppp1ppp/2n2n2/2b1p3/4P3/3B1N2/PPPP1PPP/RNBQK2R w KQkq - 0 1',
    solution: ['c2c3', 'a7a5', 'd3c4'],
    description: 'Zentrumsvorbereitung und Läufer aktivieren',
  ),
  ChessPuzzle(
    fen: 'r2qkbnr/ppp1pppp/2n5/3p4/3PP1b1/5N2/PPP2PPP/RNBQKB1R w KQkq - 0 1',
    solution: ['e4e5', 'g4f3', 'd1f3'],
    description: 'Zentrum vorstoßen und Läufer gewinnen',
  ),
  ChessPuzzle(
    fen: 'r1bqk2r/ppp2ppp/2np1n2/2b1p3/2B1P3/2NP1N2/PPP2PPP/R1BQK2R w KQkq - 0 1',
    solution: ['c1g5', 'h7h6', 'g5f6'],
    description: 'Springer pinnen und gewinnen',
  ),
  ChessPuzzle(
    fen: 'rn1qkbnr/ppp1pppp/8/3p4/3PP1b1/8/PPP2PPP/RNBQKBNR w KQkq - 0 1',
    solution: ['e4d5', 'd8d5', 'b1c3'],
    description: 'Zentrum schlagen und mit Tempo entwickeln',
  ),
];

const puzzlesByDifficulty = {
  'easy': easyPuzzles,
  'medium': mediumPuzzles,
  'hard': hardPuzzles,
};

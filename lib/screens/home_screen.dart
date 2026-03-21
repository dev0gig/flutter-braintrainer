import 'package:flutter/material.dart';
import '../models/game_definition.dart';
import '../games/anagram_solver/anagram_solver_screen.dart';
import '../games/math_trainer/math_trainer_screen.dart';
import '../games/n_back/n_back_screen.dart';
import '../games/memory_match/memory_match_screen.dart';
import '../games/pattern_memory/pattern_memory_screen.dart';
import '../games/schulte_table/schulte_table_screen.dart';
import '../games/stroop_test/stroop_test_screen.dart';
import '../games/sudoku/sudoku_screen.dart';
import '../games/switching_task/switching_task_screen.dart';
import '../games/wcst/wcst_screen.dart';
import '../games/chess/chess_screen.dart';

final List<GameDefinition> games = [
  GameDefinition(
    id: 'anagram-solver',
    name: 'Anagramm',
    description: 'Wörter aus Buchstaben bilden',
    icon: Icons.spellcheck,
    scoreLabel: 'Richtige',
    builder: () => const AnagramSolverScreen(),
  ),
  GameDefinition(
    id: 'chess',
    name: 'Chess',
    description: 'Klassisches Schach',
    icon: Icons.castle,
    scoreLabel: 'Gelöste Puzzles',
    isLowerBetterFn: (s) => s?['mode'] == 'computer',
    builder: () => const ChessScreen(),
  ),
  GameDefinition(
    id: 'math-trainer',
    name: 'Mathe Trainer',
    description: 'Schnelles Kopfrechnen',
    icon: Icons.calculate,
    scoreLabel: 'Punkte',
    builder: () => const MathTrainerScreen(),
  ),
  GameDefinition(
    id: 'memory-cards',
    name: 'Paare finden',
    description: 'Klassisches Memory',
    icon: Icons.style,
    scoreLabel: 'Zeit (s)',
    lowerIsBetter: true,
    builder: () => const MemoryMatchScreen(),
  ),
  GameDefinition(
    id: 'n-back',
    name: 'N-Back',
    description: 'Arbeitsgedächtnis trainieren',
    icon: Icons.psychology,
    scoreLabel: 'Genauigkeit %',
    builder: () => const NBackScreen(),
  ),
  GameDefinition(
    id: 'pattern-memory',
    name: 'Pattern Memory',
    description: 'Merke dir das Muster',
    icon: Icons.grid_view,
    scoreLabel: 'Level',
    builder: () => const PatternMemoryScreen(),
  ),
  GameDefinition(
    id: 'schulte-table',
    name: 'Schulte Table',
    description: 'Finde Zahlen in Reihenfolge',
    icon: Icons.apps,
    scoreLabel: 'Zeit (s)',
    lowerIsBetter: true,
    builder: () => const SchulteTableScreen(),
  ),
  GameDefinition(
    id: 'stroop-test',
    name: 'Stroop Test',
    description: 'Farbe vs. Wortbedeutung',
    icon: Icons.palette,
    scoreLabel: 'Richtige',
    builder: () => const StroopTestScreen(),
  ),
  GameDefinition(
    id: 'sudoku',
    name: 'Sudoku',
    description: 'Klassisches Zahlenrätsel',
    icon: Icons.grid_on,
    scoreLabel: 'Zeit (s)',
    lowerIsBetter: true,
    builder: () => const SudokuScreen(),
  ),
  GameDefinition(
    id: 'switching-task',
    name: 'Task Switching',
    description: 'Regelwechsel unter Zeitdruck',
    icon: Icons.swap_vert,
    scoreLabel: 'Punkte',
    builder: () => const SwitchingTaskScreen(),
  ),
  GameDefinition(
    id: 'wcst',
    name: 'WCST',
    description: 'Kognitive Flexibilität testen',
    icon: Icons.category,
    scoreLabel: 'Genauigkeit %',
    builder: () => const WcstScreen(),
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String get _title => games[_selectedIndex].name;

  Widget get _currentGame => games[_selectedIndex].builder();

  void _selectGame(int index, {bool closeDrawer = false}) {
    setState(() => _selectedIndex = index);
    if (closeDrawer) Navigator.pop(context);
  }

  Widget _buildSidebarContent({bool isDrawer = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    final sidebarBg = colorScheme.surfaceContainerLow;
    final safePadding = MediaQuery.of(context).padding;

    return Column(
      children: [
        ColoredBox(
          color: sidebarBg,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, safePadding.top + 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.psychology_alt, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'BrainTrainer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        Expanded(
          child: ClipRect(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: true,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: safePadding.bottom),
                  clipBehavior: Clip.hardEdge,
                  physics: const ClampingScrollPhysics(),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    final isSelected = index == _selectedIndex;
                    return ListTile(
                      leading: Icon(game.icon),
                      title: Text(game.name),
                      subtitle: Text(
                        game.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      selected: isSelected,
                      selectedTileColor:
                          colorScheme.primaryContainer.withValues(alpha: 0.3),
                      onTap: () => _selectGame(index, closeDrawer: isDrawer),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    final bg = Theme.of(context).colorScheme.surfaceContainerLow;
    return Drawer(
      backgroundColor: bg,
      elevation: 0,
      child: _buildSidebarContent(isDrawer: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        if (isTablet) {
          return Scaffold(
            appBar: AppBar(
              title: Text(_title),
              centerTitle: true,
            ),
            body: SafeArea(
              top: false,
              child: Row(
                children: [
                  SizedBox(
                    width: 300,
                    child: Material(
                      color: colorScheme.surfaceContainerLow,
                      child: _buildSidebarContent(isDrawer: false),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(child: _currentGame),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_title),
            centerTitle: true,
          ),
          drawer: _buildDrawer(),
          drawerEnableOpenDragGesture: false,
          body: SafeArea(
            top: false,
            child: _currentGame,
          ),
        );
      },
    );
  }
}

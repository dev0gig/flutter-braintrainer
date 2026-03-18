import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import '../models/game_definition.dart';
import '../services/score_service.dart';
import 'scores_screen.dart';
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

  void _showSettingsSheet() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Statistiken'),
                subtitle: const Text('Score-Verlauf aller Spiele'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    this.context,
                    MaterialPageRoute(
                      builder: (_) => const ScoresScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload),
                title: const Text('Scores exportieren'),
                subtitle: const Text('Als JSON-Datei teilen'),
                onTap: () async {
                  Navigator.pop(context);
                  final json = await ScoreService.exportJson();
                  final dir = await getTemporaryDirectory();
                  final file = File('${dir.path}/braintrainer_scores.json');
                  await file.writeAsString(json);
                  await SharePlus.instance.share(
                    ShareParams(files: [XFile(file.path)]),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Scores importieren'),
                subtitle: const Text('JSON-Backup einlesen'),
                onTap: () async {
                  Navigator.pop(context);
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                  );
                  if (result == null || result.files.single.path == null) return;
                  final file = File(result.files.single.path!);
                  final json = await file.readAsString();
                  try {
                    final count = await ScoreService.importJson(json);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('$count Scores importiert')),
                      );
                    }
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Ungültige Datei')),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline, color: colorScheme.error),
                title: Text(
                  'Alle Scores zurücksetzen',
                  style: TextStyle(color: colorScheme.error),
                ),
                subtitle: const Text('Löscht alle gespeicherten Spielstände'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: this.context,
                    builder: (context) => AlertDialog(
                      title: const Text('Scores zurücksetzen?'),
                      content: const Text(
                        'Alle gespeicherten Spielstände werden unwiderruflich gelöscht.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Abbrechen'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await ScoreService.clearAll();
                            if (mounted) {
                              ScaffoldMessenger.of(this.context).showSnackBar(
                                const SnackBar(
                                    content: Text('Scores zurückgesetzt')),
                              );
                            }
                          },
                          child: Text(
                            'Löschen',
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarContent({bool isDrawer = true}) {
    final colorScheme = Theme.of(context).colorScheme;
    final sidebarBg = colorScheme.surfaceContainerLow;

    return Column(
      children: [
        ColoredBox(
          color: sidebarBg,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
              child: ListView.builder(
                padding: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
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
        Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ColoredBox(
          color: sidebarBg,
          child: ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Einstellungen'),
            onTap: () {
              if (isDrawer) Navigator.pop(context);
              _showSettingsSheet();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: _buildSidebarContent(isDrawer: true),
      ),
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
                      child: SafeArea(
                        child: _buildSidebarContent(isDrawer: false),
                      ),
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
          drawerEdgeDragWidth: MediaQuery.of(context).size.width / 2,
          body: SafeArea(
            top: false,
            child: _currentGame,
          ),
        );
      },
    );
  }
}

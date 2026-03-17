import 'package:flutter/material.dart';

import '../models/game_definition.dart';
import '../services/score_service.dart';
import 'home_screen.dart';

enum ScoreTimeRange { week, month, all }

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  Map<String, List<ScoreEntry>> _allScores = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final scores = await ScoreService.getAllScores();
    if (mounted) {
      setState(() {
        _allScores = scores;
        _loading = false;
      });
    }
  }

  void _openDetail(GameDefinition game) {
    final scores = _allScores[game.id] ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _GameDetailSheet(game: game, scores: scores),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiken'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: games.length,
              itemBuilder: (context, index) {
                final game = games[index];
                final scores = _allScores[game.id] ?? [];
                return _GameOverviewCard(
                  game: game,
                  scores: scores,
                  colorScheme: colorScheme,
                  onTap: () => _openDetail(game),
                );
              },
            ),
    );
  }
}

// --- Overview Card (Layer 1) ---

class _GameOverviewCard extends StatelessWidget {
  final GameDefinition game;
  final List<ScoreEntry> scores;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _GameOverviewCard({
    required this.game,
    required this.scores,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final latestScore = scores.isNotEmpty ? scores.last.score : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(game.icon, color: colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      game.scoreLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              if (latestScore != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$latestScore',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                    ),
                    Text(
                      '${scores.length} Spiele',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                )
              else
                Text(
                  'Noch keine Daten',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Detail Bottom Sheet (Layer 2) ---

class _GameDetailSheet extends StatefulWidget {
  final GameDefinition game;
  final List<ScoreEntry> scores;

  const _GameDetailSheet({required this.game, required this.scores});

  @override
  State<_GameDetailSheet> createState() => _GameDetailSheetState();
}

class _GameDetailSheetState extends State<_GameDetailSheet> {
  ScoreTimeRange _timeRange = ScoreTimeRange.all;

  List<ScoreEntry> _filterByTime(List<ScoreEntry> entries) {
    if (_timeRange == ScoreTimeRange.all) return entries;
    final now = DateTime.now();
    final cutoff = switch (_timeRange) {
      ScoreTimeRange.week => now.subtract(const Duration(days: 7)),
      ScoreTimeRange.month => now.subtract(const Duration(days: 30)),
      ScoreTimeRange.all => now,
    };
    return entries.where((e) => e.date.isAfter(cutoff)).toList();
  }

  /// Group scores by settingsKey.
  Map<String, List<ScoreEntry>> _groupBySettings(List<ScoreEntry> entries) {
    final map = <String, List<ScoreEntry>>{};
    for (final e in entries) {
      (map[e.settingsKey] ??= []).add(e);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final filtered = _filterByTime(widget.scores);
    final grouped = _groupBySettings(filtered);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Icon(widget.game.icon, color: colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    widget.game.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            // Time filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SegmentedButton<ScoreTimeRange>(
                segments: const [
                  ButtonSegment(
                    value: ScoreTimeRange.week,
                    label: Text('Woche'),
                  ),
                  ButtonSegment(
                    value: ScoreTimeRange.month,
                    label: Text('Monat'),
                  ),
                  ButtonSegment(
                    value: ScoreTimeRange.all,
                    label: Text('Alle'),
                  ),
                ],
                selected: {_timeRange},
                onSelectionChanged: (v) =>
                    setState(() => _timeRange = v.first),
              ),
            ),
            // Content
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Keine Daten für diesen Zeitraum',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: grouped.length,
                      itemBuilder: (context, index) {
                        final key = grouped.keys.elementAt(index);
                        final scores = grouped[key]!;
                        final first = scores.first;
                        final label = settingsLabel(
                          widget.game.id,
                          first.settings,
                          first.difficulty,
                        );
                        return _SettingsSection(
                          label: label,
                          scores: scores,
                          colorScheme: colorScheme,
                          scoreLabel: widget.game.scoreLabel,
                          lowerIsBetter: widget.game.isLowerBetterFor(first.settings),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// --- Per-Settings Section ---

class _SettingsSection extends StatelessWidget {
  final String label;
  final List<ScoreEntry> scores;
  final ColorScheme colorScheme;
  final String scoreLabel;
  final bool lowerIsBetter;

  const _SettingsSection({
    required this.label,
    required this.scores,
    required this.colorScheme,
    required this.scoreLabel,
    this.lowerIsBetter = false,
  });

  static String _formatTime(int seconds) {
    if (seconds >= 60) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return s > 0 ? '${m}m ${s}s' : '${m}m';
    }
    return '${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final best = scores.map((s) => s.score).reduce(
      lowerIsBetter ? (a, b) => a < b ? a : b : (a, b) => a > b ? a : b,
    );
    final avg = scores.map((s) => s.score).reduce((a, b) => a + b) / scores.length;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label chip
            Chip(
              label: Text(label),
              backgroundColor: colorScheme.primaryContainer,
              labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: 8),
            // Stats row
            Row(
              children: [
                _StatItem(
                  label: 'Bester',
                  value: lowerIsBetter ? _formatTime(best) : '$best',
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Durchschnitt',
                  value: lowerIsBetter
                      ? _formatTime(avg.round())
                      : avg.toStringAsFixed(1),
                  colorScheme: colorScheme,
                ),
                const SizedBox(width: 16),
                _StatItem(
                  label: 'Spiele',
                  value: '${scores.length}',
                  colorScheme: colorScheme,
                ),
              ],
            ),
            // Graph
            if (scores.length >= 2) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: CustomPaint(
                  size: const Size(double.infinity, 80),
                  painter: _ScoreGraphPainter(
                    scores: scores,
                    lineColor: colorScheme.primary,
                    fillColor: colorScheme.primary.withValues(alpha: 0.1),
                    dotColor: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _StatItem({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

// --- Graph Painter ---

class _ScoreGraphPainter extends CustomPainter {
  final List<ScoreEntry> scores;
  final Color lineColor;
  final Color fillColor;
  final Color dotColor;

  _ScoreGraphPainter({
    required this.scores,
    required this.lineColor,
    required this.fillColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.length < 2) return;

    final values = scores.map((s) => s.score.toDouble()).toList();
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final range = maxVal - minVal;
    final yPadding = 4.0;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i / (values.length - 1) * size.width;
      final normalizedY =
          range == 0 ? 0.5 : (values[i] - minVal) / range;
      final y = size.height - yPadding - normalizedY * (size.height - yPadding * 2);
      points.add(Offset(x, y));
    }

    // Fill area under curve
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Draw line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (final p in points) {
      canvas.drawCircle(p, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScoreGraphPainter oldDelegate) =>
      scores != oldDelegate.scores ||
      lineColor != oldDelegate.lineColor;
}

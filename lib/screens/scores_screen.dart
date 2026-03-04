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
  ScoreTimeRange _timeRange = ScoreTimeRange.all;
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
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      final scores =
                          _filterByTime(_allScores[game.id] ?? []);
                      return _GameScoreCard(
                        game: game,
                        scores: scores,
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _GameScoreCard extends StatelessWidget {
  final GameDefinition game;
  final List<ScoreEntry> scores;
  final ColorScheme colorScheme;

  const _GameScoreCard({
    required this.game,
    required this.scores,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final latestScore = scores.isNotEmpty ? scores.last.score : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
              ],
            ),
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

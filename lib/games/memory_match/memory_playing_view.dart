import 'dart:math';

import 'package:flutter/material.dart';

import 'memory_game_state.dart';

class MemoryPlayingView extends StatelessWidget {
  final MemoryGameState state;

  const MemoryPlayingView({super.key, required this.state});

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
                color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(state.timerDisplay,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant)),
              const SizedBox(width: 16),
              Text(
                'Versuche: ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${state.attempts}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Paare: ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${state.matchedCount}/${state.totalPairs}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),

        // Grid
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _buildGrid(context),
              ),
            ),
          ),
        ),

      ],
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cols = state.gridCols;
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final spacing = 6.0;
        final cardWidth = (availableWidth - (cols - 1) * spacing) / cols;
        final cardHeight = cardWidth; // square cards

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < state.cards.length; i++)
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: _MemoryCardWidget(
                  card: state.cards[i],
                  onTap: () => state.onCardTap(i),
                  colorScheme: colorScheme,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MemoryCardWidget extends StatefulWidget {
  final MemoryCard card;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _MemoryCardWidget({
    required this.card,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<_MemoryCardWidget> createState() => _MemoryCardWidgetState();
}

class _MemoryCardWidgetState extends State<_MemoryCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  bool get _isRevealed => widget.card.isFlipped || widget.card.isMatched;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.addListener(() {
      // Switch face at halfway point
      if (_animation.value >= 0.5 && _showFront == _isRevealed) {
        setState(() => _showFront = !_isRevealed);
      } else if (_animation.value < 0.5 && _showFront != _isRevealed) {
        // noop, handled above
      }
    });

    _showFront = !_isRevealed;
    if (_isRevealed) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _MemoryCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isRevealed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          final isBack = _animation.value >= 0.5;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(cs),
                  )
                : _buildFront(cs),
          );
        },
      ),
    );
  }

  Widget _buildFront(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.help_outline,
        color: cs.onSurfaceVariant.withValues(alpha: 0.2),
        size: 28,
      ),
    );
  }

  Widget _buildBack(ColorScheme cs) {
    final isMatched = widget.card.isMatched;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMatched ? Colors.green : cs.primary,
          width: 2,
        ),
        boxShadow: isMatched
            ? [BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 12)]
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        widget.card.symbol,
        style: TextStyle(
          fontSize: 28,
          color: cs.onSurface,
        ),
      ),
    );
  }
}

class MemoryGameoverView extends StatelessWidget {
  final MemoryGameState state;

  const MemoryGameoverView({super.key, required this.state});

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
              const Icon(
                Icons.emoji_events,
                size: 64,
                color: Colors.amber,
              ),
              const SizedBox(height: 12),
              Text(
                'Klasse!',
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    Row(
                      children: [
                        Expanded(child: _statBox(
                          state.timerDisplay,
                          'Zeit',
                          colorScheme,
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _statBox(
                          '${state.attempts}',
                          'Versuche',
                          colorScheme,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: state.startGame,
                icon: const Icon(Icons.replay),
                label: const Text('Nochmal spielen'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.returnToStart,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Zurück zum Menü'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(String value, String label, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold, color: cs.primary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

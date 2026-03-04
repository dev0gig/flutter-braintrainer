import 'package:flutter/material.dart';

import 'n_back_game_state.dart';

class NBackPlayingView extends StatelessWidget {
  final NBackGameState state;

  const NBackPlayingView({super.key, required this.state});

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
                '${state.nLevel}-Back',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Trial ',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '${state.currentTrial}',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '/${state.totalTrials}',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              const SizedBox(width: 48), // balance for close button
            ],
          ),
        ),

        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Instruction
                    Text(
                      'Drücke wenn Position = vor ${state.nLevel} Schritten',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // 3x3 Grid
                    AspectRatio(
                      aspectRatio: 1,
                      child: GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (var i = 0; i < 9; i++)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: state.activePosition == i
                                    ? colorScheme.primary
                                    : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: colorScheme.outlineVariant),
                                boxShadow: state.activePosition == i
                                    ? [
                                        BoxShadow(
                                          color: colorScheme.primary.withValues(alpha: 0.3),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Match button
                    SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: FilledButton(
                        onPressed: state.showingStimulus ? state.respond : null,
                        style: FilledButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('MATCH'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

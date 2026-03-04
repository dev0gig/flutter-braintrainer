import 'package:flutter/material.dart';

class GamePlaceholder extends StatelessWidget {
  final String name;
  final IconData icon;

  const GamePlaceholder({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kommt bald...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

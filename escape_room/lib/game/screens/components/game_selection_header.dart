import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Header section of the game selection screen with title and subtitle
class GameSelectionHeader extends StatelessWidget {
  const GameSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🔓',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height > 700 ? 64 : 48,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            localizations?.appTitle ?? 'Escape Master',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.height > 700 ? 48 : 36,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '究極の脱出パズルゲーム',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: MediaQuery.of(context).size.height > 700 ? 18 : 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

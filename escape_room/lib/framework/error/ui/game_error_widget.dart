import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/game_error_models.dart';

/// エラー表示ウィジェット
///
/// Flutter公式準拠: ErrorWidgetをカスタマイズ
class GameErrorWidget extends StatelessWidget {
  final GameError error;
  final VoidCallback? onRetry;

  const GameErrorWidget({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getErrorIcon(),
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            error.userMessage,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Text(
              error.message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ],
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.type) {
      case GameErrorType.network:
        return Icons.wifi_off;
      case GameErrorType.adLoad:
        return Icons.ad_units_outlined;
      case GameErrorType.audioPlayback:
        return Icons.volume_off;
      case GameErrorType.permission:
        return Icons.lock_outline;
      case GameErrorType.resourceLoad:
        return Icons.broken_image;
      default:
        return Icons.error_outline;
    }
  }
}

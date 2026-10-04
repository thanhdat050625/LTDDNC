import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/cineplex_colors.dart';
import 'app_button.dart';

class AppErrorView extends StatelessWidget {
  final String message;
  final String? title;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorView({
    super.key,
    required this.message,
    this.title,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context);
    final buttonText = retryLabel ?? l10n?.retry ?? 'Thử lại';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: colors.error,
              ),
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: buttonText,
                onPressed: onRetry,
                width: 160,
                height: 42,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

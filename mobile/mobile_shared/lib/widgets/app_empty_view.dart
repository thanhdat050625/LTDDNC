import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/cineplex_colors.dart';
import 'app_button.dart';

class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const AppEmptyView({
    super.key,
    this.icon = Icons.inbox_outlined,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.action,
    this.iconSize = 48,
    this.padding = const EdgeInsets.all(24.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.extension<CineplexColors>() ??
        (isDark ? CineplexColors.dark : CineplexColors.light);
    final l10n = AppLocalizations.of(context);
    final displayTitle = title ?? l10n?.noData ?? 'Không có dữ liệu';

    return Center(
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: iconSize + 28,
              height: iconSize + 28,
              decoration: BoxDecoration(
                color: colors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.textSecondary.withValues(alpha: 0.15),
                  width: 1,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              displayTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 160,
                height: 42,
                isOutlined: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

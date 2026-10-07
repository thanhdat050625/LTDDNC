import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/cineplex_colors.dart';

/// Shows a standardized confirmation dialog before exiting the app.
/// Returns `true` if the user confirmed exit, `false` otherwise.
Future<bool> showAppExitDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => const AppExitDialog(),
  );
  return result ?? false;
}

/// Standardized exit confirmation dialog matching project theme and l10n.
class AppExitDialog extends StatelessWidget {
  const AppExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CineplexColors.of(context);

    final title = l10n?.exitAppTitle ?? 'Thoát ứng dụng';
    final message = l10n?.exitAppMessage ?? 'Bạn có chắc chắn muốn thoát ứng dụng không?';
    final cancelText = l10n?.cancel ?? 'Hủy';
    final confirmText = l10n?.exitAppConfirm ?? 'Thoát';

    return AlertDialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.borderSubtle, width: 1),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 14,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            foregroundColor: colors.textSecondary,
          ),
          child: Text(
            cancelText,
            style: TextStyle(
              color: colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: colors.error,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

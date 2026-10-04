import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ScanResultOverlay extends StatelessWidget {
  final bool isSuccess;
  final bool isWarning;
  final String message;
  final VoidCallback? onDismiss;

  const ScanResultOverlay({
    super.key,
    required this.isSuccess,
    this.isWarning = false,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final Color bgColor;
    final IconData icon;

    if (isSuccess) {
      bgColor = colors.success;
      icon = Icons.check_circle_rounded;
    } else if (isWarning) {
      bgColor = colors.warning;
      icon = Icons.warning_amber_rounded;
    } else {
      bgColor = colors.error;
      icon = Icons.cancel_rounded;
    }

    final Color textColor = isWarning ? const Color(0xFF111827) : Colors.white;
    final Color iconColor = isWarning ? const Color(0xFF111827) : Colors.white;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ),
            if (onDismiss != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.close, color: iconColor, size: 20),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

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
    Color bgColor;
    IconData icon;

    if (isSuccess) {
      bgColor = Colors.green.shade700;
      icon = Icons.check_circle;
    } else if (isWarning) {
      bgColor = Colors.amber.shade800;
      icon = Icons.warning_amber_rounded;
    } else {
      bgColor = Colors.red.shade700;
      icon = Icons.cancel;
    }

    return Positioned(
      bottom: 40,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: bgColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
              if (onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

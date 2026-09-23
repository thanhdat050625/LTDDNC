import 'package:flutter/material.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';

class ScanResultOverlay extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const ScanResultOverlay({Key? key, required this.isSuccess, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSuccess ? Colors.green : AppColors.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }
}

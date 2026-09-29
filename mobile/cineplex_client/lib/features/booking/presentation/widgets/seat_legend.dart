import 'package:flutter/material.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';
import 'package:cineplex_client/l10n/app_localizations.dart';

class SeatLegend extends StatelessWidget {
  const SeatLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem(AppColors.seatStandard, l10n.seatAvailable),
        _buildLegendItem(AppColors.seatSelected, l10n.seatSelected),
        _buildLegendItem(AppColors.seatHeld, l10n.seatHeld),
        _buildLegendItem(AppColors.seatBooked, l10n.seatBooked),
        _buildLegendItem(AppColors.seatCouple, l10n.seatCouple),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

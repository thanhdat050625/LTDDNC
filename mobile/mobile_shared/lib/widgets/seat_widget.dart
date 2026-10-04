import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/seat_model.dart';
import '../theme/cineplex_colors.dart';

class SeatWidget extends StatelessWidget {
  final SeatModel seat;
  final bool isSelected;
  final VoidCallback? onTap;
  final double size;
  final bool showColumnOnly;

  const SeatWidget({
    super.key,
    required this.seat,
    this.isSelected = false,
    this.onTap,
    this.size = 34.0,
    this.showColumnOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final isBooked = seat.status == SeatStatus.booked;
    final isMaintenance = seat.status == SeatStatus.maintenance;
    final isInteractable = !isBooked && !isMaintenance && onTap != null;

    final seatColor = _resolveColor(colors);
    final labelText = _resolveLabel();
    final textColor = _resolveTextColor(colors, isDark);

    final double seatWidth = seat.isCouple ? (size * 2 + 6) : size;
    final double seatHeight = size;

    return Semantics(
      button: isInteractable,
      enabled: isInteractable,
      label: '${seat.label} ${_resolveStatusText(seat.status, l10n)}',
      child: GestureDetector(
        onTap: isInteractable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(3),
          width: seatWidth,
          height: seatHeight,
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF111827))
                  : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.seatSelected.withValues(alpha: 0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            labelText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor,
              fontSize: size <= 32 ? 10 : 11,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.clip,
          ),
        ),
      ),
    );
  }

  Color _resolveColor(CineplexColors colors) {
    if (isSelected) return colors.seatSelected;
    switch (seat.status) {
      case SeatStatus.booked:
        return colors.seatBooked;
      case SeatStatus.held:
        return colors.seatHeld;
      case SeatStatus.maintenance:
        return colors.textSecondary.withValues(alpha: 0.3);
      case SeatStatus.selected:
        return colors.seatSelected;
      case SeatStatus.available:
        if (seat.isCouple) return colors.seatCouple;
        if (seat.isVip) return colors.seatVIP;
        return colors.seatStandard;
    }
  }

  Color _resolveTextColor(CineplexColors colors, bool isDark) {
    if (seat.status == SeatStatus.booked) {
      return colors.seatBookedText;
    }
    if (seat.status == SeatStatus.maintenance) {
      return colors.textSecondary.withValues(alpha: 0.5);
    }
    if (seat.status == SeatStatus.selected || isSelected) {
      return const Color(0xFF111827);
    }
    if (seat.status == SeatStatus.held) {
      return const Color(0xFF111827);
    }
    return colors.seatText;
  }

  String _resolveLabel() {
    if (seat.isCouple) {
      return '${seat.column},${seat.column + 1}';
    }
    if (showColumnOnly) {
      return '${seat.column}';
    }
    return seat.label;
  }

  String _resolveStatusText(SeatStatus status, AppLocalizations? l10n) {
    switch (status) {
      case SeatStatus.booked:
        return l10n?.seatBooked ?? 'Đã đặt';
      case SeatStatus.held:
        return l10n?.seatHeld ?? 'Đang giữ';
      case SeatStatus.maintenance:
        return l10n?.roomStatusMaintenance ?? 'Bảo trì';
      case SeatStatus.selected:
        return l10n?.seatSelected ?? 'Đang chọn';
      case SeatStatus.available:
        return l10n?.seatAvailable ?? 'Trống';
    }
  }
}

enum SeatLegendType {
  standard,
  vip,
  couple,
  selected,
  held,
  booked,
}

class SeatLegend extends StatelessWidget {
  final List<SeatLegendType>? items;
  final bool showAll;
  final double spacing;
  final double runSpacing;

  const SeatLegend({
    super.key,
    this.items,
    this.showAll = false,
    this.spacing = 14.0,
    this.runSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context);

    final displayItems = items ??
        (showAll
            ? SeatLegendType.values
            : const [
                SeatLegendType.standard,
                SeatLegendType.vip,
                SeatLegendType.couple,
                SeatLegendType.selected,
                SeatLegendType.booked,
              ]);

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: displayItems.map((type) => _buildItem(type, colors, l10n)).toList(),
    );
  }

  Widget _buildItem(
    SeatLegendType type,
    CineplexColors colors,
    AppLocalizations? l10n,
  ) {
    final Color color;
    final String label;

    switch (type) {
      case SeatLegendType.standard:
        color = colors.seatStandard;
        label = l10n?.seatStandard ?? 'Thường';
        break;
      case SeatLegendType.vip:
        color = colors.seatVIP;
        label = l10n?.seatVIP ?? 'VIP';
        break;
      case SeatLegendType.couple:
        color = colors.seatCouple;
        label = l10n?.seatCouple ?? 'Ghế đôi';
        break;
      case SeatLegendType.selected:
        color = colors.seatSelected;
        label = l10n?.seatSelected ?? 'Đang chọn';
        break;
      case SeatLegendType.held:
        color = colors.seatHeld;
        label = l10n?.seatHeld ?? 'Đang giữ';
        break;
      case SeatLegendType.booked:
        color = colors.seatBooked;
        label = l10n?.seatBooked ?? 'Đã đặt';
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: type == SeatLegendType.selected
                ? Border.all(color: Colors.white, width: 1)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

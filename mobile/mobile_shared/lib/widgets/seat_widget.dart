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
    final isHeldByOther = seat.status == SeatStatus.held && !isSelected;
    final isInteractable = !isBooked && !isMaintenance && !isHeldByOther && onTap != null;

    final labelText = _resolveLabel();
    final textColor = _resolveTextColor(colors, isDark);

    // Chuẩn kích thước ghế rạp chiếu phim (tỷ lệ chuẩn ghế ngồi có tựa lưng)
    final double seatWidth = size;
    final double seatHeight = size * 1.12;

    // Tạo bo góc mô phỏng ghế đôi / ghế thường
    final BorderRadius borderRadius = _resolveBorderRadius();
    final Gradient? seatGradient = _resolveGradient(colors, isDark);
    final Color solidColor = _resolveColor(colors);

    // Khoảng cách giữa các ghế: ghế đôi đi theo cặp (1-2, 3-4...)
    final EdgeInsets margin = _resolveMargin();

    return Semantics(
      button: isInteractable,
      enabled: isInteractable,
      label: '${seat.label} ${_resolveStatusText(seat.status, l10n)}',
      child: GestureDetector(
        onTap: isInteractable ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: margin,
          width: seatWidth,
          height: seatHeight,
          decoration: BoxDecoration(
            color: seatGradient == null ? solidColor : null,
            gradient: seatGradient,
            borderRadius: borderRadius,
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF111827))
                  : (isBooked
                      ? Colors.transparent
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.black.withValues(alpha: 0.08))),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.seatSelected.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : (!isBooked
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                          blurRadius: 3,
                          offset: const Offset(0, 1.5),
                        ),
                      ]
                    : null),
          ),
          child: Column(
            children: [
              // Phần tựa lưng ghế (Backrest) với số ghế
              Expanded(
                child: Center(
                  child: Text(
                    labelText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: size <= 28 ? 9 : (size <= 32 ? 10 : 11),
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                  ),
                ),
              ),
              // Đệm ghế phía dưới (Seat cushion lip) tạo hiệu ứng 3D như ghế rạp thật
              Container(
                height: 3.5,
                margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.45)
                      : (isBooked
                          ? Colors.black.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: isDark ? 0.22 : 0.35)),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BorderRadius _resolveBorderRadius() {
    if (seat.isCouple) {
      // Ghế đôi: nửa bên trái bo tròn ngoài, nửa bên phải bo tròn ngoài
      final isLeftInPair = seat.column % 2 != 0;
      if (isLeftInPair) {
        return const BorderRadius.only(
          topLeft: Radius.circular(8),
          bottomLeft: Radius.circular(4),
          topRight: Radius.circular(2),
          bottomRight: Radius.circular(2),
        );
      } else {
        return const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(4),
          topLeft: Radius.circular(2),
          bottomLeft: Radius.circular(2),
        );
      }
    }
    // Ghế thường & VIP: bo cong tựa lưng phía trên
    return const BorderRadius.only(
      topLeft: Radius.circular(6),
      topRight: Radius.circular(6),
      bottomLeft: Radius.circular(3),
      bottomRight: Radius.circular(3),
    );
  }

  EdgeInsets _resolveMargin() {
    if (seat.isCouple) {
      final isLeftInPair = seat.column % 2 != 0;
      return EdgeInsets.only(
        top: 2,
        bottom: 2,
        left: isLeftInPair ? 2.5 : 0.5,
        right: isLeftInPair ? 0.5 : 2.5,
      );
    }
    return const EdgeInsets.all(2.0);
  }

  Gradient? _resolveGradient(CineplexColors colors, bool isDark) {
    if (isSelected) {
      return LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.seatSelected.withValues(alpha: 0.9),
          colors.seatSelected,
        ],
      );
    }
    switch (seat.status) {
      case SeatStatus.booked:
      case SeatStatus.maintenance:
        return null; // Dùng solid color
      case SeatStatus.held:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.seatHeld.withValues(alpha: 0.9),
            colors.seatHeld,
          ],
        );
      case SeatStatus.selected:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.seatSelected.withValues(alpha: 0.9),
            colors.seatSelected,
          ],
        );
      case SeatStatus.available:
        if (seat.isCouple) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFFA855F7), const Color(0xFF7E22CE)]
                : [const Color(0xFFC084FC), const Color(0xFF9333EA)],
          );
        }
        if (seat.isVip) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFFEF4444), const Color(0xFFB91C1C)]
                : [const Color(0xFFF87171), const Color(0xFFDC2626)],
          );
        }
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF4B5563), const Color(0xFF374151)]
              : [const Color(0xFF94A3B8), const Color(0xFF64748B)],
        );
    }
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

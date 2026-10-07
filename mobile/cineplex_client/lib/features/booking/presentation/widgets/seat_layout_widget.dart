import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

class SeatLayoutWidget extends StatelessWidget {
  final List<SeatModel> seats;
  final List<int> selectedSeatIds;
  final Function(int) onSeatTap;
  final int rows;
  final int columns;

  const SeatLayoutWidget({
    super.key,
    required this.seats,
    required this.selectedSeatIds,
    required this.onSeatTap,
    required this.rows,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    if (seats.isEmpty) return const SizedBox.shrink();

    final colors = CineplexColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group seats by row
    final Map<String, List<SeatModel>> rowSeats = {};
    for (final seat in seats) {
      if (!rowSeats.containsKey(seat.row)) {
        rowSeats[seat.row] = [];
      }
      rowSeats[seat.row]!.add(seat);
    }

    final sortedRows = rowSeats.keys.toList()..sort();

    // Tính toán kích thước ghế thích ứng theo số cột phòng chiếu
    final double seatSize = columns <= 10
        ? 30.0
        : (columns <= 12 ? 27.0 : (columns <= 14 ? 24.0 : 22.0));

    return InteractiveViewer(
      minScale: 0.65,
      maxScale: 2.5,
      boundaryMargin: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: sortedRows.map((row) {
                  final rowList = rowSeats[row]!..sort((a, b) => a.column.compareTo(b.column));
                  final isCoupleRow = rowList.any((s) => s.isCouple);
                  final centerCol = (columns / 2).floor();

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cột chữ cái hàng ghế bên trái
                        _buildRowBadge(row, colors, isDark),
                        const SizedBox(width: 6),

                        // Danh sách ghế trong hàng
                        ...rowList.map((seat) {
                          // Khoảng cách lối đi:
                          // - Hàng ghế đôi: tạo lối đi giữa mỗi cặp ghế (cách 2 ghế)
                          // - Hàng ghế thường: tạo lối đi ở giữa phòng (centerCol) nếu phòng có từ 8 cột
                          final isCoupleAisle = isCoupleRow && (seat.column % 2 == 0) && seat.column < rowList.length;
                          final isStandardAisle = !isCoupleRow && columns >= 8 && seat.column == centerCol && seat.column < rowList.length;

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SeatWidget(
                                seat: seat,
                                isSelected: selectedSeatIds.contains(seat.seatId),
                                onTap: () => onSeatTap(seat.seatId),
                                size: seatSize,
                              ),
                              if (isCoupleAisle)
                                const SizedBox(width: 8)
                              else if (isStandardAisle)
                                const SizedBox(width: 10),
                            ],
                          );
                        }),

                        const SizedBox(width: 6),
                        // Cột chữ cái hàng ghế bên phải
                        _buildRowBadge(row, colors, isDark),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRowBadge(String row, CineplexColors colors, bool isDark) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        row,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colors.textSecondary.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}


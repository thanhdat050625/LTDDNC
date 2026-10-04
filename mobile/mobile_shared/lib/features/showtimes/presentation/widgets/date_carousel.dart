import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

class DateCarousel extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DateCarousel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  String _getWeekdayLabel(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case DateTime.monday:
        return l10n.weekdayMon;
      case DateTime.tuesday:
        return l10n.weekdayTue;
      case DateTime.wednesday:
        return l10n.weekdayWed;
      case DateTime.thursday:
        return l10n.weekdayThu;
      case DateTime.friday:
        return l10n.weekdayFri;
      case DateTime.saturday:
        return l10n.weekdaySat;
      case DateTime.sunday:
        return l10n.weekdaySun;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: theme.surface,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dates.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            // "Tất cả" chip
            final isAll = selectedDate == null;
            return _buildChip(
              theme: theme,
              isSelected: isAll,
              topText: l10n.filterAll,
              bottomText: '∞',
              onTap: () => onDateSelected(null),
            );
          }
          final date = dates[index - 1];
          final isSelected = selectedDate != null &&
              selectedDate!.year == date.year &&
              selectedDate!.month == date.month &&
              selectedDate!.day == date.day;
          final weekday = _getWeekdayLabel(date.weekday, l10n);
          final dayStr = date.day.toString().padLeft(2, '0');
          return _buildChip(
            theme: theme,
            isSelected: isSelected,
            topText: weekday,
            bottomText: dayStr,
            onTap: () => onDateSelected(isSelected ? null : date),
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required CineplexColors theme,
    required bool isSelected,
    required String topText,
    required String bottomText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? theme.primary : theme.card,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 52,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? theme.primary : theme.cardBorder,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                topText,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white70 : theme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                bottomText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : theme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

class DateCarousel extends StatefulWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onDateSelected;

  const DateCarousel({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateCarousel> createState() => _DateCarouselState();
}

class _DateCarouselState extends State<DateCarousel> {
  final ScrollController _scrollController = ScrollController();

  // Chip width + separator + padding
  static const double _chipWidth = 52;
  static const double _chipSpacing = 8;
  static const double _chipAllWidth = 52; // "Tất cả" chip cũng 52

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DateCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
    }
  }

  List<DateTime> _buildDisplayDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = List.generate(14, (i) => today.add(Duration(days: i)));

    final sel = widget.selectedDate;
    final outOfRange = sel != null &&
        !dates.any((d) =>
            d.year == sel.year && d.month == sel.month && d.day == sel.day);
    if (outOfRange) {
      return [...dates, DateTime(sel.year, sel.month, sel.day)];
    }
    return dates;
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final sel = widget.selectedDate;
    if (sel == null) {
      // Scroll đến đầu ("Tất cả")
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    final displayDates = _buildDisplayDates();
    // index trong ListView: 0 = "Tất cả", 1..n = displayDates
    final dateIndex = displayDates.indexWhere((d) =>
        d.year == sel.year && d.month == sel.month && d.day == sel.day);
    if (dateIndex < 0) return;

    // Tổng index trong ListView = dateIndex + 1 (vì index 0 là chip "Tất cả")
    final listIndex = dateIndex + 1;
    // offset = padding_left + (chip + gap) * listIndex - nửa viewport để căn giữa
    const paddingLeft = 12.0;
    final chipOffset = paddingLeft + listIndex * (_chipAllWidth + _chipSpacing);
    final viewportHalf = _scrollController.position.viewportDimension / 2;
    final targetOffset = (chipOffset - viewportHalf + _chipWidth / 2)
        .clamp(0.0, _scrollController.position.maxScrollExtent);

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getWeekdayLabel(int weekday, AppLocalizations l10n) {
    switch (weekday) {
      case DateTime.monday: return l10n.weekdayMon;
      case DateTime.tuesday: return l10n.weekdayTue;
      case DateTime.wednesday: return l10n.weekdayWed;
      case DateTime.thursday: return l10n.weekdayThu;
      case DateTime.friday: return l10n.weekdayFri;
      case DateTime.saturday: return l10n.weekdaySat;
      case DateTime.sunday: return l10n.weekdaySun;
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final displayDates = _buildDisplayDates();

    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: theme.surface,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: displayDates.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: _chipSpacing),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isAll = widget.selectedDate == null;
            return _buildChip(
              theme: theme,
              isSelected: isAll,
              topText: l10n.filterAll,
              bottomText: '∞',
              onTap: () => widget.onDateSelected(null),
            );
          }
          final date = displayDates[index - 1];
          final sel = widget.selectedDate;
          final isSelected = sel != null &&
              sel.year == date.year &&
              sel.month == date.month &&
              sel.day == date.day;
          return _buildChip(
            theme: theme,
            isSelected: isSelected,
            topText: _getWeekdayLabel(date.weekday, l10n),
            bottomText: date.day.toString().padLeft(2, '0'),
            onTap: () => widget.onDateSelected(isSelected ? null : date),
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
          width: _chipWidth,
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

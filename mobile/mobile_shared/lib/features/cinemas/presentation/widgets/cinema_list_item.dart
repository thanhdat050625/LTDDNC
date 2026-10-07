import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class CinemaListItem extends StatelessWidget {
  final CinemaModel cinema;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CinemaListItem({
    super.key,
    required this.cinema,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return l10n.cinemaStatusActive;
      case 'INACTIVE':
        return l10n.cinemaStatusInactive;
      case 'MAINTENANCE':
        return l10n.cinemaStatusMaintenance;
      default:
        return status;
    }
  }

  Color _getStatusColor(String status, CineplexColors theme) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return theme.success;
      case 'INACTIVE':
        return theme.textSecondary;
      case 'MAINTENANCE':
        return theme.warning;
      default:
        return theme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CineplexColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _getStatusColor(cinema.status, theme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(theme.radiusMd),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cinema.name,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(cinema.status, l10n),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 14, color: theme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cinema.address.isNotEmpty ? cinema.address : '-',
                    style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.phone, size: 14, color: theme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  cinema.phone.isNotEmpty ? cinema.phone : '-',
                  style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
                ),
                const SizedBox(width: 14),
                Icon(LucideIcons.monitorPlay, size: 14, color: theme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${cinema.roomsCount ?? cinema.rooms?.length ?? 0} ${l10n.roomCount.toLowerCase()}',
                  style: TextStyle(color: theme.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.edit3, size: 18, color: theme.accent),
                  onPressed: onEdit,
                  tooltip: l10n.editCinema,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: const EdgeInsets.all(8),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(LucideIcons.trash2, size: 18, color: theme.error),
                  onPressed: onDelete,
                  tooltip: l10n.delete,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

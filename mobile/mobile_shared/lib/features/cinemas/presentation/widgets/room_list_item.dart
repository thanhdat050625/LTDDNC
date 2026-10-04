import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomListItem extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewSeats;

  const RoomListItem({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
    this.onViewSeats,
  });

  String _getRoomTypeLabel(String type, AppLocalizations l10n) {
    switch (type.toUpperCase()) {
      case 'STANDARD':
        return l10n.roomTypeStandard;
      case 'VIP':
        return l10n.roomTypeVIP;
      case 'IMAX':
        return l10n.roomTypeIMAX;
      case '4DX':
        return l10n.roomType4DX;
      default:
        return type;
    }
  }

  String _getStatusLabel(String status, AppLocalizations l10n) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return l10n.roomStatusActive;
      case 'INACTIVE':
        return l10n.roomStatusInactive;
      case 'MAINTENANCE':
        return l10n.roomStatusMaintenance;
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
    final statusColor = _getStatusColor(room.status, theme);

    return AppCard(
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
                  room.name,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              // Status Badge
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
                  _getStatusLabel(room.status, l10n),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Room Type & Seat Matrix Info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getRoomTypeLabel(room.roomType, l10n),
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${room.totalSeats} ${l10n.seatUnit} • ${room.rows}x${room.columns}',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(color: theme.borderSubtle, height: 1),
          const SizedBox(height: 4),
          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onViewSeats != null)
                TextButton.icon(
                  onPressed: onViewSeats,
                  icon: Icon(LucideIcons.layoutGrid, size: 15, color: theme.accent),
                  label: Text(
                    l10n.viewSeatMap,
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(LucideIcons.edit3, size: 18, color: theme.accent),
                    onPressed: onEdit,
                    tooltip: l10n.editRoom,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                    padding: const EdgeInsets.all(8),
                  ),
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
        ],
      ),
    );
  }
}

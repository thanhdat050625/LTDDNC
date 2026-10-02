import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class RoomListItem extends StatelessWidget {
  final RoomModel room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RoomListItem({
    super.key,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return AppCard(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        room.roomType,
                        style: TextStyle(color: theme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (room.status == 'ACTIVE' ? theme.success : theme.textSecondary).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        room.status,
                        style: TextStyle(
                          color: room.status == 'ACTIVE' ? theme.success : theme.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(LucideIcons.edit3, size: 20, color: theme.accent),
                onPressed: onEdit,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(4),
              ),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 20, color: theme.error),
                onPressed: onDelete,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

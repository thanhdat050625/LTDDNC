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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.all(theme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    cinema.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: theme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (cinema.status == 'ACTIVE' ? theme.success : theme.error).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    cinema.status,
                    style: TextStyle(
                      color: cinema.status == 'ACTIVE' ? theme.success : theme.error,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: theme.spacingSm),
            Row(
              children: [
                Icon(LucideIcons.mapPin, size: 14, color: theme.textSecondary),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    cinema.address ?? '-',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(LucideIcons.phone, size: 14, color: theme.textSecondary),
                SizedBox(width: 4),
                Text(
                  cinema.phone ?? '-',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                ),
                SizedBox(width: 12),
                Icon(LucideIcons.monitorPlay, size: 14, color: theme.textSecondary),
                SizedBox(width: 4),
                Text(
                  '${cinema.roomsCount ?? 0} ${AppLocalizations.of(context)!.roomCount.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
                ),
              ],
            ),
            SizedBox(height: theme.spacingMd),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.edit3, size: 20, color: theme.accent),
                  onPressed: onEdit,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.all(4),
                ),
                SizedBox(width: theme.spacingSm),
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionListItem extends StatelessWidget {
  final ConcessionProductModel concession;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConcessionListItem({
    super.key,
    required this.concession,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

    Color stockColor = theme.success;
    if (concession.stockQuantity == 0) {
      stockColor = theme.error;
    } else if (concession.stockQuantity <= 5) {
      stockColor = Colors.orange;
    }

    return AppCard(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  concession.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${concession.stockQuantity}',
                  style: TextStyle(
                    color: stockColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacingSm),
          Row(
            children: [
              Icon(LucideIcons.tag, size: 14, color: theme.textSecondary),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  FormatUtils.formatCurrency(concession.price.toDouble()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.accent, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
    );
  }
}

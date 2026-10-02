import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class PromotionListItem extends StatelessWidget {
  final PromotionModel promotion;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PromotionListItem({
    super.key,
    required this.promotion,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<CineplexColors>()!;

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
                  promotion.code.toUpperCase(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (promotion.isActive ? theme.success : theme.error).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  promotion.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    color: promotion.isActive ? theme.success : theme.error,
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
              Icon(LucideIcons.tag, size: 14, color: theme.textSecondary),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  promotion.discountType == 'PERCENTAGE' 
                    ? '${promotion.discountValue}%' 
                    : FormatUtils.formatCurrency(promotion.discountValue.toDouble()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: theme.accent, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: theme.textSecondary),
              SizedBox(width: 4),
              Text(
                '${FormatUtils.formatDate(promotion.startDate)} - ${FormatUtils.formatDate(promotion.endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.users, size: 14, color: theme.textSecondary),
              SizedBox(width: 4),
              Text(
                '${promotion.usedCount} / ${promotion.maxUsage == null ? '∞' : promotion.maxUsage}',
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
    );
  }
}

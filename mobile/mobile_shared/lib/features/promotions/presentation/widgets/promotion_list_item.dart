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
    final l10n = AppLocalizations.of(context)!;

    final isPercentage = promotion.discountType == 'PERCENTAGE';
    final discountBadgeColor = isPercentage ? const Color(0xFF6366F1) : const Color(0xFF10B981);
    final discountBadgeText = isPercentage ? l10n.percentDiscountBadge : l10n.fixedDiscountBadge;
    final discountIcon = isPercentage ? LucideIcons.percent : LucideIcons.banknote;
    final discountFormatted = isPercentage
        ? '-${promotion.discountValue}%'
        : '-${FormatUtils.formatCurrency(promotion.discountValue.toDouble())}';

    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (promotion.isActive ? theme.success : theme.error).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: (promotion.isActive ? theme.success : theme.error).withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  promotion.isActive ? l10n.statusActive : l10n.statusInactive,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: discountBadgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: discountBadgeColor.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(discountIcon, size: 10, color: discountBadgeColor),
                    const SizedBox(width: 4),
                    Text(
                      discountBadgeText,
                      style: TextStyle(
                        color: discountBadgeColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  discountFormatted,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: discountBadgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${FormatUtils.formatDate(promotion.startDate)} - ${FormatUtils.formatDate(promotion.endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(LucideIcons.users, size: 14, color: theme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${promotion.usedCount} / ${promotion.maxUsage == null ? '∞' : promotion.maxUsage}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(LucideIcons.edit3, size: 18, color: theme.accent),
                onPressed: onEdit,
                tooltip: l10n.editPromotion,
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
    );
  }
}

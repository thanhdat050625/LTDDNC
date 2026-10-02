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
    final l10n = AppLocalizations.of(context)!;

    Color stockColor = theme.success;
    String stockText = l10n.inStockCount(concession.stockQuantity);
    if (concession.stockQuantity == 0) {
      stockColor = theme.error;
      stockText = l10n.outOfStock;
    } else if (concession.stockQuantity <= 5) {
      stockColor = Colors.orange;
      stockText = l10n.lowStockCount(concession.stockQuantity);
    }

    final hasImage = concession.imageUrl != null && concession.imageUrl!.trim().isNotEmpty;

    return AppCard(
      padding: EdgeInsets.all(theme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: theme.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(theme.radiusMd),
              border: Border.all(
                color: theme.textSecondary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(theme.radiusMd),
              child: hasImage
                  ? AppCachedImage(
                      imageUrl: concession.imageUrl!,
                      width: 76,
                      height: 76,
                      borderRadius: theme.radiusMd,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        LucideIcons.popcorn,
                        color: theme.accent,
                        size: 32,
                      ),
                    ),
            ),
          ),
          SizedBox(width: theme.spacingMd),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  concession.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  FormatUtils.formatCurrency(concession.price.toDouble()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: theme.accent,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                // Stock Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: stockColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: stockColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        stockText,
                        style: TextStyle(
                          color: stockColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(LucideIcons.pencil, size: 18, color: theme.accent),
                onPressed: onEdit,
                tooltip: l10n.editProduct,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(LucideIcons.trash2, size: 18, color: theme.error),
                onPressed: onDelete,
                tooltip: l10n.delete,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

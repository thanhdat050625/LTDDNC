import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile_shared/mobile_shared.dart';

class ConcessionListItem extends StatelessWidget {
  final ConcessionProductModel concession;
  final VoidCallback? onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ConcessionListItem({
    super.key,
    required this.concession,
    this.onTap,
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

    final hasImage =
        concession.imageUrl != null && concession.imageUrl!.trim().isNotEmpty;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(theme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Product Thumbnail
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: theme.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  border: Border.all(
                    color: theme.textSecondary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(theme.radiusSm),
                  child: hasImage
                      ? AppCachedImage(
                          imageUrl: concession.imageUrl!,
                          width: 58,
                          height: 58,
                          borderRadius: theme.radiusSm,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Icon(
                            LucideIcons.popcorn,
                            color: theme.accent,
                            size: 26,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      FormatUtils.formatCurrency(concession.price.toDouble()),
                      style: TextStyle(
                        color: theme.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Stock Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: stockColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: stockColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            stockText,
                            style: TextStyle(
                              color: stockColor,
                              fontSize: 10,
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
                    icon: Icon(
                      LucideIcons.pencil,
                      size: 16,
                      color: theme.accent,
                    ),
                    onPressed: onEdit,
                    tooltip: l10n.editProduct,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(height: 2),
                  IconButton(
                    icon: Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: theme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: l10n.delete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

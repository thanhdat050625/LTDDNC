import 'package:flutter/material.dart';
import 'package:mobile_shared/mobile_shared.dart';

import 'package:flutter/services.dart';

class PromotionBanner extends StatelessWidget {
  final List<PromotionModel> promotions;
  const PromotionBanner({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: promotions.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Clipboard.setData(ClipboardData(text: promo.code));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${l10n.promotionApplied}: ${promo.code}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Color(0xFF111827), size: 48),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          promo.code,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          promo.description ?? l10n.specialDiscount,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

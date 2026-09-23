import 'package:flutter/material.dart';
import 'package:cineplex_mobile/features/home/data/models/home_data_model.dart';
import 'package:cineplex_mobile/core/theme/app_colors.dart';

class PromotionBanner extends StatelessWidget {
  final List<PromotionModel> promotions;
  const PromotionBanner({super.key, required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) return const SizedBox.shrink();
    
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: promotions.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final promo = promotions[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.local_offer, color: Colors.white, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(promo.code, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(promo.description ?? 'Special discount', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

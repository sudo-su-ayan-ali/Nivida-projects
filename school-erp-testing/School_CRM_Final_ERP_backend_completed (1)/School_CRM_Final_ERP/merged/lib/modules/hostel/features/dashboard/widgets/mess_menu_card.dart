import "package:flutter/material.dart";
import "../../../core/theme/app_colors.dart";
import "../../../core/constants/app_spacing.dart";
import "../../../shared/widgets/app_card.dart";

class MessMenuCard extends StatelessWidget {
  const MessMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = [
      (Icons.free_breakfast_rounded, AppColors.warning, "Breakfast", "Poha, Bread, Banana, Tea"),
      (Icons.rice_bowl_rounded, AppColors.success, "Lunch", "Rice, Dal, Paneer Curry, Salad"),
      (Icons.local_cafe_rounded, AppColors.info, "Evening Snacks", "Sandwich, Coffee"),
      (Icons.dinner_dining_rounded, AppColors.purple, "Dinner", "Roti, Mix Veg, Dal Tadka, Rice"),
    ];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
        const SectionHeader(title: "Mess Menu - Today"),
          const SizedBox(height: 8),
          ...meals.map((m) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: m.$2.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.sm)),
                      child: Icon(m.$1, color: m.$2, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$3, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(m.$4, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

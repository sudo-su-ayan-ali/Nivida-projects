import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';
import 'common/form_widgets.dart';

class UpgradePlanCard extends StatelessWidget {
  const UpgradePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.yellowBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC98A0A), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Upgrade Your Plan', style: AppTextStyles.itemTitle.copyWith(fontSize: 14.5)),
                const SizedBox(height: 2),
                Text('Unlock premium features and advanced tools', style: AppTextStyles.itemSub),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _showUpgradeDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }
}

void _showUpgradeDialog(BuildContext context) {
  showAppFormDialog(
    context: context,
    title: 'Upgrade Your Plan',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _planTile('Plus', '₹299/mo', ['Unlimited assignments', 'Advanced analytics', 'Email support']),
        const SizedBox(height: 10),
        _planTile('Pro', '₹599/mo', ['Everything in Plus', 'AI grading assist', 'Priority support'], highlighted: true),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: AppPrimaryButton(
            label: 'Maybe later',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ],
    ),
  );
}

Widget _planTile(String name, String price, List<String> features, {bool highlighted = false}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: highlighted ? AppColors.primaryLight : AppColors.scaffoldBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: highlighted ? AppColors.primary : AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.itemTitle.copyWith(fontSize: 15)),
            Text(price, style: AppTextStyles.itemTitle.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 8),
        for (final f in features)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 14, color: AppColors.green),
                const SizedBox(width: 6),
                Text(f, style: AppTextStyles.itemSub),
              ],
            ),
          ),
      ],
    ),
  );
}

class MotivationCard extends StatelessWidget {
  const MotivationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.primaryGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keep Inspiring! ✨', style: AppTextStyles.itemTitle.copyWith(color: Colors.white, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  'Your dedication shapes the future.',
                  style: AppTextStyles.itemSub.copyWith(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }
}

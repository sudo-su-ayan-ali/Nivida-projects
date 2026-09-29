import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_card.dart';

/// Small stat card used for Transport / Hostel / Document Verification / ID Cards row.
class InfoMiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String bigValue;
  final String subLine;
  final String linkText;
  final VoidCallback? onTap;

  const InfoMiniCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.bigValue,
    required this.subLine,
    this.linkText = 'View Details',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(bigValue, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(subLine, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
         
        ],
      ),
    );
  }
}

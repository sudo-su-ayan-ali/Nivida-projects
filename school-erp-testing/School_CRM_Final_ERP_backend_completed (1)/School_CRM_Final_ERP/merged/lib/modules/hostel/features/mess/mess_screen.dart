import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/responsive/responsive.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/widgets/app_breadcrumb.dart';

class MessScreen extends StatelessWidget {
  const MessScreen({super.key});

  static const _weekly = {
    'Monday': ('Poha, Tea', 'Rice, Dal, Aloo Gobi', 'Biscuits, Coffee', 'Roti, Rajma, Rice'),
    'Tuesday': ('Idli, Sambhar', 'Rice, Dal, Bhindi Fry', 'Fruit Chaat', 'Roti, Chana Masala'),
    'Wednesday': ('Paratha, Curd', 'Rice, Dal, Paneer Curry', 'Sandwich, Tea', 'Roti, Mix Veg'),
    'Thursday': ('Upma, Tea', 'Rice, Dal, Bhindi', 'Namkeen, Coffee', 'Roti, Dal Makhani'),
    'Friday': ('Poha, Bread, Banana, Tea', 'Rice, Dal, Paneer Curry, Salad', 'Sandwich, Coffee', 'Roti, Mix Veg, Dal Tadka, Rice'),
    'Saturday': ('Chole Bhature', 'Veg Biryani, Raita', 'Pakora, Chai', 'Roti, Malai Kofta'),
    'Sunday': ('Aloo Paratha, Curd', 'Special Thali', 'Pastry, Juice', 'Roti, Paneer Butter Masala'),
  };

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
        return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppBreadcrumb(items: const ['Mess & Food Management']),
          const SizedBox(height: 10),
          const Text('Mess & Food Management', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          const Text('Manage weekly menus, meal attendance, and mess inventory.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xl),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.statColumns(context).clamp(1, 4),
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.5,
            children: const [
              StatCard(icon: Icons.restaurant_rounded, color: AppColors.primary, value: '186', label: 'Meals Served Today'),
              StatCard(icon: Icons.currency_rupee_rounded, color: AppColors.warning, value: '₹18,400', label: "This Week's Expense"),
              StatCard(icon: Icons.inventory_2_rounded, color: AppColors.success, value: '42', label: 'Inventory Items'),
              StatCard(icon: Icons.report_problem_rounded, color: AppColors.danger, value: '2', label: 'Open Mess Complaints'),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SectionHeader(title: 'Weekly Menu'),
                const SizedBox(height: AppSpacing.lg),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(AppColors.background),
                    columns: const [
                      DataColumn(label: Text('Day')),
                      DataColumn(label: Text('Breakfast')),
                      DataColumn(label: Text('Lunch')),
                      DataColumn(label: Text('Snacks')),
                      DataColumn(label: Text('Dinner')),
                    ],
                    rows: _weekly.entries
                        .map((e) => DataRow(cells: [
                              DataCell(Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700))),
                              DataCell(Text(e.value.$1, style: const TextStyle(fontSize: 12.5))),
                              DataCell(Text(e.value.$2, style: const TextStyle(fontSize: 12.5))),
                              DataCell(Text(e.value.$3, style: const TextStyle(fontSize: 12.5))),
                              DataCell(Text(e.value.$4, style: const TextStyle(fontSize: 12.5))),
                            ]))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Flex(
            direction: isDesktop ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'Meal Attendance Today'),
                      const SizedBox(height: 12),
                      _mealBar('Breakfast', 210, 256),
                      _mealBar('Lunch', 238, 256),
                      _mealBar('Evening Snacks', 190, 256),
                      _mealBar('Dinner', 224, 256),
                    ],
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? AppSpacing.xl : 0, height: isDesktop ? 0 : AppSpacing.xl),
              Expanded(
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SectionHeader(title: 'Food Inventory Status'),
                      const SizedBox(height: 12),
                      _inventoryRow('Rice', '120 kg', 'In Stock'),
                      _inventoryRow('Wheat Flour', '85 kg', 'In Stock'),
                      _inventoryRow('Cooking Oil', '18 L', 'Low Stock'),
                      _inventoryRow('Pulses (Dal)', '60 kg', 'In Stock'),
                      _inventoryRow('LPG Cylinders', '2 units', 'Reorder'),
                    ],
                  ),
                ),
              ),
            ],
          ),
           ],
      ),
    );
  }

  Widget _mealBar(String label, int served, int total) {
    final pct = served / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
            Text('$served/$total', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: pct, minHeight: 8, backgroundColor: AppColors.border, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _inventoryRow(String item, String qty, String status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(item, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(qty, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          StatusBadge(status: status == 'In Stock' ? 'Approved' : status == 'Low Stock' ? 'Pending' : 'Rejected'),
        ],
      ),
    );
  }
}

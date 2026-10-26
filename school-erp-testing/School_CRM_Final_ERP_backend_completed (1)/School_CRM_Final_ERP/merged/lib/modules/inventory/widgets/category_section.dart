import 'package:flutter/material.dart';
import '../models/inventory_models.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import 'section_card.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final categories = appState.liveCategories;
    final columns = Responsive.gridColumns(context, mobile: 2, tablet: 3, desktop: 3);

    final isFiltered = appState.categoryFilter != 'All Categories';

    return SectionCard(
      title: 'Category Wise Items',
      actionLabel: isFiltered ? 'View All' : null,
      onAction: isFiltered
          ? () {
              appState.setCategoryFilter('All Categories');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Showing all categories')),
              );
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (categories.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No categories yet — add an item to get started',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: categories
                      .map((c) => SizedBox(
                            width: width,
                            child: _CategoryTile(
                              data: c,
                              selected: appState.categoryFilter == c.name,
                              onTap: () {
                                appState.setCategoryFilter(c.name);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Filtered by ${c.name} — see table below')),
                                );
                              },
                            ),
                          ))
                      .toList(),
                );
              },
            ),
      
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryData data;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryTile({required this.data, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(color: data.bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(data.icon, color: data.color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${data.itemCount} Items',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

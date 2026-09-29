import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/csv_builder.dart';
import '../utils/export_helper.dart';
import '../utils/responsive.dart';
import 'dialogs/add_edit_item_dialog.dart';

class ToolbarSection extends StatefulWidget {
  const ToolbarSection({super.key});

  @override
  State<ToolbarSection> createState() => _ToolbarSectionState();
}

class _ToolbarSectionState extends State<ToolbarSection> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final isDesktop = Responsive.isDesktop(context);

    // Keep the field in sync if search was cleared elsewhere (e.g. "View All Items").
    if (_searchCtrl.text != appState.searchQuery) {
      _searchCtrl.value = _searchCtrl.value.copyWith(
        text: appState.searchQuery,
        selection: TextSelection.collapsed(offset: appState.searchQuery.length),
      );
    }

    final searchField = Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: appState.setSearch,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Search items, categories, brands...',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (appState.searchQuery.isNotEmpty)
            InkWell(
              onTap: () => appState.setSearch(''),
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
              ),
            ),
        ],
      ),
    );

    final filters = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _FilterMenu(label: appState.categoryFilter, options: appState.categoryOptions, onSelected: appState.setCategoryFilter),
        _FilterMenu(label: appState.locationFilter, options: appState.locationOptions, onSelected: appState.setLocationFilter),
        _FilterMenu(label: appState.statusFilter, options: appState.statusOptions, onSelected: appState.setStatusFilter),
      ],
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _OutlinedActionButton(
          icon: Icons.download_rounded,
          label: 'Export Report',
          onTap: () => _exportReport(context, appState),
        ),
        PopupMenuButton<String>(
          tooltip: 'More Actions',
          onSelected: (v) => _handleMoreAction(context, appState, v),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'refresh', child: Text('Refresh / Clear Filters')),
            PopupMenuItem(value: 'print', child: Text('Print Table')),
            PopupMenuItem(value: 'import', child: Text('Import Items')),
          ],
          child: const _StaticChip(icon: Icons.more_horiz_rounded, label: 'More Actions'),
        ),
        _FilledActionButton(
          label: 'Add New Item',
          onTap: () => _addItem(context, appState),
        ),
      ],
    );

    if (isDesktop) {
      return Row(
        children: [
          Expanded(flex: 3, child: searchField),
          const SizedBox(width: 12),
          filters,
          const Spacer(),
          actions,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchField,
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: filters),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: actions),
      ],
    );
  }

  Future<void> _addItem(BuildContext context, AppState appState) async {
    final item = await showDialog(context: context, builder: (_) => const AddEditItemDialog());
    if (item == null || !context.mounted) return;
    await appState.addNewItem(item);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${item.name} added to inventory')));
  }

  void _exportReport(BuildContext context, AppState appState) {
    final csv = buildInventoryCsv(appState.filteredItems);
    final downloaded = downloadTextFile('inventory_report.csv', csv);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(downloaded
            ? 'Report exported — inventory_report.csv downloaded'
            : 'Export is only downloadable on Flutter Web in this demo (${appState.filteredItems.length} rows generated)'),
      ),
    );
  }

  void _handleMoreAction(BuildContext context, AppState appState, String action) {
    String message;
    switch (action) {
      case 'refresh':
        appState.clearFilters();
        message = 'Filters cleared';
        break;
      case 'print':
        message = 'Print is only available on Flutter Web in this demo';
        break;
      case 'import':
        message = 'Import is a demo action — no backend is connected';
        break;
      default:
        message = 'Done';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FilterMenu extends StatelessWidget {
  final String label;
  final List<String> options;
  final ValueChanged<String> onSelected;
  const _FilterMenu({required this.label, required this.options, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: onSelected,
      itemBuilder: (_) => options.map((o) => PopupMenuItem(value: o, child: Text(o))).toList(),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _StaticChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StaticChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _OutlinedActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OutlinedActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: _StaticChip(icon: icon, label: label),
      ),
    );
  }
}

class _FilledActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _FilledActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [BoxShadow(color: Color(0x336C5CE7), blurRadius: 14, offset: Offset(0, 6))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/app_state_provider.dart';

class AppHeader extends StatefulWidget implements PreferredSizeWidget {
  final bool showMenuButton;
  const AppHeader({super.key, this.showMenuButton = false});

  @override
  State<AppHeader> createState() => _AppHeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(76);
}

class _AppHeaderState extends State<AppHeader> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlay;

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showResults(BuildContext context, AppStateProvider state) {
    _removeOverlay();
    final results = state.globalSearch(_searchController.text);
    if (results.isEmpty) return;
    final box = context.findRenderObject() as RenderBox;
    _overlay = OverlayEntry(
      builder: (context) => Positioned(
        width: box.size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, box.size.height + 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(14),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 340),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final r = results[i];
                  return ListTile(
                    dense: true,
                    leading: Icon(r.icon, size: 18, color: AppColors.primary),
                    title: Text(r.title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(r.subtitle, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(r.category, style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                    onTap: () {
                      _searchController.clear();
                      _searchFocus.unfocus();
                      _removeOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlay!);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 900;

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border)),
      ),
      child: Row(
        children: [
          if (widget.showMenuButton)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
         if (!isNarrow) ...[
  InkWell(
    onTap: () => state.goTo(AppSection.dashboard),
    child: Row(
      children: [
        const Icon(Icons.grid_view_rounded, size: 15, color: AppColors.primary),
        const SizedBox(width: 4),
        Text('Parents', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
      ],
    ),
  ),
  const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Icon(Icons.chevron_right, size: 16, color: AppColors.muted),
  ),
  Text(_sectionLabel(state.section), style: const TextStyle(fontWeight: FontWeight.w700)),
  const SizedBox(width: 24),
],
          if (!isNarrow)
            Expanded(
              child: CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Search student name, roll no...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    state.setSearchQuery(v);
                    if (v.trim().isEmpty) {
                      _removeOverlay();
                    } else {
                      _showResults(context, state);
                    }
                  },
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 16),
        
          if (!isNarrow) ...[
            const SizedBox(width: 8),
            Container(width: 1, height: 32, color: isDark ? AppColors.borderDark : AppColors.border),
            const SizedBox(width: 12),
                        Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(state.schoolName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  Text(state.academicSession, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.expand_more, size: 18, color: AppColors.muted),
            const SizedBox(width: 12),
          ],
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.statBg(AppColors.primary), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
          ),
        ],
      ),
    );
  }


  String _sectionLabel(AppSection s) {
    switch (s) {
      case AppSection.dashboard:
        return 'Dashboard';
      case AppSection.myChildren:
        return 'My Children';
      case AppSection.attendance:
        return 'Attendance';
      case AppSection.academics:
        return 'Academics';
      case AppSection.fees:
        return 'Fees & Payments';
      case AppSection.examinations:
        return 'Examinations';
      case AppSection.homework:
        return 'Homework';
      case AppSection.timetable:
        return 'Timetable';
      case AppSection.transport:
        return 'Transport';
      case AppSection.library:
        return 'Library';
      case AppSection.notices:
        return 'Notices';
      case AppSection.events:
        return 'Events';
      case AppSection.teacherCommunication:
        return 'Teacher Communication';
      case AppSection.settings:
        return 'Settings';
    }
  }
}

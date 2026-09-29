import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'account_dialogs.dart';

class _PanelItem {
  final String title;
  final String subtitle;
  final String time;
  const _PanelItem(this.title, this.subtitle, this.time);
}

const _kNotifications = [
  _PanelItem('Leave request from Mr. Sandeep Yadav', 'Awaiting your approval', '10m ago'),
  _PanelItem('Exam schedule published', 'Mid-term dates are now live', '1h ago'),
  _PanelItem('New teacher added', 'Ms. Neha Singh joined Computer Science', '3h ago'),
];

const _kMessages = [
  _PanelItem('Priya Verma', 'Can you review the physics syllabus draft?', '5m ago'),
  _PanelItem('Amit Kumar', 'Sent the English literature notes.', '40m ago'),
  _PanelItem('Sandeep Yadav', 'Thanks for approving my leave!', '2h ago'),
  _PanelItem('Admin Office', 'Staff meeting moved to Friday 3 PM.', 'Yesterday'),
];

/// Sticky top header: hamburger + breadcrumb, global search (drives the
/// Teacher List filter below), and a fully working notification / message
/// / settings / school-session cluster.
class TopHeader extends StatefulWidget {
  final VoidCallback onMenuTap;
  final String searchValue;
  final ValueChanged<String> onSearchChanged;

  const TopHeader({
    super.key,
    required this.onMenuTap,
    required this.searchValue,
    required this.onSearchChanged,
  });

  @override
  State<TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<TopHeader> {
  late final TextEditingController _searchCtrl;
  int _unreadNotifications = 3;
  int _unreadMessages = 7;
  String _session = 'Session: 2024–25';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchValue);
  }

  @override
  void didUpdateWidget(covariant TopHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_searchCtrl.text != widget.searchValue) {
      _searchCtrl.value = TextEditingValue(
        text: widget.searchValue,
        selection: TextSelection.collapsed(offset: widget.searchValue.length),
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openPanel({required String title, required List<_PanelItem> items, required IconData icon, required Color accent}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: title,
      barrierColor: Colors.black.withOpacity(0.04),
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (ctx, __, ___) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 78, right: 24),
            child: Material(
              color: Colors.white,
              elevation: 14,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 320,
                constraints: const BoxConstraints(maxHeight: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 10, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.text)),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.pop(ctx),
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (_, i) {
                          final it = items[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(radius: 17, backgroundColor: accent.withOpacity(0.12), child: Icon(icon, size: 16, color: accent)),
                            title: Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text)),
                            subtitle: Text(it.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            trailing: Text(it.time, style: const TextStyle(fontSize: 9.5, color: Color(0xFFB0B4C4), fontWeight: FontWeight.w600)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, __, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          alignment: Alignment.topRight,
          scale: Tween<double>(begin: 0.94, end: 1).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width > 900;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.96),
        boxShadow: AppColors.softerShadow,
      ),
      child: Row(
        children: [
          
          if (wide)
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(text: 'Teachers', style: TextStyle(color: AppColors.primary)),
                  TextSpan(text: ' / Dashboard', style: TextStyle(color: Color(0xFF9CA3AF))),
                ],
              ),
            ),
          const SizedBox(width: 24),
          if (wide)
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 18, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: widget.onSearchChanged,
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Search here...',
                            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                            border: InputBorder.none,
                            isDense: true,
                            suffixIcon: _searchCtrl.text.isEmpty
                                ? null
                                : InkWell(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      widget.onSearchChanged('');
                                    },
                                    child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF9CA3AF)),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 16),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() => _unreadNotifications = 0);
              _openPanel(title: 'Notifications', items: _kNotifications, icon: Icons.notifications_rounded, accent: AppColors.danger);
            },
            child: _IconBadge(icon: Icons.notifications_none_rounded, count: _unreadNotifications, color: AppColors.danger),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              setState(() => _unreadMessages = 0);
              _openPanel(title: 'Messages', items: _kMessages, icon: Icons.mail_rounded, accent: AppColors.primary);
            },
            child: _IconBadge(icon: Icons.mail_outline_rounded, count: _unreadMessages, color: AppColors.primary),
          ),
          if (wide) ...[
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => showAccountSettingsDialog(context),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(Icons.settings_outlined, color: Color(0xFF4B5563)),
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 1, height: 30, color: AppColors.border),
            const SizedBox(width: 12),
            PopupMenuButton<String>(
              tooltip: 'Switch session',
              offset: const Offset(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                setState(() => _session = 'Session: $v');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Switched to session $v.'), behavior: SnackBarBehavior.floating),
                );
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: '2025–26', child: Text('2025–26')),
                PopupMenuItem(value: '2024–25', child: Text('2024–25 (current)')),
                PopupMenuItem(value: '2023–24', child: Text('2023–24 (archived)')),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Greenfield Public School',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.text)),
                      Text(_session, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF), size: 18),
                ],
              ),
            ),
          ],
          const SizedBox(width: 12),
          Tooltip(
            message: 'Greenfield Public School is a verified EduSmart institution',
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Greenfield Public School is a verified EduSmart institution.'), behavior: SnackBarBehavior.floating),
              ),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: const Color(0xFFEEF0FF), borderRadius: BorderRadius.circular(18)),
                child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _IconBadge({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(child: Icon(icon, color: const Color(0xFF4B5563), size: 22)),
          if (count > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

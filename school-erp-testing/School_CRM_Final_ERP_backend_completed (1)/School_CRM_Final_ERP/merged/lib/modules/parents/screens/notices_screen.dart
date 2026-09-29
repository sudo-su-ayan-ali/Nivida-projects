import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_card.dart';

enum _NoticeFilter { all, unread }

class NoticesScreen extends StatefulWidget {
  const NoticesScreen({super.key});

  @override
  State<NoticesScreen> createState() => _NoticesScreenState();
}

class _NoticesScreenState extends State<NoticesScreen> {
  final _searchCtrl = TextEditingController();
  _NoticeFilter _filter = _NoticeFilter.all;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final query = _searchCtrl.text.toLowerCase();

    var notices = state.notices.where((n) {
      final matchesQuery = query.isEmpty ||
          n.title.toLowerCase().contains(query) ||
          n.description.toLowerCase().contains(query);
      final matchesFilter = _filter == _NoticeFilter.all || !n.read;
      return matchesQuery && matchesFilter;
    }).toList()
      ..sort((a, b) => b.postedAt.compareTo(a.postedAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Notices', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            TextButton(
              onPressed: state.markAllNoticesRead,
              child: const Text('Mark all as read'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(hintText: 'Search notices...', prefixIcon: Icon(Icons.search, size: 20)),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            SegmentedButton<_NoticeFilter>(
              segments: const [
                ButtonSegment(value: _NoticeFilter.all, label: Text('All')),
                ButtonSegment(value: _NoticeFilter.unread, label: Text('Unread')),
              ],
              selected: {_filter},
              onSelectionChanged: (s) => setState(() => _filter = s.first),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: notices.isEmpty
              ? const EmptyState(icon: Icons.campaign_outlined, message: 'No notices match your search.')
              : Column(
                  children: [
                    for (final n in notices) ...[
                      _noticeRow(context, state, n),
                      const Divider(height: 24),
                    ],
                  ],
                ),
        ),
      ],
    );
  }

  Widget _noticeRow(BuildContext context, AppStateProvider state, Notice n) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _openDetails(context, state, n),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.statBg(n.color), borderRadius: BorderRadius.circular(10)),
            child: Icon(n.icon, size: 18, color: n.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                    if (!n.read)
                      Container(width: 8, height: 8, margin: const EdgeInsets.only(left: 6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(n.description, style: TextStyle(fontSize: 12.5, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(DateFormat('dd MMM yyyy, hh:mm a').format(n.postedAt), style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openDetails(BuildContext context, AppStateProvider state, Notice n) {
    state.markNoticeRead(n.id);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(n.title),
        content: Text(n.description),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/section_card.dart';

class TeacherCommunicationScreen extends StatefulWidget {
  const TeacherCommunicationScreen({super.key});

  @override
  State<TeacherCommunicationScreen> createState() => _TeacherCommunicationScreenState();
}

class _TeacherCommunicationScreenState extends State<TeacherCommunicationScreen> {
  String? _selectedThreadId;
  final _searchCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  final state = context.watch<AppStateProvider>();
  final query = _searchCtrl.text.toLowerCase();
  final threads = state.threads
      .where((t) => query.isEmpty || t.teacherName.toLowerCase().contains(query) || t.subject.toLowerCase().contains(query))
      .toList()
    ..sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));

  final isWide = MediaQuery.of(context).size.width >= 900;

  if (state.threads.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Teacher Communication', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Message your children\'s teachers directly.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        SizedBox(
          height: 560,
          child: SectionCard(
            child: Center(
              child: Text(
                'No messages yet',
                style: TextStyle(color: AppColors.muted, fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  if (_selectedThreadId == null || !threads.any((t) => t.id == _selectedThreadId)) {
    _selectedThreadId = threads.isNotEmpty ? threads.first.id : state.threads.first.id;
  }
  final selectedThread = threads.firstWhere(
    (t) => t.id == _selectedThreadId,
    orElse: () => state.threads.first,
  );

  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Teacher Communication', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Message your children\'s teachers directly.', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 16),
        SizedBox(
          height: 560,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 320, child: _threadList(context, state, threads)),
                    const SizedBox(width: 20),
                    Expanded(child: _chatPanel(context, state, selectedThread)),
                  ],
                )
              : _selectedThreadId == null
                  ? _threadList(context, state, threads)
                  : Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => setState(() => _selectedThreadId = null),
                            icon: const Icon(Icons.arrow_back, size: 16),
                            label: const Text('Back'),
                          ),
                        ),
                        Expanded(child: _chatPanel(context, state, selectedThread)),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _threadList(BuildContext context, AppStateProvider state, List<TeacherThread> threads) {
    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Search teacher...', prefixIcon: Icon(Icons.search, size: 18), isDense: true),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = threads[i];
                final selected = t.id == _selectedThreadId;
                return Material(
                  color: selected ? AppColors.statBg(AppColors.primary) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      state.openThread(t.id);
                      setState(() => _selectedThreadId = t.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: t.avatarColor,
                            child: Text(t.avatarInitials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.teacherName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(t.subject, style: TextStyle(fontSize: 11, color: AppColors.muted)),
                                const SizedBox(height: 2),
                                Text(t.lastMessagePreview, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          if (t.unread)
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatPanel(BuildContext context, AppStateProvider state, TeacherThread thread) {
    return SectionCard(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                CircleAvatar(radius: 18, backgroundColor: thread.avatarColor, child: Text(thread.avatarInitials, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(thread.teacherName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(thread.subject, style: TextStyle(fontSize: 11.5, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: thread.messages.length,
              itemBuilder: (_, i) => _messageBubble(thread.messages[i]),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.border))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageCtrl,
                    decoration: const InputDecoration(hintText: 'Type a message...', isDense: true),
                    onSubmitted: (_) => _send(state, thread.id),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _send(state, thread.id),
                  icon: const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(AppStateProvider state, String threadId) {
    if (_messageCtrl.text.trim().isEmpty) return;
    state.sendMessage(threadId, _messageCtrl.text);
    _messageCtrl.clear();
  }

  Widget _messageBubble(ChatMessage m) {
    final isParent = m.sender == MessageSender.parent;
    return Align(
      alignment: isParent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isParent ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isParent ? 14 : 2),
            bottomRight: Radius.circular(isParent ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text, style: TextStyle(color: isParent ? Colors.white : AppColors.textPrimary, fontSize: 13)),
            const SizedBox(height: 4),
            Text(DateFormat('hh:mm a').format(m.time), style: TextStyle(fontSize: 10, color: isParent ? Colors.white70 : AppColors.muted)),
          ],
        ),
      ),
    );
  }
}

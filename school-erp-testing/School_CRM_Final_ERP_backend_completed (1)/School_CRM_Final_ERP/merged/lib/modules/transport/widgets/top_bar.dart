import '../data/transport_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/dashboard_models.dart';
import '../data/mock_data.dart';
import 'dialogs/form_controls.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  final List<NotificationData> notifications;
  final List<MessageData> messages;
  final String academicYear;
  final ValueChanged<String> onAcademicYearChanged;
  final void Function(String query) onSearchSelected;
  final VoidCallback onViewAllNotifications;
  final VoidCallback onViewAllMessages;
  final VoidCallback onMarkAllNotificationsRead;

  const TopBar({
    super.key,
    required this.notifications,
    required this.messages,
    required this.academicYear,
    required this.onAcademicYearChanged,
    required this.onSearchSelected,
    required this.onViewAllNotifications,
    required this.onViewAllMessages,
    required this.onMarkAllNotificationsRead,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 1180;
    final unreadNotifs = widget.notifications.where((n) => !n.read).length;
    final unreadMsgs = widget.messages.where((m) => !m.read).length;

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Greenfield International School', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (!isCompact) _AcademicYearSelector(value: widget.academicYear, onChanged: widget.onAcademicYearChanged),
          const SizedBox(width: 20),
          if (!isCompact)
            Expanded(child: _SearchField(onSelected: widget.onSearchSelected))
          else
            const Spacer(),
          const SizedBox(width: 20),
          _NotificationsButton(
            notifications: widget.notifications,
            unread: unreadNotifs,
            onViewAll: widget.onViewAllNotifications,
            onMarkAllRead: widget.onMarkAllNotificationsRead,
          ),
          const SizedBox(width: 10),
          _MessagesButton(messages: widget.messages, unread: unreadMsgs, onViewAll: widget.onViewAllMessages),
          const SizedBox(width: 16),
          Container(width: 1, height: 34, color: AppColors.border),
          const SizedBox(width: 16),
          const _ProfileCard(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search
// ---------------------------------------------------------------------------
class _SearchField extends StatefulWidget {
  final void Function(String query) onSelected;
  const _SearchField({required this.onSelected});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;
  List<String> _index = [];

  @override
  void initState() {
    super.initState();
    _loadIndex();
  }

  Future<void> _loadIndex() async {
    final service = TransportService();
    final routes = await service.fetchRouteNames();
    final drivers = await service.fetchDriverNames();
    final vehicles = await service.fetchVehicleNumbers();
    if (!mounted) return;
    setState(() {
      _index = {...routes, ...drivers, ...vehicles}.toList();
    });
  }

  List<String> _searchIndex() => _index;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue value) {
          if (value.text.trim().isEmpty) return const Iterable<String>.empty();
          final q = value.text.toLowerCase();
          return _searchIndex().where((s) => s.toLowerCase().contains(q));
        },
        onSelected: (selection) {
          widget.onSelected(selection);
        },
        fieldViewBuilder: (context, controller, focusNode, onSubmit) {
          return Focus(
            onFocusChange: (v) => setState(() => _focused = v),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: _focused ? AppColors.primary : AppColors.border, width: _focused ? 1.4 : 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 19, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onSubmitted: (v) => onSubmit(),
                      style: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Search routes, drivers, vehicles…',
                        hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  if (controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        controller.clear();
                        setState(() {});
                      },
                      child: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                      child: Text('⌘K', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                    ),
                ],
              ),
            ),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420, maxHeight: 260),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderSoft),
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.search_rounded, size: 17, color: AppColors.textMuted),
                      title: Text(option, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Academic Year Selector
// ---------------------------------------------------------------------------
class _AcademicYearSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _AcademicYearSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 46),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
      onSelected: onChanged,
      itemBuilder: (context) => MockData.academicYears
          .map((y) => PopupMenuItem<String>(
                value: y,
                child: Row(
                  children: [
                    Icon(y == value ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                        size: 17, color: y == value ? AppColors.primary : AppColors.textMuted),
                    const SizedBox(width: 10),
                    Text('Academic Year: $y', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.info),
            const SizedBox(width: 8),
            Text('Academic Year: $value', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications dropdown
// ---------------------------------------------------------------------------
class _NotificationsButton extends StatelessWidget {
  final List<NotificationData> notifications;
  final int unread;
  final VoidCallback onViewAll;
  final VoidCallback onMarkAllRead;
  const _NotificationsButton({required this.notifications, required this.unread, required this.onViewAll, required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    // `context` here is this widget's own stable BuildContext (part of the
    // permanent page tree) — safe to use for snackbars/callbacks even after
    // the popup route closes. `menuContext` (from the inner Builder) is a
    // descendant of the popup route itself and is what Navigator.pop() must
    // use to close the dropdown.
    return PopupMenuButton<void>(
      offset: const Offset(-300, 46),
      color: Colors.white,
      elevation: 10,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Builder(builder: (menuContext) {
            return SizedBox(
              width: 340,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
                    child: Row(
                      children: [
                        Text('Notifications', style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(menuContext).pop();
                            onMarkAllRead();
                          },
                          child: Text('Mark all read', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderSoft),
                  if (notifications.isEmpty)
                    const Padding(padding: EdgeInsets.all(24), child: Text('No notifications'))
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 320),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: notifications.length > 5 ? 5 : notifications.length,
                        itemBuilder: (_, index) {
                          final n = notifications[index];
                          return ListTile(
                            dense: true,
                            onTap: () {
                              Navigator.of(menuContext).pop();
                              showAppSnackBar(context, n.title, icon: n.icon, color: n.color);
                            },
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(color: n.color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                              child: Icon(n.icon, size: 16, color: n.color),
                            ),
                            title: Text(n.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            subtitle: Text('${n.subtitle} · ${n.time}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                            trailing: n.read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          );
                        },
                      ),
                    ),
                  const Divider(height: 1, color: AppColors.borderSoft),
                  InkWell(
                    onTap: () {
                      Navigator.of(menuContext).pop();
                      onViewAll();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('View all notifications', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
      child: _IconBadgeButton(icon: Icons.notifications_none_rounded, count: unread),
    );
  }
}

// ---------------------------------------------------------------------------
// Messages dropdown
// ---------------------------------------------------------------------------
class _MessagesButton extends StatelessWidget {
  final List<MessageData> messages;
  final int unread;
  final VoidCallback onViewAll;
  const _MessagesButton({required this.messages, required this.unread, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<void>(
      offset: const Offset(-260, 46),
      color: Colors.white,
      elevation: 10,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
      itemBuilder: (_) => [
        PopupMenuItem<void>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Builder(builder: (menuContext) {
            return SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    child: Row(
                      children: [
                        Text('Messages', style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.borderSoft),
                  if (messages.isEmpty)
                    const Padding(padding: EdgeInsets.all(24), child: Text('No messages'))
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: messages.length,
                        itemBuilder: (_, index) {
                          final m = messages[index];
                          return ListTile(
                            dense: true,
                            onTap: () {
                              Navigator.of(menuContext).pop();
                              showAppSnackBar(context, 'Opened conversation with ${m.sender}', icon: Icons.mail_rounded, color: m.color);
                            },
                            leading: CircleAvatar(radius: 17, backgroundColor: m.color.withOpacity(0.15), child: Text(m.initials, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: m.color))),
                            title: Text(m.sender, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            subtitle: Text(m.preview, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                            trailing: m.read ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          );
                        },
                      ),
                    ),
                  const Divider(height: 1, color: AppColors.borderSoft),
                  InkWell(
                    onTap: () {
                      Navigator.of(menuContext).pop();
                      onViewAll();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text('View all messages', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
      child: _IconBadgeButton(icon: Icons.mail_outline_rounded, count: unread),
    );
  }
}

class _IconBadgeButton extends StatefulWidget {
  final IconData icon;
  final int count;
  const _IconBadgeButton({required this.icon, required this.count});

  @override
  State<_IconBadgeButton> createState() => _IconBadgeButtonState();
}

class _IconBadgeButtonState extends State<_IconBadgeButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _hovering ? const Color(0xFFF1F5F9) : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: _hovering ? AppColors.border : Colors.transparent),
            ),
            child: Icon(widget.icon, size: 21, color: AppColors.textSecondary),
          ),
          if (widget.count > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(color: AppColors.danger, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.6)),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Center(
                  child: Text('${widget.count}', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Profile menu
// ---------------------------------------------------------------------------
class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      color: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
      onSelected: (value) {
        if (value == 'logout') {
          showAppSnackBar(context, 'Signed out successfully', icon: Icons.logout_rounded, color: AppColors.textSecondary);
        } else {
          showAppSnackBar(context, value);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(value: 'My Profile', child: _MenuRow(icon: Icons.person_outline_rounded, label: 'My Profile')),
        PopupMenuItem<String>(value: 'Account Settings', child: _MenuRow(icon: Icons.settings_outlined, label: 'Account Settings')),
        PopupMenuItem<String>(value: 'Switch School', child: _MenuRow(icon: Icons.swap_horiz_rounded, label: 'Switch School')),
        const PopupMenuDivider(height: 8),
        PopupMenuItem<String>(value: 'logout', child: _MenuRow(icon: Icons.logout_rounded, label: 'Log Out', color: AppColors.danger)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: AppColors.warning.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 3))],
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Super Admin', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('Administrator', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _MenuRow({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Row(
      children: [
        Icon(icon, size: 17, color: c),
        const SizedBox(width: 10),
        Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: c)),
      ],
    );
  }
}

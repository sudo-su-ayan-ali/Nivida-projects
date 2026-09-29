import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class GreetingSection extends StatefulWidget {
  final bool isMobile;
  const GreetingSection({super.key, this.isMobile = false});

  @override
  State<GreetingSection> createState() => _GreetingSectionState();
}

class _GreetingSectionState extends State<GreetingSection> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _greeting {
    final h = _now.hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: widget.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_greetingText(), const SizedBox(height: 14), _dateTimeChip()],
            )
          : Row(
              children: [
                Expanded(child: _greetingText()),
                _dateTimeChip(),
              ],
            ),
    );
  }

  Widget _greetingText() {
    final name = context.watch<AppState>().teacherName;
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: AppColors.primaryGradient),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.waving_hand_rounded, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$_greeting, $name! 👋', style: AppTextStyles.greetingTitle),
            const SizedBox(height: 4),
            Text("Here's what's happening with your classes today.",
                style: AppTextStyles.greetingSubtitle),
          ],
        ),
      ],
    );
  }

  Widget _dateTimeChip() {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(_now);
    final timeStr = DateFormat('hh:mm a').format(_now);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(dateStr, style: AppTextStyles.itemTitle.copyWith(fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(timeStr, style: AppTextStyles.itemSub),
            ],
          ),
        ],
      ),
    );
  }
}

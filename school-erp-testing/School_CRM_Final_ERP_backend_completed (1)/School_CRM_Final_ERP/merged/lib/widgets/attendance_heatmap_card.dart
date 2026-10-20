import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_card.dart';

const _periodOptions = ['Today', 'This Week', 'This Month'];

Color _heatColor(int v) {
  if (v >= 90) return AppColors.heatBest;
  if (v >= 75) return AppColors.heatGood;
  if (v >= 50) return AppColors.heatFair;
  return AppColors.heatLow;
}

Color _heatTextColor(int v) => v >= 90 ? Colors.white : AppColors.textPrimary;

String _weekdayShort(int weekday) {
  const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return names[weekday - 1];
}

class AttendanceHeatmapCard extends StatefulWidget {
  const AttendanceHeatmapCard({super.key});

  @override
  State<AttendanceHeatmapCard> createState() => _AttendanceHeatmapCardState();
}

class _AttendanceHeatmapCardState extends State<AttendanceHeatmapCard> {
  final ScrollController _scrollController = ScrollController();
  String _selectedPeriod = 'This Week';

  bool _loading = true;
  List<String> _sectionNames = [];
  List<String> _rowLabels = [];
  List<List<int>> _grid = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;
      String? institutionId;
      if (userId != null) {
        final profileRow = await client
            .from('profiles')
            .select('institution_id')
            .eq('id', userId)
            .maybeSingle();
        institutionId = profileRow?['institution_id'] as String?;
      }

      // --- Sections (dynamic columns) ------------------------------------
      var sectionsQuery = client.from('sections').select('id, name');
      if (institutionId != null) {
        sectionsQuery = sectionsQuery.eq('institution_id', institutionId);
      }
      final sectionsData = await sectionsQuery;
      final sections = (sectionsData as List)
          .map((r) => {'id': r['id'] as String, 'name': r['name'] as String})
          .toList();

      // --- Date range based on selected period ----------------------------
      final now = DateTime.now();
      final todayOnly = DateTime(now.year, now.month, now.day);
      List<DateTime> days;
      List<String> rowLabels;
      if (_selectedPeriod == 'Today') {
        days = [todayOnly];
        rowLabels = ['Today'];
      } else if (_selectedPeriod == 'This Week') {
        days = [for (int i = 5; i >= 0; i--) todayOnly.subtract(Duration(days: i))];
        rowLabels = [for (final d in days) _weekdayShort(d.weekday)];
      } else {
        days = [for (int i = 27; i >= 0; i--) todayOnly.subtract(Duration(days: i))];
        rowLabels = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
      }
      final rangeStart = days.first;
      final rangeEnd = days.last.add(const Duration(days: 1));

      // --- Attendance rows in that range -----------------------------------
      var attQuery = client
          .from('attendance_records')
          .select('session_date, section_id, status')
          .gte('session_date', rangeStart.toIso8601String().split('T').first)
          .lt('session_date', rangeEnd.toIso8601String().split('T').first);
      if (institutionId != null) {
        attQuery = attQuery.eq('institution_id', institutionId);
      }
      final attData = await attQuery;
      final attRows = attData as List;

      // --- Build grid --------------------------------------------------------
      final rowCount = _selectedPeriod == 'This Month' ? 4 : days.length;
      final present = List.generate(rowCount, (_) => List.filled(sections.length, 0));
      final total = List.generate(rowCount, (_) => List.filled(sections.length, 0));

      for (final row in attRows) {
        final dateStr = row['session_date'] as String?;
        if (dateStr == null) continue;
        final d = DateTime.tryParse(dateStr);
        if (d == null) continue;
        final secId = row['section_id'] as String?;
        final secIndex = sections.indexWhere((s) => s['id'] == secId);
        if (secIndex == -1) continue;

        int rowIndex;
        if (_selectedPeriod == 'This Month') {
          final dayOffset = d.difference(rangeStart).inDays;
          rowIndex = (dayOffset / 7).floor().clamp(0, 3);
        } else {
          rowIndex = days.indexWhere(
              (day) => day.year == d.year && day.month == d.month && day.day == d.day);
          if (rowIndex == -1) continue;
        }

        total[rowIndex][secIndex] += 1;
        if (row['status'] == 'present') present[rowIndex][secIndex] += 1;
      }

      final grid = List.generate(
        rowCount,
        (r) => List.generate(sections.length, (c) {
          if (total[r][c] == 0) return 0;
          return ((present[r][c] / total[r][c]) * 100).round();
        }),
      );

      if (!mounted) return;
      setState(() {
        _sectionNames = sections.map((s) => s['name'] as String).toList();
        _rowLabels = rowLabels;
        _grid = grid;
        _loading = false;
      });
    } catch (e) {
      debugPrint('ATTENDANCE HEATMAP DEBUG: failed: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance Heatmap',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary),
              ),
              _PeriodDropdown(
                value: _selectedPeriod,
                options: _periodOptions,
                onChanged: (value) {
                  setState(() => _selectedPeriod = value);
                  _load();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loading)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_sectionNames.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(child: Text('No sections found')),
            )
          else
            Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 8,
              radius: const Radius.circular(10),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 12),
                child: Table(
                  defaultColumnWidth: const FixedColumnWidth(64),
                  columnWidths: const {0: FixedColumnWidth(70)},
                  children: [
                    TableRow(children: [
                      const SizedBox(height: 30),
                      for (final c in _sectionNames)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(c,
                                style: AppText.caption.copyWith(fontSize: 10.5)),
                          ),
                        ),
                    ]),
                    for (int r = 0; r < _rowLabels.length; r++)
                      TableRow(children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(_rowLabels[r],
                              style: AppText.body.copyWith(fontSize: 11.5)),
                        ),
                        for (int c = 0; c < _sectionNames.length; c++)
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              height: 30,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _heatColor(_grid[r][c]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('${_grid[r][c]}%',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _heatTextColor(_grid[r][c]))),
                            ),
                          ),
                      ]),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: const [
              _LegendDot(color: AppColors.heatBest, label: '90% and above'),
              _LegendDot(color: AppColors.heatGood, label: '75% - 89%'),
              _LegendDot(color: AppColors.heatFair, label: '50% - 74%'),
              _LegendDot(color: AppColors.heatLow, label: 'Below 50%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _PeriodDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: value,
      onSelected: onChanged,
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Text(option, style: AppText.body),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary)),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppText.caption),
      ],
    );
  }
}
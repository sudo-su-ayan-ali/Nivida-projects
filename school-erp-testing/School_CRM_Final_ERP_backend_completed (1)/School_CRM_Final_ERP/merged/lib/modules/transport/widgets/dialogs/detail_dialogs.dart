import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/dashboard_models.dart';
import '../section_card.dart';
import '../data_table_card.dart';
import 'app_dialog.dart';

// ---------------------------------------------------------------------------
// KPI card drill-down
// ---------------------------------------------------------------------------
void showKpiDetailDialog(BuildContext context, KpiCardData d) {
  showDialog(
    context: context,
    builder: (_) => AppDialog(
      title: d.title,
      subtitle: d.subtitle,
      icon: d.icon,
      color: d.gradient.last,
      width: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(d.value, style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.8)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: d.trendUp ? AppColors.successSoft : AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(d.trendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, size: 12, color: d.trendUp ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 3),
                    Text(d.trend, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: d.trendUp ? AppColors.success : AppColors.danger)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Trend over the last 8 days', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          SizedBox(height: 90, width: double.infinity, child: CustomPaint(painter: _MiniTrendPainter(values: d.sparkline, color: d.gradient.last))),
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 16),
          Text(
            'This figure reflects live activity across all active routes for today. Tap "${d.actionLabel}" from the dashboard to see the full breakdown.',
            style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _MiniTrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _MiniTrendPainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    final dx = size.width / (values.length - 1);

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - ((values[i] - minV) / range) * (size.height - 20) - 6;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = color);
    }
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _MiniTrendPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// Generic "view all" list dialog wrapper
// ---------------------------------------------------------------------------
void _showListDialog({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
  required Widget child,
}) {
  showDialog(
    context: context,
    builder: (_) => AppDialog(
      title: title,
      subtitle: subtitle,
      icon: icon,
      color: color,
      width: 820,
      contentPadding: const EdgeInsets.fromLTRB(22, 6, 22, 22),
      child: child,
    ),
  );
}

void showAllRoutesDialog(BuildContext context, List<RouteSummaryRow> routes) {
  final rows = routes.map((r) {
    return <Widget>[
      TableCellText(r.route, bold: true),
      DriverAvatarCell(name: r.driver, color: AppColors.info),
      TableCellText(r.vehicle, color: AppColors.textSecondary),
      TableCellText('${r.students}', color: AppColors.textSecondary),
      StatusBadge(label: r.status, color: AppColors.success, bgColor: AppColors.successSoft),
      MiniProgressCell(value: r.attendancePresent, total: r.attendanceTotal),
    ];
  }).toList();

    _showListDialog(
    context: context,
    title: 'All Routes',
    subtitle: '${routes.length} routes currently active',
    icon: Icons.alt_route_rounded,
    color: AppColors.primary,
    child: DataTableCard(
      minWidth: 820,
      columns: const [
        TableColumnDef(label: 'ROUTE', flex: 3),
        TableColumnDef(label: 'DRIVER', flex: 3),
        TableColumnDef(label: 'VEHICLE', flex: 2),
        TableColumnDef(label: 'STUDENTS', flex: 2),
        TableColumnDef(label: 'STATUS', flex: 2),
        TableColumnDef(label: 'ATTENDANCE', flex: 2),
      ],
      rows: rows,
    ),
  );
}

void showAllTripsDialog(BuildContext context, List<TripRow> trips) {
  final rows = trips.map((t) {
    final isDrop = t.tripType == 'Drop';
    Color statusColor = AppColors.success;
    Color statusBg = AppColors.successSoft;
    if (t.status == 'Delayed') {
      statusColor = AppColors.danger;
      statusBg = AppColors.dangerSoft;
    } else if (t.status == 'Scheduled') {
      statusColor = AppColors.info;
      statusBg = AppColors.infoSoft;
    }
    return <Widget>[
      TableCellText(t.route, bold: true),
      DriverAvatarCell(name: t.driver, color: AppColors.primary),
      TableCellText(t.vehicle, color: AppColors.textSecondary),
      StatusBadge(label: t.tripType, color: isDrop ? AppColors.warning : AppColors.primary, bgColor: isDrop ? AppColors.warningSoft : AppColors.primarySoft),
      TableCellText(t.time, color: AppColors.textSecondary),
      StatusBadge(label: t.status, color: statusColor, bgColor: statusBg),
    ];
  }).toList();

  _showListDialog(
    context: context,
    title: 'Trip Schedule',
    subtitle: '${trips.length} trips scheduled today',
    icon: Icons.event_note_rounded,
    color: const Color(0xFFDB2777),
    child: DataTableCard(
      minWidth: 620,
      columns: const [
        TableColumnDef(label: 'ROUTE', flex: 3),
        TableColumnDef(label: 'DRIVER', flex: 3),
        TableColumnDef(label: 'VEHICLE', flex: 2),
        TableColumnDef(label: 'TYPE', flex: 2),
        TableColumnDef(label: 'TIME', flex: 2),
        TableColumnDef(label: 'STATUS', flex: 2),
      ],
      rows: rows,
    ),
  );
}

void showFeeReportDialog(BuildContext context, List<FeeCollectionRow> fees) {
  final rows = fees.map((f) {
    final isOnline = f.mode == 'Online';
    return <Widget>[
      TableCellText(f.date, color: AppColors.textSecondary),
      TableCellText(f.amount, bold: true, color: AppColors.success),
      TableCellText('${f.transactions}', color: AppColors.textSecondary),
      StatusBadge(label: f.mode, color: isOnline ? AppColors.primary : AppColors.warning, bgColor: isOnline ? AppColors.primarySoft : AppColors.warningSoft),
    ];
  }).toList();

  _showListDialog(
    context: context,
    title: 'Fee Collection Report',
    subtitle: '${fees.length} entries on record',
    icon: Icons.currency_rupee_rounded,
    color: const Color(0xFF0891B2),
    child: DataTableCard(
      minWidth: 420,
      columns: const [
        TableColumnDef(label: 'DATE', flex: 3),
        TableColumnDef(label: 'AMOUNT', flex: 2),
        TableColumnDef(label: 'TXNS', flex: 2),
        TableColumnDef(label: 'MODE', flex: 2),
      ],
      rows: rows,
    ),
  );
}

void showAllAlertsDialog(BuildContext context, List<AlertData> alerts) {
  _showListDialog(
    context: context,
    title: "Today's Alerts",
    subtitle: '${alerts.length} alerts',
    icon: Icons.notifications_active_rounded,
    color: AppColors.danger,
    child: Column(
      children: alerts
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: a.bgColor, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: a.color.withOpacity(0.14))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Icon(a.icon, size: 17, color: a.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(a.subtitle, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Text(a.time, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                  ],
                ),
              ))
          .toList(),
    ),
  );
}

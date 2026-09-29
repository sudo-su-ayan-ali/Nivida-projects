import 'package:flutter/material.dart';
import '../state/app_scope.dart';
import '../theme/app_theme.dart';
import '../utils/responsive.dart';
import '../widgets/header_section.dart';
import '../widgets/toolbar_section.dart';
import '../widgets/kpi_section.dart';
import '../widgets/inventory_overview_section.dart';
import '../widgets/category_section.dart';
import '../widgets/alerts_section.dart';
import '../widgets/inventory_table_section.dart';
import '../widgets/low_stock_section.dart';
import '../widgets/stock_activity_section.dart';
import '../widgets/summary_section.dart';
import '../widgets/quick_actions_section.dart';

/// Single scrollable dashboard page — no sidebar, fully responsive.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.of(context);
    final isDesktop = Responsive.isDesktop(context);
    final hPad = Responsive.horizontalPadding(context);
    final maxWidth = Responsive.maxContentWidth(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const HeaderSection(),
                  const SizedBox(height: 16),
                  _AnimatedSection(
                    delay: 0,
                    child: Container(
                      decoration: cardDecoration(radius: 18),
                      padding: const EdgeInsets.all(16),
                      child: const ToolbarSection(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedSection(delay: 60, child: const KpiSection()),
                  const SizedBox(height: 16),

                  // Overview / Category / Alerts row
                  // NOTE: deliberately NOT wrapped in IntrinsicHeight — the
                  // sections below use LayoutBuilder internally for their
                  // responsive grids, and LayoutBuilder cannot compute
                  // intrinsic dimensions (Flutter throws at runtime if it
                  // tries). CrossAxisAlignment.start lets each card size to
                  // its own natural (different) height instead, which is
                  // safe and still looks clean since each card has its own
                  // shadow/border.
                 if (isDesktop)
  _AnimatedSection(
    delay: 120,
    child: const _EqualHeightRow(
      flexes: [3, 4, 3],
      children: [
        InventoryOverviewSection(),
        CategorySection(),
        AlertsSection(),
      ],
    ),
  )
                  else
                    _AnimatedSection(
                      delay: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          InventoryOverviewSection(),
                          SizedBox(height: 16),
                          CategorySection(),
                          SizedBox(height: 16),
                          AlertsSection(),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  _AnimatedSection(delay: 180, child: const InventoryTableSection()),
                  const SizedBox(height: 16),

                  // Low stock / stock in / stock out row (see note above —
                  // no IntrinsicHeight here either, same reasoning).
                  if (isDesktop)
                    _AnimatedSection(
                      delay: 240,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: LowStockSection()),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StockActivitySection(
                              title: 'Recent Stock In',
                              items: appState.stockInLog,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StockActivitySection(
                              title: 'Recent Stock Out',
                              items: appState.stockOutLog,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _AnimatedSection(
                      delay: 240,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const LowStockSection(),
                          const SizedBox(height: 16),
                          StockActivitySection(title: 'Recent Stock In', items: appState.stockInLog),
                          const SizedBox(height: 16),
                          StockActivitySection(title: 'Recent Stock Out', items: appState.stockOutLog),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  _AnimatedSection(delay: 300, child: const QuickActionsSection()),
                  const SizedBox(height: 16),
                  _AnimatedSection(delay: 340, child: const SummarySection()),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small fade + slide-up entrance animation wrapper for each section,
/// staggered via [delay] milliseconds for a polished feel on load.
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delay;
  const _AnimatedSection({required this.child, required this.delay});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.03),
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
  
}
class _EqualHeightRow extends StatefulWidget {
  final List<Widget> children;
  final List<int> flexes;
  final double spacing;
  const _EqualHeightRow({required this.children, required this.flexes, this.spacing = 16});

  @override
  State<_EqualHeightRow> createState() => _EqualHeightRowState();
}

class _EqualHeightRowState extends State<_EqualHeightRow> {
  late final List<GlobalKey> _keys =
      List.generate(widget.children.length, (_) => GlobalKey());
  double? _maxHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    double tallest = 0;
    for (final key in _keys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize && box.size.height > tallest) {
        tallest = box.size.height;
      }
    }
    if (tallest > 0 && tallest != _maxHeight) {
      setState(() => _maxHeight = tallest);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

    final row = <Widget>[];
    for (var i = 0; i < widget.children.length; i++) {
      if (i != 0) row.add(SizedBox(width: widget.spacing));
      row.add(
        Expanded(
          flex: widget.flexes[i],
          child: ConstrainedBox(
            key: _keys[i],
            constraints: BoxConstraints(minHeight: _maxHeight ?? 0),
            child: widget.children[i],
          ),
        ),
      );
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: row);
  }
}
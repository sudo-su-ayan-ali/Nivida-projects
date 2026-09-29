import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

class SalaryStructureScreen extends StatefulWidget {
  const SalaryStructureScreen({super.key});

  @override
  State<SalaryStructureScreen> createState() => _SalaryStructureScreenState();
}

class _SalaryStructureScreenState extends State<SalaryStructureScreen> {
  Employee? _selected;

  final _basic = TextEditingController();
  final _hra = TextEditingController();
  final _conveyance = TextEditingController();
  final _medical = TextEditingController();
  final _special = TextEditingController();
  final _pf = TextEditingController();
  final _esi = TextEditingController();
  final _ptax = TextEditingController();
  final _other = TextEditingController();

  void _loadFor(Employee e, AppState state) {
    final s = state.structureFor(e.id);
    _basic.text = s.basic.toStringAsFixed(0);
    _hra.text = s.hra.toStringAsFixed(0);
    _conveyance.text = s.conveyance.toStringAsFixed(0);
    _medical.text = s.medical.toStringAsFixed(0);
    _special.text = s.specialAllowance.toStringAsFixed(0);
    _pf.text = s.pf.toStringAsFixed(0);
    _esi.text = s.esi.toStringAsFixed(0);
    _ptax.text = s.professionalTax.toStringAsFixed(0);
    _other.text = s.otherDeductions.toStringAsFixed(0);
  }

  double get _basicV => double.tryParse(_basic.text) ?? 0;
  double get _hraV => double.tryParse(_hra.text) ?? 0;
  double get _convV => double.tryParse(_conveyance.text) ?? 0;
  double get _medV => double.tryParse(_medical.text) ?? 0;
  double get _specialV => double.tryParse(_special.text) ?? 0;
  double get _pfV => double.tryParse(_pf.text) ?? 0;
  double get _esiV => double.tryParse(_esi.text) ?? 0;
  double get _ptaxV => double.tryParse(_ptax.text) ?? 0;
  double get _otherV => double.tryParse(_other.text) ?? 0;

  double get _gross => _basicV + _hraV + _convV + _medV + _specialV;
  double get _deductions => _pfV + _esiV + _ptaxV + _otherV;
  double get _net => _gross - _deductions;

  void _save() {
    if (_selected == null) return;
    context.read<AppState>().updateSalaryStructure(SalaryStructure(
          employeeId: _selected!.id,
          basic: _basicV,
          hra: _hraV,
          conveyance: _convV,
          medical: _medV,
          specialAllowance: _specialV,
          pf: _pfV,
          esi: _esiV,
          professionalTax: _ptaxV,
          otherDeductions: _otherV,
        ));
    showAppToast(context, 'Salary structure saved for ${_selected!.name}');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_selected == null && state.employees.isNotEmpty) {
      _selected = state.employees.first;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadFor(_selected!, state));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(
          title: 'Salary Structure',
          subtitle: 'Define salary components per employee',
        ),
        const SizedBox(height: 18),
        LayoutBuilder(builder: (ctx, c) {
          final isWide = c.maxWidth > 900;
          final form = AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<Employee>(
                  value: _selected,
                  decoration: const InputDecoration(labelText: 'Select Employee'),
                  items: state.employees
                      .map((e) => DropdownMenuItem(value: e, child: Text('${e.name} (${e.empCode})')))
                      .toList(),
                  onChanged: (v) {
                    setState(() => _selected = v);
                    if (v != null) _loadFor(v, state);
                  },
                ),
                const SizedBox(height: 18),
                const Text('Earnings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 10),
                _numField('Basic Salary', _basic),
                _numField('HRA', _hra),
                _numField('Conveyance', _conveyance),
                _numField('Medical Allowance', _medical),
                _numField('Special Allowance', _special),
                const SizedBox(height: 8),
                const Text('Deductions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 10),
                _numField('Provident Fund (PF)', _pf),
                _numField('ESI', _esi),
                _numField('Professional Tax', _ptax),
                _numField('Other Deductions', _other),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: PrimaryButton(label: 'Save Structure', icon: Icons.save_outlined, onPressed: _save),
                ),
              ],
            ),
          );

          final summary = AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Calculation Summary', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 16),
                _summaryLine('Gross Salary', _gross, bold: false, color: AppColors.textPrimary),
                _summaryLine('Total Deductions', _deductions, color: AppColors.danger),
                const Divider(height: 28),
                _summaryLine('Net Salary', _net, bold: true, color: AppColors.success, big: true),
              ],
            ),
          );

          if (isWide) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: form),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: summary),
                ],
              ),
            );
          }
          return Column(children: [form, const SizedBox(height: 20), summary]);
        }),
      ],
    );
  }

  Widget _numField(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, prefixText: '₹ '),
      ),
    );
  }

  Widget _summaryLine(String label, double value, {bool bold = false, Color? color, bool big = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontSize: big ? 15 : 13.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
          Text('₹${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: big ? 18 : 14,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: color)),
        ],
      ),
    );
  }
}

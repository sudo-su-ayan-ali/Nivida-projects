import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'payroll_processing_screen.dart' show months;

class PayslipsScreen extends StatefulWidget {
  const PayslipsScreen({super.key});

  @override
  State<PayslipsScreen> createState() => _PayslipsScreenState();
}

class _PayslipsScreenState extends State<PayslipsScreen> {
  Employee? _employee;
  String _month = 'May 2024';
  bool _generated = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (_employee == null && state.employees.isNotEmpty) {
      _employee = state.employees.first;
    }
    final structure = _employee == null ? null : state.structureFor(_employee!.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageHeader(title: 'Payslips', subtitle: 'Generate and view employee payslips'),
        const SizedBox(height: 18),
        AppCard(
          child: Wrap(
            spacing: 14,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<Employee>(
                  value: _employee,
                  decoration: const InputDecoration(labelText: 'Employee'),
                  items: state.employees.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                  onChanged: (v) => setState(() { _employee = v; _generated = false; }),
                ),
              ),
              FilterDropdown<String>(
                hint: 'Month',
                value: _month,
                items: months,
                labelBuilder: (v) => v,
                onChanged: (v) => setState(() { _month = v ?? _month; _generated = false; }),
              ),
              PrimaryButton(
                  label: 'Generate Payslip',
                  icon: Icons.receipt_long_outlined,
                  onPressed: () => setState(() => _generated = true)),
              if (_generated) ...[
                SecondaryButton(
                    label: 'Print',
                    icon: Icons.print_outlined,
                    onPressed: () => showAppToast(context, 'Sending to printer (demo)')),
                SecondaryButton(
                    label: 'Download',
                    icon: Icons.download_outlined,
                    onPressed: () => showAppToast(context, 'Payslip downloaded (demo)')),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_generated && _employee != null && structure != null)
          _PayslipDocument(employee: _employee!, month: _month, structure: structure)
        else
          const AppCard(child: EmptyState(message: 'Select an employee and month, then generate a payslip.')),
      ],
    );
  }
}

class _PayslipDocument extends StatelessWidget {
  final Employee employee;
  final String month;
  final SalaryStructure structure;
  const _PayslipDocument({required this.employee, required this.month, required this.structure});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.school, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bright Future School', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text('Civil Lines, Jodhpur, Rajasthan, India',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration:
                        BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
                    child: Text('Payslip · $month',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 14),
              Wrap(
                spacing: 40,
                runSpacing: 12,
                children: [
                  _kv('Employee Name', employee.name),
                  _kv('Employee ID', employee.empCode),
                  _kv('Department', employee.department),
                  _kv('Designation', employee.designation),
                  _kv('Bank Account', employee.bankAccount),
                  _kv('PAN', employee.pan),
                  _kv('Payment Date', '05 ${month.split(' ').first} ${month.split(' ').last}'),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _breakdownTable('Earnings', {
                    'Basic Salary': structure.basic,
                    'HRA': structure.hra,
                    'Conveyance': structure.conveyance,
                    'Medical Allowance': structure.medical,
                    'Special Allowance': structure.specialAllowance,
                  }, AppColors.success)),
                  const SizedBox(width: 20),
                  Expanded(child: _breakdownTable('Deductions', {
                    'Provident Fund': structure.pf,
                    'ESI': structure.esi,
                    'Professional Tax': structure.professionalTax,
                    'Other Deductions': structure.otherDeductions,
                  }, AppColors.danger)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.pageBg, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Net Salary Payable', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text('₹${structure.net.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.success)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('This is a system-generated payslip and does not require a signature.',
                  style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _breakdownTable(String title, Map<String, double> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
        const SizedBox(height: 8),
        for (final e in items.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(e.key, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                Text('₹${e.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _kv(String k, String v) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
          Text(v, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

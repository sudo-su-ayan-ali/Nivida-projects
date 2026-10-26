import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';
import '../theme/app_colors.dart';

class BackupSettingsView extends StatefulWidget {
  final SettingsController controller;
  const BackupSettingsView({super.key, required this.controller});

  @override
  State<BackupSettingsView> createState() => _BackupSettingsViewState();
}

class _BackupSettingsViewState extends State<BackupSettingsView> {
  String _frequency = 'Daily (Nightly at 02:00 UTC)';
  String _retention = '90 Days';
  String _destination = 'Cloud & Local Archive';

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final dark = controller.isDarkMode;

    final cardBg = dark ? AppColors.cardWhiteDark : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = dark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.iconTealBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.storage_rounded, color: AppColors.iconTealFg, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ERP Backup & Data Recovery',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Complete disaster recovery engine for Tenant Alpha. Backs up all 28 tables including students, finance, and HR.',
                      style: TextStyle(fontSize: 13, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Export full backup button
              FilledButton.icon(
                onPressed: controller.isExportingBackup ? null : () => controller.runFullBackup(),
                icon: controller.isExportingBackup
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.download_rounded, size: 16),
                label: Text(
                  controller.isExportingBackup ? 'Exporting Tables...' : 'Export Full ERP Database (.xlsx)',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        if (controller.isExportingBackup && controller.backupStatusMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE3ECFD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                ),
                const SizedBox(width: 12),
                Text(
                  controller.backupStatusMessage!,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 18),

        // 2-column Backup Configuration
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // Config Card 1
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Automated Backup Configuration',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Automatic Nightly Backup',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Create automated database snapshots every night at 02:00 AM UTC',
                                    style: TextStyle(fontSize: 12, color: textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: controller.toggles['Auto Backup'] ?? true,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (_) => controller.toggleSetting('Auto Backup'),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _buildDropdownRow(
                          label: 'Backup Frequency',
                          value: _frequency,
                          options: [
                            'Daily (Nightly at 02:00 UTC)',
                            'Twice Daily (Every 12 Hours)',
                            'Weekly (Sunday 00:00 UTC)'
                          ],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _frequency = v);
                            controller.emitToast('Backup frequency updated', ToastType.info);
                          },
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow(
                          label: 'Snapshot Retention Policy',
                          value: _retention,
                          options: ['30 Days', '60 Days', '90 Days', '180 Days', '1 Year'],
                          dark: dark,
                          onChanged: (v) {
                            setState(() => _retention = v);
                            controller.emitToast('Retention period set to $v', ToastType.info);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Config Card 2: Storage & Health
                SizedBox(
                  width: isWide ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Storage Destination & Health',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildDropdownRow(
                          label: 'Primary Storage Target',
                          value: _destination,
                          options: [
                            'Cloud & Local Archive',
                            'Dedicated On-Premises Server',
                            'Supabase Cloud Bucket'
                          ],
                          dark: dark,
                          onChanged: (v) => setState(() => _destination = v),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1F7EA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Color(0xFF22B573), size: 20),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Backup Health: 100% Verified',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF22B573)),
                                    ),
                                    Text(
                                      'Last automatic snapshot verified on Oct 26, 2026. Zero corrupted tables.',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF1B6B46)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () {
                            controller.emitToast('Storage checksum verification passed: all snapshot hashes valid', ToastType.success);
                          },
                          icon: const Icon(Icons.verified_outlined, size: 16),
                          label: const Text('Verify Snapshot Checksums'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 18),

        // Recent Backup Snapshots Table
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Verified Snapshots',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 28,
                  columns: const [
                    DataColumn(label: Text('Snapshot ID', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Size', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Tables', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Trigger', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
                  ],
                  rows: [
                    _buildSnapshotRow(
                      id: 'BKP-ALPHA-20261026-01',
                      date: 'Today, 02:00 AM',
                      size: '4.8 MB',
                      tables: '28 Tables',
                      trigger: 'Scheduled Nightly',
                      status: 'Verified',
                      controller: controller,
                    ),
                    _buildSnapshotRow(
                      id: 'BKP-ALPHA-20261025-01',
                      date: 'Oct 25, 2026 02:00 AM',
                      size: '4.7 MB',
                      tables: '28 Tables',
                      trigger: 'Scheduled Nightly',
                      status: 'Verified',
                      controller: controller,
                    ),
                    _buildSnapshotRow(
                      id: 'BKP-ALPHA-20261024-02',
                      date: 'Oct 24, 2026 04:30 PM',
                      size: '4.6 MB',
                      tables: '28 Tables',
                      trigger: 'Principal Manual Export',
                      status: 'Verified',
                      controller: controller,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _buildSnapshotRow({
    required String id,
    required String date,
    required String size,
    required String tables,
    required String trigger,
    required String status,
    required SettingsController controller,
  }) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
        DataCell(Text(date, style: const TextStyle(fontSize: 13))),
        DataCell(Text(size, style: const TextStyle(fontSize: 13))),
        DataCell(Text(tables, style: const TextStyle(fontSize: 13))),
        DataCell(Text(trigger, style: const TextStyle(fontSize: 13))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F7EA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF22B573)),
            ),
          ),
        ),
        DataCell(
          TextButton.icon(
            onPressed: () => controller.runFullBackup(),
            icon: const Icon(Icons.download_rounded, size: 14),
            label: const Text('Download', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownRow({
    required String label,
    required String value,
    required List<String> options,
    required bool dark,
    required ValueChanged<String> onChanged,
  }) {
    final textPrimary = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;
    final fieldBg = dark ? const Color(0xFF11172A) : Colors.white;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.contains(value) ? value : options.first,
              style: TextStyle(fontSize: 12.5, color: textPrimary),
              dropdownColor: dark ? AppColors.cardWhiteDark : Colors.white,
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';

/// Feature 2 — Document Vault.
/// A secure, per-student place to upload/store certificates, Transfer
/// Certificates, Aadhar/ID proof and admission forms — a gap the ERP had
/// no answer for at all before this.
class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  String _className = 'All Classes';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final students = app.studentsFiltered(className: _className, query: _query);
    final classes = ['All Classes', ...app.classNames];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 28,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document Vault', style: AppTextStyles.greetingTitle),
              const SizedBox(height: 4),
              Text(
                'Secure, per-student storage for certificates, TC, ID proof & admission forms',
                style: AppTextStyles.greetingSubtitle,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _summaryTile(
                      icon: Icons.verified_outlined,
                      color: AppColors.green,
                      bg: AppColors.greenBg,
                      value: '${app.verifiedDocumentsCount}',
                      label: 'Verified',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryTile(
                      icon: Icons.hourglass_empty_rounded,
                      color: AppColors.orange,
                      bg: AppColors.orangeBg,
                      value: '${app.pendingDocumentsCount}',
                      label: 'Pending Verification',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _summaryTile(
                      icon: Icons.report_gmailerrorred_outlined,
                      color: AppColors.red,
                      bg: AppColors.redBg,
                      value: '${app.missingDocumentsCount}',
                      label: 'Missing',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    child: AppDropdown<String>(
                      label: 'Class',
                      value: classes.contains(_className)
                          ? _className
                          : 'All Classes',
                      items: classes,
                      itemLabel: (c) => c,
                      onChanged: (v) =>
                          setState(() => _className = v ?? 'All Classes'),
                    ),
                  ),
                  SizedBox(
                    width: 260,
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search student...',
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.scaffoldBg,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (students.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No students match this filter.',
                      style: AppTextStyles.itemSub,
                    ),
                  ),
                )
              else
                for (final s in students) _StudentDocRow(student: s),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required Color color,
    required Color bg,
    required String value,
    required String label,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconBadge(icon: icon, color: color, bgColor: bg, size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.statValue.copyWith(fontSize: 18),
                ),
                Text(
                  label,
                  style: AppTextStyles.itemSub,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDocRow extends StatelessWidget {
  final StudentItem student;
  const _StudentDocRow({required this.student});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final missing = app.missingDocumentTypesFor(student.id);
    final total = AppState.requiredDocumentTypes.length;
    final have = total - missing.length;
    final complete = missing.isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => _openVault(context, student),
        child: Row(
          children: [
            InitialsAvatar(seed: student.name, size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: AppTextStyles.itemTitle),
                  Text(student.className, style: AppTextStyles.itemSub),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : have / total,
                      minHeight: 6,
                      backgroundColor: AppColors.scaffoldBg,
                      valueColor: AlwaysStoppedAnimation(
                        complete ? AppColors.green : AppColors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            StatusPill(
              label: complete ? 'Complete' : '$have / $total docs',
              color: complete ? AppColors.green : AppColors.orange,
              bgColor: complete ? AppColors.greenBg : AppColors.orangeBg,
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _openVault(BuildContext context, StudentItem student) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => _VaultDialog(student: student),
    );
  }
}

class _VaultDialog extends StatelessWidget {
  final StudentItem student;
  const _VaultDialog({required this.student});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, app, _) {
        final docs = app.documentsFor(student.id);
        final canVerify = app.currentRole.canVerifyDocuments;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480, maxHeight: 560),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InitialsAvatar(seed: student.name, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: AppTextStyles.greetingTitle.copyWith(
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              '${student.className} • Document Vault',
                              style: AppTextStyles.greetingSubtitle,
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 26, color: AppColors.border),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final type in AppState.requiredDocumentTypes)
                            _DocTypeRow(
                              type: type,
                              doc: docs.where((d) => d.type == type).isEmpty
                                  ? null
                                  : docs.firstWhere((d) => d.type == type),
                              studentId: student.id,
                              canVerify: canVerify,
                            ),
                          if (docs
                              .where(
                                (d) => !AppState.requiredDocumentTypes.contains(
                                  d.type,
                                ),
                              )
                              .isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'OTHER DOCUMENTS',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(height: 8),
                            for (final d in docs.where(
                              (d) => !AppState.requiredDocumentTypes.contains(
                                d.type,
                              ),
                            ))
                              _DocTypeRow(
                                type: d.type,
                                doc: d,
                                studentId: student.id,
                                canVerify: canVerify,
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: AppPrimaryButton(
                      label: 'Upload Document',
                      icon: Icons.upload_file_outlined,
                      onPressed: () => _showUploadDialog(context, student.id),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context, String studentId) {
    String type = AppState.requiredDocumentTypes.first;
    final formKey = GlobalKey<FormState>();
    PlatformFile? pickedFile;
    bool uploading = false;

    showAppFormDialog(
      context: context,
      title: 'Upload Document',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDropdown<String>(
                  label: 'Document Type',
                  value: type,
                  items: const [...AppState.requiredDocumentTypes, 'Other'],
                  itemLabel: (t) => t,
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    final result = await FilePicker.platform.pickFiles(
                      withData: true,
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() => pickedFile = result.files.first);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pickedFile?.name ??
                                'Choose a file from your computer',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AppPrimaryButton(
                    label: uploading ? 'Uploading...' : 'Upload',
                    icon: Icons.cloud_upload_outlined,
                    onPressed: uploading
                        ? null
                        : () async {
                            if (pickedFile == null) {
                              showAppSnack(
                                context,
                                'Please choose a file first',
                                icon: Icons.error_outline,
                              );
                              return;
                            }
                            setState(() => uploading = true);

                            try {
                              final bytes = pickedFile!.bytes;
                              final path =
                                  '$studentId/${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';

                              await Supabase.instance.client.storage
                                  .from('teacher-documents')
                                  .uploadBinary(path, bytes!);

                              final fileUrl = Supabase.instance.client.storage
                                  .from('teacher-documents')
                                  .getPublicUrl(path);

                              await context.read<AppState>().addDocument(
                                studentId: studentId,
                                type: type,
                                fileName: pickedFile!.name,
                                fileUrl: fileUrl,
                              );

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                showAppSnack(
                                  context,
                                  'Document uploaded — pending verification',
                                  icon: Icons.cloud_upload_outlined,
                                );
                              }
                            } catch (e) {
                              setState(() => uploading = false);
                              if (context.mounted) {
                                showAppSnack(
                                  context,
                                  'Upload failed: $e',
                                  icon: Icons.error_outline,
                                );
                              }
                            }
                          },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DocTypeRow extends StatelessWidget {
  final String type;
  final DocumentItem? doc;
  final String studentId;
  final bool canVerify;
  const _DocTypeRow({
    required this.type,
    required this.doc,
    required this.studentId,
    required this.canVerify,
  });

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final missing = doc == null;
    final verified = doc?.status == 'Verified';
    final color = missing
        ? AppColors.red
        : (verified ? AppColors.green : AppColors.orange);
    final bg = missing
        ? AppColors.redBg
        : (verified ? AppColors.greenBg : AppColors.orangeBg);
    final icon = missing
        ? Icons.error_outline
        : (verified ? Icons.verified_outlined : Icons.hourglass_empty_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(icon: icon, color: color, bgColor: bg, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: AppTextStyles.itemTitle.copyWith(fontSize: 13),
                ),
                Text(
                  missing
                      ? 'Not uploaded yet'
                      : '${doc!.fileName} • ${doc!.uploadedOn}',
                  style: AppTextStyles.itemSub,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (!missing) ...[
            StatusPill(label: doc!.status, color: color, bgColor: bg),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onSelected: (action) {
                if (action == 'view') {
                  showAppSnack(
                    context,
                    'Opening ${doc!.fileName} (preview)',
                    icon: Icons.visibility_outlined,
                  );
                } else if (action == 'verify') {
                  app.verifyDocument(doc!.id);
                  showAppSnack(context, '${doc!.type} marked as verified');
                } else if (action == 'delete') {
                  app.deleteDocument(doc!.id);
                  showAppSnack(
                    context,
                    'Document removed',
                    icon: Icons.delete_outline,
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View')),
                if (canVerify && !verified)
                  const PopupMenuItem(
                    value: 'verify',
                    child: Text('Mark Verified'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ] else
            StatusPill(label: 'Missing', color: color, bgColor: bg),
        ],
      ),
    );
  }
}

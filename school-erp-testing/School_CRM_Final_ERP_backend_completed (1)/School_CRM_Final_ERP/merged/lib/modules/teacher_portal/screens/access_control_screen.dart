import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/common/app_card.dart';
import '../widgets/common/form_widgets.dart';

const List<String> _kRoleOptions = ['Teacher', 'HOD', 'Principal', 'Admin'];
const List<String> _kRaisedByOptions = ['Principal', 'Vice Principal'];

/// Role-Based Access Control — sidebar section for Principal / Admin only.
///
/// This is a REQUEST & REVIEW workflow, not an access engine: when a
/// Principal or Vice Principal wants a staff member's role/access changed,
/// they raise it here, and it lands in this queue for leadership to
/// review and decide on. Approving or rejecting a request only records
/// that decision — it does not, by itself, change anyone's real access in
/// the app, exactly as things work today.
class AccessControlScreen extends StatefulWidget {
  const AccessControlScreen({super.key});

  @override
  State<AccessControlScreen> createState() => _AccessControlScreenState();
}

class _AccessControlScreenState extends State<AccessControlScreen> {
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pending = app.pendingAccessRequests;
    final decided = app.accessRequests.where((r) => r.status != 'Pending').toList();

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 720;
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 28, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role-Based Access Control', style: AppTextStyles.greetingTitle),
                    const SizedBox(height: 4),
                    Text('Requests from Principal / Vice Principal to change a staff member\'s role', style: AppTextStyles.greetingSubtitle),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showNewRequestDialog(context, app),
                  icon: const Icon(Icons.add_moderator_outlined, size: 17),
                  label: const Text('New Access Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _summaryTile(icon: Icons.hourglass_empty_rounded, color: AppColors.orange, bg: AppColors.orangeBg, value: '${pending.length}', label: 'Pending Requests')),
                const SizedBox(width: 12),
                Expanded(child: _summaryTile(icon: Icons.verified_user_outlined, color: AppColors.green, bg: AppColors.greenBg, value: '${app.accessRequests.where((r) => r.status == 'Approved').length}', label: 'Approved')),
                const SizedBox(width: 12),
                Expanded(child: _summaryTile(icon: Icons.block_outlined, color: AppColors.red, bg: AppColors.redBg, value: '${app.accessRequests.where((r) => r.status == 'Rejected').length}', label: 'Rejected')),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'This section only tracks and reviews access-change requests raised by a Principal or Vice Principal. '
                      'Approving a request here does not directly grant any access — nothing else in the app changes.',
                      style: AppTextStyles.itemSub,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text('Pending Requests (${pending.length})', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('No pending access requests. All caught up!', style: AppTextStyles.itemSub),
              )
            else
              for (final r in pending) _RequestRow(request: r),
            const SizedBox(height: 22),
            Text('Recently Decided', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 12),
            if (decided.isEmpty)
              Text('Nothing decided yet.', style: AppTextStyles.itemSub)
            else
              for (final r in decided) _DecidedRow(request: r),
            const SizedBox(height: 8),
          ],
        ),
      );
    });
  }

  Widget _summaryTile({required IconData icon, required Color color, required Color bg, required String value, required String label}) {
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
                Text(value, style: AppTextStyles.statValue.copyWith(fontSize: 18)),
                Text(label, style: AppTextStyles.itemSub, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewRequestDialog(BuildContext context, AppState app) {
    final staffCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    String currentRole = _kRoleOptions.first;
    String requestedRole = _kRoleOptions[1];
    String raisedByRole = _kRaisedByOptions.first;

    showAppFormDialog(
      context: context,
      title: 'New Access Request',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Requesting on behalf of',
                style: AppTextStyles.itemSub.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              AppDropdown<String>(
                label: 'Raised By',
                value: raisedByRole,
                items: _kRaisedByOptions,
                itemLabel: (v) => v,
                onChanged: (v) => setState(() => raisedByRole = v ?? raisedByRole),
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Staff Member Name', controller: staffCtrl, hint: 'e.g. Rohan Mehta'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Current Role',
                      value: currentRole,
                      items: _kRoleOptions,
                      itemLabel: (v) => v,
                      onChanged: (v) => setState(() => currentRole = v ?? currentRole),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Requested Role',
                      value: requestedRole,
                      items: _kRoleOptions,
                      itemLabel: (v) => v,
                      onChanged: (v) => setState(() => requestedRole = v ?? requestedRole),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Reason', controller: reasonCtrl, hint: 'Why does this access change need to happen?', maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Submit Request',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (staffCtrl.text.trim().isEmpty || reasonCtrl.text.trim().isEmpty) {
                      showAppSnack(context, 'Add a staff name and a reason first', icon: Icons.error_outline);
                      return;
                    }
                    app.submitAccessRequest(
                      staffName: staffCtrl.text.trim(),
                      currentRole: currentRole,
                      requestedRole: requestedRole,
                      reason: reasonCtrl.text.trim(),
                      raisedByRole: raisedByRole,
                    );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Access request submitted for review', icon: Icons.mark_email_read_outlined);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  final AccessRequest request;
  const _RequestRow({required this.request});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(seed: request.staffName.isEmpty ? 'S' : request.staffName, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.staffName, style: AppTextStyles.itemTitle),
                      Text('${request.currentRole} → ${request.requestedRole}  •  Raised by ${request.raisedByRole} (${request.raisedBy})', style: AppTextStyles.itemSub),
                    ],
                  ),
                ),
                StatusPill(label: request.appliedOn, color: AppColors.textSecondary, bgColor: AppColors.scaffoldBg),
              ],
            ),
            const SizedBox(height: 8),
            Text(request.reason, style: AppTextStyles.itemSub),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    app.approveAccessRequest(request.id, note: 'Approved');
                    showAppSnack(context, 'Marked ${request.staffName}\'s request as approved');
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 15, color: AppColors.green),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.green,
                    side: const BorderSide(color: AppColors.green),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    app.rejectAccessRequest(request.id, note: 'Not approved');
                    showAppSnack(context, 'Rejected ${request.staffName}\'s request', icon: Icons.cancel_outlined);
                  },
                  icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.red),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DecidedRow extends StatelessWidget {
  final AccessRequest request;
  const _DecidedRow({required this.request});

  Color get _color => request.status == 'Approved' ? AppColors.green : AppColors.red;
  Color get _bg => request.status == 'Approved' ? AppColors.greenBg : AppColors.redBg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            InitialsAvatar(seed: request.staffName.isEmpty ? 'S' : request.staffName, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.staffName, style: AppTextStyles.itemTitle),
                  Text('${request.currentRole} → ${request.requestedRole}  •  ${request.reviewerNote.isEmpty ? 'No note' : request.reviewerNote}', style: AppTextStyles.itemSub),
                ],
              ),
            ),
            StatusPill(label: request.status, color: _color, bgColor: _bg),
          ],
        ),
      ),
    );
  }
}

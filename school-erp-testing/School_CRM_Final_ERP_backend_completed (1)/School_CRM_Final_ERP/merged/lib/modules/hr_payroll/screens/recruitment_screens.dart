import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../widgets/app_table.dart';
import '../widgets/common.dart';

const _uuid = Uuid();

// ---------------- Jobs ----------------

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  Future<void> _openForm({JobOpening? existing}) async {
    final state = context.read<AppState>();
    final result = await showDialog<JobOpening>(
      context: context,
      builder: (_) => _JobDialog(existing: existing, departments: state.departments.map((d) => d.name).toList()),
    );
    if (result != null) {
      if (existing != null) {
        await state.updateJob(result);
        if (context.mounted) showAppToast(context, 'Job updated');
      } else {
        await state.addJob(result);
        if (context.mounted) showAppToast(context, 'Job opening created');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Jobs',
          subtitle: 'Manage job openings',
          actions: [PrimaryButton(label: 'Post Job', onPressed: () => _openForm())],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Position', 'Department', 'Location', 'Type', 'Vacancies', 'Applications', 'Status', 'Actions'],
            emptyMessage: 'No job openings',
            rows: [
              for (final j in state.jobs)
                DataRow(cells: [
                  DataCell(Text(j.title, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(j.department)),
                  DataCell(Text(j.location)),
                  DataCell(Text(j.employmentType)),
                  DataCell(Text('${j.vacancies}')),
                  DataCell(Text('${j.applications}')),
                  DataCell(StatusBadge.forStatus(j.status)),
                  DataCell(RowActions(
                    onEdit: () => _openForm(existing: j),
                    onDelete: () async {
                      final confirmed = await showConfirmDialog(context,
                          title: 'Delete Job', message: 'Close "${j.title}"?', confirmLabel: 'Delete', danger: true);
                      if (confirmed) {
                        await state.deleteJob(j.id);
                        if (context.mounted) showAppToast(context, 'Job removed');
                      }
                    },
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _JobDialog extends StatefulWidget {
  final JobOpening? existing;
  final List<String> departments;
  const _JobDialog({this.existing, required this.departments});

  @override
  State<_JobDialog> createState() => _JobDialogState();
}

class _JobDialogState extends State<_JobDialog> {
  late TextEditingController _title;
  late TextEditingController _location;
  late TextEditingController _vacancies;
  String? _department;
  String _type = 'Full Time';
  String _status = 'Open';

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.existing?.title ?? '');
    _location = TextEditingController(text: widget.existing?.location ?? 'Jodhpur');
    _vacancies = TextEditingController(text: '${widget.existing?.vacancies ?? 1}');
    _department = widget.existing?.department ?? (widget.departments.isNotEmpty ? widget.departments.first : null);
    _type = widget.existing?.employmentType ?? 'Full Time';
    _status = widget.existing?.status ?? 'Open';
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(isEdit ? 'Edit Job' : 'Post Job'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _title, decoration: const InputDecoration(labelText: 'Job Title')),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _department,
                decoration: const InputDecoration(labelText: 'Department'),
                items: widget.departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _department = v),
              ),
              const SizedBox(height: 14),
              TextField(controller: _location, decoration: const InputDecoration(labelText: 'Location')),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _type,
                    decoration: const InputDecoration(labelText: 'Employment Type'),
                    items: const ['Full Time', 'Part Time', 'Contract']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _vacancies,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Vacancies'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const ['Open', 'Closed', 'On Hold'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_title.text.trim().isEmpty || _department == null) return;
            Navigator.pop(
              context,
              JobOpening(
                id: widget.existing?.id ?? _uuid.v4(),
                title: _title.text.trim(),
                department: _department!,
                location: _location.text.trim(),
                employmentType: _type,
                vacancies: int.tryParse(_vacancies.text.trim()) ?? 1,
                applications: widget.existing?.applications ?? 0,
                status: _status,
              ),
            );
          },
          child: Text(isEdit ? 'Save' : 'Post'),
        ),
      ],
    );
  }
}

// ---------------- Candidates ----------------

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key});

  Future<void> _openAddCandidate(BuildContext context) async {
    final state = context.read<AppState>();
    final result = await showDialog<Candidate>(
      context: context,
      builder: (_) => _CandidateDialog(
        positions: state.jobs.map((j) => j.title).toSet().toList(),
      ),
    );
    if (result != null) {
      await state.addCandidate(result);
      if (context.mounted) showAppToast(context, 'Candidate added successfully');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Candidates',
          subtitle: 'Track and manage candidate applications',
          actions: [
            PrimaryButton(
              label: 'Add Candidate',
              icon: Icons.person_add_outlined,
              onPressed: () => _openAddCandidate(context),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Candidate', 'Position', 'Experience', 'Skills', 'Interview Status', 'Application Status', 'Actions'],
            emptyMessage: 'No candidates yet',
            rows: [
              for (final c in state.candidates)
                DataRow(cells: [
                  DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(c.position)),
                  DataCell(Text(c.experience)),
                  DataCell(SizedBox(width: 160, child: Text(c.skills.join(', '), overflow: TextOverflow.ellipsis))),
                  DataCell(StatusBadge.forStatus(c.interviewStatus)),
                  DataCell(StatusBadge.forStatus(c.applicationStatus)),
                  DataCell(PopupMenuButton<String>(
                    tooltip: 'Update status',
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (v) async {
                      await state.updateCandidateStatus(c.id, application: v);
                      if (context.mounted) showAppToast(context, 'Application marked as $v');
                    },
                    itemBuilder: (ctx) => const ['Applied', 'In Review', 'Shortlisted', 'Rejected', 'Hired']
                        .map((s) => PopupMenuItem(value: s, child: Text(s)))
                        .toList(),
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _CandidateDialog extends StatefulWidget {
  final List<String> positions;
  const _CandidateDialog({required this.positions});

  @override
  State<_CandidateDialog> createState() => _CandidateDialogState();
}

class _CandidateDialogState extends State<_CandidateDialog> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _experience = TextEditingController(text: '3 years');
  final _skills = TextEditingController(text: 'Communication, Teaching');
  String? _position;

  @override
  void initState() {
    super.initState();
    if (widget.positions.isNotEmpty) {
      _position = widget.positions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Add Candidate'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Full Name *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email Address *'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 14),
              if (widget.positions.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _position,
                  decoration: const InputDecoration(labelText: 'Position Applied *'),
                  items: widget.positions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _position = v),
                )
              else
                TextField(
                  decoration: const InputDecoration(labelText: 'Position Applied *'),
                  onChanged: (v) => _position = v,
                ),
              const SizedBox(height: 14),
              TextField(
                controller: _experience,
                decoration: const InputDecoration(labelText: 'Experience (e.g. 4 years)'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _skills,
                decoration: const InputDecoration(labelText: 'Skills (comma-separated)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_name.text.trim().isEmpty || (_position == null || _position!.trim().isEmpty)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please provide candidate name and position')),
              );
              return;
            }
            final rawSkills = _skills.text
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            Navigator.pop(
              context,
              Candidate(
                id: _uuid.v4(),
                name: _name.text.trim(),
                position: _position!.trim(),
                experience: _experience.text.trim(),
                skills: rawSkills.isEmpty ? ['General'] : rawSkills,
                interviewStatus: 'Scheduled',
                applicationStatus: 'In Review',
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ---------------- Interviews ----------------

class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  Future<void> _openForm() async {
    final state = context.read<AppState>();
    final result = await showDialog<InterviewSchedule>(
      context: context,
      builder: (_) => _InterviewDialog(candidates: state.candidates),
    );
    if (result != null) {
      await state.addInterview(result);
      if (context.mounted) showAppToast(context, 'Interview scheduled');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final df = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Interviews',
          subtitle: 'Schedule and conduct candidate interviews',
          actions: [PrimaryButton(label: 'Schedule Interview', onPressed: _openForm)],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Candidate', 'Position', 'Interviewer', 'Date', 'Time', 'Mode', 'Status'],
            emptyMessage: 'No interviews scheduled',
            rows: [
              for (final i in state.interviews)
                DataRow(cells: [
                  DataCell(Text(i.candidateName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(i.position)),
                  DataCell(Text(i.interviewer)),
                  DataCell(Text(df.format(i.date))),
                  DataCell(Text(i.time)),
                  DataCell(Text(i.mode)),
                  DataCell(StatusBadge.forStatus(i.status)),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _InterviewDialog extends StatefulWidget {
  final List<Candidate> candidates;
  const _InterviewDialog({required this.candidates});

  @override
  State<_InterviewDialog> createState() => _InterviewDialogState();
}

class _InterviewDialogState extends State<_InterviewDialog> {
  Candidate? _candidate;
  final _interviewer = TextEditingController();
  final _time = TextEditingController(text: '11:00 AM');
  DateTime _date = DateTime.now().add(const Duration(days: 2));
  String _mode = 'In-person';

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Schedule Interview'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Candidate>(
                value: _candidate,
                decoration: const InputDecoration(labelText: 'Candidate'),
                items: widget.candidates.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                onChanged: (v) => setState(() => _candidate = v),
              ),
              const SizedBox(height: 14),
              TextField(controller: _interviewer, decoration: const InputDecoration(labelText: 'Interviewer')),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                          context: context, initialDate: _date, firstDate: DateTime.now(), lastDate: DateTime(2100));
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date'),
                      child: Text(df.format(_date)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: _time, decoration: const InputDecoration(labelText: 'Time')),
                ),
              ]),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _mode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: const ['In-person', 'Online', 'Telephonic'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _mode = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_candidate == null || _interviewer.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              InterviewSchedule(
                id: _uuid.v4(),
                candidateName: _candidate!.name,
                position: _candidate!.position,
                interviewer: _interviewer.text.trim(),
                date: _date,
                time: _time.text.trim(),
                mode: _mode,
              ),
            );
          },
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

// ---------------- Offers ----------------

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  Future<void> _openForm() async {
    final state = context.read<AppState>();
    final result = await showDialog<JobOffer>(
      context: context,
      builder: (_) => _OfferDialog(candidates: state.candidates),
    );
    if (result != null) {
      await state.addOffer(result);
      if (context.mounted) showAppToast(context, 'Offer created');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final df = DateFormat('dd MMM yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Offers',
          subtitle: 'Manage offers and onboarding',
          actions: [PrimaryButton(label: 'Create Offer', onPressed: _openForm)],
        ),
        const SizedBox(height: 18),
        AppCard(
          child: AppTable(
            columns: const ['Candidate', 'Position', 'Salary', 'Joining Date', 'Status', 'Actions'],
            emptyMessage: 'No offers created',
            rows: [
              for (final o in state.offers)
                DataRow(cells: [
                  DataCell(Text(o.candidateName, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(o.position)),
                  DataCell(Text('₹${o.salary.toStringAsFixed(0)}')),
                  DataCell(Text(df.format(o.joiningDate))),
                  DataCell(StatusBadge.forStatus(o.status)),
                  DataCell(PopupMenuButton<String>(
                    tooltip: 'Update status',
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (v) async {
                      await state.updateOfferStatus(o.id, v);
                      if (context.mounted) showAppToast(context, 'Offer marked as $v');
                    },
                    itemBuilder: (ctx) => const ['Pending', 'Sent', 'Accepted', 'Declined']
                        .map((s) => PopupMenuItem(value: s, child: Text(s)))
                        .toList(),
                  )),
                ]),
            ],
          ),
        ),
      ],
    );
  }
}

class _OfferDialog extends StatefulWidget {
  final List<Candidate> candidates;
  const _OfferDialog({required this.candidates});

  @override
  State<_OfferDialog> createState() => _OfferDialogState();
}

class _OfferDialogState extends State<_OfferDialog> {
  Candidate? _candidate;
  final _salary = TextEditingController();
  DateTime _joining = DateTime.now().add(const Duration(days: 14));

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Create Offer'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Candidate>(
              value: _candidate,
              decoration: const InputDecoration(labelText: 'Candidate'),
              items: widget.candidates.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _candidate = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _salary,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Offered Salary (₹/month)'),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                    context: context, initialDate: _joining, firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (picked != null) setState(() => _joining = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Joining Date'),
                child: Text(df.format(_joining)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_candidate == null || _salary.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              JobOffer(
                id: _uuid.v4(),
                candidateName: _candidate!.name,
                position: _candidate!.position,
                salary: double.tryParse(_salary.text.trim()) ?? 0,
                joiningDate: _joining,
              ),
            );
          },
          child: const Text('Send Offer'),
        ),
      ],
    );
  }
}
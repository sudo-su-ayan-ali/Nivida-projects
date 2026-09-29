import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import '../common/form_widgets.dart';

/// All the "create / add" dialogs used throughout the ERP live here so
/// every quick action (dashboard tiles, page "+ Add" buttons, etc.) opens
/// a real, working form that mutates [AppState] instead of a placeholder.

Future<void> showAddAssignmentDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final dueCtrl = TextEditingController(text: '20 May 2026');
  final countCtrl = TextEditingController(text: '30');
  final formKey = GlobalKey<FormState>();
  String selectedClass = context.read<AppState>().classNames.first;

  return showAppFormDialog(
    context: context,
    title: 'Create Assignment',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Assignment Title', controller: titleCtrl, hint: 'e.g. Quadratic Equations Worksheet', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: app.classNames,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedClass = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Due Date', controller: dueCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Total Students', controller: countCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Create Assignment',
                  icon: Icons.add_task_rounded,
                                 onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    await app.addAssignment(
                      title: titleCtrl.text.trim(),
                      className: selectedClass,
                      dueDate: dueCtrl.text.trim().isEmpty ? 'TBD' : dueCtrl.text.trim(),
                      totalCount: int.tryParse(countCtrl.text.trim()) ?? 30,
                    );
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Assignment created and shared with $selectedClass');
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

Future<void> showAddExamDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: 'Mathematics');
  final dateCtrl = TextEditingController(text: '30 May 2026');
  final formKey = GlobalKey<FormState>();
  String selectedClass = context.read<AppState>().classNames.first;

  return showAppFormDialog(
    context: context,
    title: 'Schedule Test / Exam',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Exam Title', controller: titleCtrl, hint: 'e.g. Unit Test - 3', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: app.classNames,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedClass = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Subject', controller: subjectCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Date', controller: dateCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Schedule Exam',
                  icon: Icons.event_available_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    app.addExam(
                      title: titleCtrl.text.trim(),
                      className: selectedClass,
                      subject: subjectCtrl.text.trim().isEmpty ? 'Mathematics' : subjectCtrl.text.trim(),
                      date: dateCtrl.text.trim().isEmpty ? 'TBD' : dateCtrl.text.trim(),
                    );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Exam scheduled for $selectedClass');
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

Future<void> showComposeMessageDialog(BuildContext context, {String? presetRecipient}) {
  final bodyCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final recipients = ['All Classes', 'Class 10-A', 'Class 9-B', 'Class 8-A', 'Class 7-C', 'Parents', 'Principal Office'];
  String selectedRecipient = presetRecipient ?? recipients.first;

  return showAppFormDialog(
    context: context,
    title: 'Compose Message',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<String>(
                label: 'Send To',
                value: selectedRecipient,
                items: recipients,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedRecipient = v!),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Message',
                controller: bodyCtrl,
                maxLines: 4,
                hint: 'Type your message or announcement...',
                validator: (v) => v == null || v.trim().isEmpty ? 'Message cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Send Message',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<AppState>().sendMessage(recipient: selectedRecipient, body: bodyCtrl.text.trim());
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Message sent to $selectedRecipient');
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

Future<void> showLeaveRequestDialog(BuildContext context) {
  final reasonCtrl = TextEditingController();
  final dateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();
  final daysCtrl = TextEditingController(text: '1');
  final formKey = GlobalKey<FormState>();
  String leaveType = 'Casual';

  return showAppFormDialog(
    context: context,
    title: 'Apply for Leave',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<String>(
                label: 'Leave Type',
                value: leaveType,
                items: const ['Casual', 'Sick', 'Earned'],
                itemLabel: (t) => t,
                onChanged: (v) => setState(() => leaveType = v ?? leaveType),
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'From Date', controller: dateCtrl, hint: 'e.g. 22 May 2026', validator: (v) => v == null || v.trim().isEmpty ? 'Date is required' : null),
              const SizedBox(height: 14),
              AppTextField(label: 'To Date', controller: toDateCtrl, hint: 'Same as From Date if single day'),
              const SizedBox(height: 14),
              AppTextField(label: 'Number of Days', controller: daysCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
              const SizedBox(height: 14),
              AppTextField(label: 'Reason', controller: reasonCtrl, maxLines: 3, hint: 'Reason for leave', validator: (v) => v == null || v.trim().isEmpty ? 'Reason is required' : null),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Submit Request',
                  icon: Icons.send_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final days = int.tryParse(daysCtrl.text.trim()) ?? 1;
                    context.read<AppState>().addLeaveRequest(
                          reasonCtrl.text.trim(),
                          dateCtrl.text.trim(),
                          leaveType: leaveType,
                          toDate: toDateCtrl.text.trim(),
                          days: days,
                        );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Leave request submitted for approval');
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

Future<void> showAddResourceDialog(
  BuildContext context, {
  required String title,
  required String fieldLabel,
  required String fieldHint,
  required void Function(AppState app, String value1, String value2) onSubmit,
  String secondFieldLabel = 'Details',
  String secondFieldHint = '',
}) {
  final ctrl1 = TextEditingController();
  final ctrl2 = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showAppFormDialog(
    context: context,
    title: title,
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: fieldLabel, controller: ctrl1, hint: fieldHint, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 14),
          AppTextField(label: secondFieldLabel, controller: ctrl2, hint: secondFieldHint),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: 'Add',
              icon: Icons.add_rounded,
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                onSubmit(context.read<AppState>(), ctrl1.text.trim(), ctrl2.text.trim());
                Navigator.of(context).pop();
                showAppSnack(context, 'Added successfully');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAddStudentDialog(BuildContext context) {
  final nameCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String selectedClass = context.read<AppState>().classNames.first;

  return showAppFormDialog(
    context: context,
    title: 'Add Student',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Student Name', controller: nameCtrl, hint: 'e.g. Aarav Sharma', validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: app.classNames,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedClass = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Add Student',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    app.addStudent(nameCtrl.text.trim(), selectedClass);
                    Navigator.of(context).pop();
                    showAppSnack(context, '${nameCtrl.text.trim()} added to $selectedClass');
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

Future<void> showAddAssessmentDialog(BuildContext context, {required String studentId, required String studentName}) {
  final titleCtrl = TextEditingController();
  final maxCtrl = TextEditingController(text: '50');
  final obtainedCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: 'Today');
  final formKey = GlobalKey<FormState>();
  const categories = ['Unit Test', 'Assignment', 'Project', 'Quiz', 'Exam'];
  String selectedCategory = categories.first;

  return showAppFormDialog(
    context: context,
    title: 'Add Marks — $studentName',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Assessment Title', controller: titleCtrl, hint: 'e.g. Unit Test 2', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Category',
                value: selectedCategory,
                items: categories,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedCategory = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Max Marks', controller: maxCtrl, keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Obtained Marks', controller: obtainedCtrl, keyboardType: TextInputType.number, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Date', controller: dateCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Save Marks',
                  icon: Icons.check_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    final maxMarks = double.tryParse(maxCtrl.text.trim()) ?? 50;
                    final obtained = double.tryParse(obtainedCtrl.text.trim()) ?? 0;
                    context.read<AppState>().addAssessment(
                          studentId: studentId,
                          title: titleCtrl.text.trim(),
                          category: selectedCategory,
                          maxMarks: maxMarks,
                          obtained: obtained,
                          date: dateCtrl.text.trim().isEmpty ? 'TBD' : dateCtrl.text.trim(),
                        );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Marks recorded for $studentName');
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

Future<void> showAddSyllabusChapterDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: 'Mathematics');
  final topicsCtrl = TextEditingController(text: '5');
  final formKey = GlobalKey<FormState>();
  String selectedClass = context.read<AppState>().classNames.first;

  return showAppFormDialog(
    context: context,
    title: 'Add Syllabus Chapter',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Chapter Title', controller: titleCtrl, hint: 'e.g. Trigonometry', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: app.classNames,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedClass = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Subject', controller: subjectCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Total Topics', controller: topicsCtrl, keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Add Chapter',
                  icon: Icons.add_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    app.addSyllabusChapter(
                      className: selectedClass,
                      subject: subjectCtrl.text.trim().isEmpty ? 'Mathematics' : subjectCtrl.text.trim(),
                      title: titleCtrl.text.trim(),
                      totalTopics: int.tryParse(topicsCtrl.text.trim()) ?? 5,
                    );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Chapter added to $selectedClass syllabus');
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

Future<void> showAddPtmSlotDialog(BuildContext context) {
  final dateCtrl = TextEditingController(text: '18 May 2026');
  final timeCtrl = TextEditingController(text: '10:00 AM');
  final formKey = GlobalKey<FormState>();

  return showAppFormDialog(
    context: context,
    title: 'Add PTM Slot',
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: 'Date', controller: dateCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Date is required' : null),
          const SizedBox(height: 14),
          AppTextField(label: 'Time', controller: timeCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Time is required' : null),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: 'Add Slot',
              icon: Icons.add_rounded,
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                context.read<AppState>().addPtmSlot(dateCtrl.text.trim(), timeCtrl.text.trim());
                Navigator.of(context).pop();
                showAppSnack(context, 'PTM slot added');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showBookPtmSlotDialog(BuildContext context, String slotId) {
  final parentCtrl = TextEditingController();
  final studentCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  return showAppFormDialog(
    context: context,
    title: 'Book Slot',
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(label: 'Parent / Guardian Name', controller: parentCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 14),
          AppTextField(label: 'Student Name', controller: studentCtrl, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              label: 'Confirm Booking',
              icon: Icons.check_rounded,
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                context.read<AppState>().bookPtmSlot(slotId, parentName: parentCtrl.text.trim(), studentName: studentCtrl.text.trim());
                Navigator.of(context).pop();
                showAppSnack(context, 'Slot booked');
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAddHomeworkDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: 'Mathematics');
  final dueCtrl = TextEditingController(text: 'This Friday');
  final formKey = GlobalKey<FormState>();
  String selectedClass = context.read<AppState>().classNames.first;

  return showAppFormDialog(
    context: context,
    title: 'Assign Homework',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Homework Title', controller: titleCtrl, hint: 'e.g. Chapter 5 Exercises', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Class',
                value: selectedClass,
                items: app.classNames,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedClass = v!),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Subject', controller: subjectCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Due Date', controller: dueCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Assign Homework',
                  icon: Icons.add_task_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    app.addHomework(
                      title: titleCtrl.text.trim(),
                      className: selectedClass,
                      subject: subjectCtrl.text.trim().isEmpty ? 'General' : subjectCtrl.text.trim(),
                      dueDate: dueCtrl.text.trim().isEmpty ? 'TBD' : dueCtrl.text.trim(),
                    );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Homework assigned to $selectedClass — submission tracking started');
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

Future<void> showAddOnlineClassDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController(text: 'Mathematics');
  final dateCtrl = TextEditingController(text: 'Tomorrow');
  final timeCtrl = TextEditingController(text: '4:00 PM');
  final formKey = GlobalKey<FormState>();
  const platforms = ['Google Meet', 'Zoom', 'MS Teams'];
  String selectedClass = context.read<AppState>().classNames.first;
  String selectedPlatform = platforms.first;

  return showAppFormDialog(
    context: context,
    title: 'Schedule Online Class',
    child: StatefulBuilder(
      builder: (context, setState) {
        final app = context.read<AppState>();
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Session Title', controller: titleCtrl, hint: 'e.g. Live Doubt-Clearing Session', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Class',
                      value: selectedClass,
                      items: app.classNames,
                      itemLabel: (c) => c,
                      onChanged: (v) => setState(() => selectedClass = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Platform',
                      value: selectedPlatform,
                      items: platforms,
                      itemLabel: (c) => c,
                      onChanged: (v) => setState(() => selectedPlatform = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: AppTextField(label: 'Subject', controller: subjectCtrl)),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Date', controller: dateCtrl)),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Time', controller: timeCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Schedule & Generate Link',
                  icon: Icons.video_call_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    app.addOnlineClass(
                      title: titleCtrl.text.trim(),
                      className: selectedClass,
                      subject: subjectCtrl.text.trim().isEmpty ? 'General' : subjectCtrl.text.trim(),
                      date: dateCtrl.text.trim().isEmpty ? 'TBD' : dateCtrl.text.trim(),
                      time: timeCtrl.text.trim().isEmpty ? 'TBD' : timeCtrl.text.trim(),
                      platform: selectedPlatform,
                    );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Online class scheduled — meeting link generated', icon: Icons.videocam_rounded);
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

Future<void> showPostNoticeDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final bodyCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final audiences = ['All Classes', 'Class 10-A', 'Class 9-B', 'Class 8-A', 'Class 7-C', 'Parents'];
  String selectedAudience = audiences.first;

  return showAppFormDialog(
    context: context,
    title: 'Post Notice',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Title', controller: titleCtrl, hint: 'e.g. PTA Meeting Reminder', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              AppDropdown<String>(
                label: 'Audience',
                value: selectedAudience,
                items: audiences,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedAudience = v!),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Notice',
                controller: bodyCtrl,
                maxLines: 4,
                hint: 'Type the announcement...',
                validator: (v) => v == null || v.trim().isEmpty ? 'Notice cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Broadcast Notice',
                  icon: Icons.campaign_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<AppState>().postNotice(title: titleCtrl.text.trim(), body: bodyCtrl.text.trim(), audience: selectedAudience);
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Notice broadcast to $selectedAudience', icon: Icons.campaign_rounded);
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

Future<void> showAddCalendarEventDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: '1 Jun 2026');
  final formKey = GlobalKey<FormState>();
  const types = ['Holiday', 'Exam', 'Event', 'Meeting', 'Class'];
  String selectedType = types.first;

  return showAppFormDialog(
    context: context,
    title: 'Add Calendar Event',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(label: 'Event Title', controller: titleCtrl, hint: 'e.g. Republic Day', validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppDropdown<String>(
                      label: 'Type',
                      value: selectedType,
                      items: types,
                      itemLabel: (c) => c,
                      onChanged: (v) => setState(() => selectedType = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: AppTextField(label: 'Date', controller: dateCtrl)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Add Event',
                  icon: Icons.event_available_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<AppState>().addCalendarEvent(
                          title: titleCtrl.text.trim(),
                          date: dateCtrl.text.trim().isEmpty ? 'TBD' : dateCtrl.text.trim(),
                          type: selectedType,
                        );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Event added to the academic calendar');
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

Future<void> showAddBehaviorNoteDialog(BuildContext context, {required String studentId, required String studentName}) {
  final noteCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();
  const types = ['Merit', 'Demerit'];
  String selectedType = types.first;

  return showAppFormDialog(
    context: context,
    title: 'Add Note — $studentName',
    child: StatefulBuilder(
      builder: (context, setState) {
        return Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppDropdown<String>(
                label: 'Type',
                value: selectedType,
                items: types,
                itemLabel: (c) => c,
                onChanged: (v) => setState(() => selectedType = v!),
              ),
              const SizedBox(height: 14),
              AppTextField(label: 'Note', controller: noteCtrl, maxLines: 3, hint: 'What happened?', validator: (v) => v == null || v.trim().isEmpty ? 'Note is required' : null),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  label: 'Add Note',
                  icon: Icons.note_add_outlined,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    context.read<AppState>().addBehaviorNote(
                          studentId: studentId,
                          type: selectedType,
                          note: noteCtrl.text.trim(),
                          date: 'Today',
                        );
                    Navigator.of(context).pop();
                    showAppSnack(context, 'Note added for $studentName');
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

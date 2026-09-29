# Backend Completion Audit — Aug 2026

Full audit of all 12 modules (378 Dart files) to find any screen that
reads from Supabase but doesn't write back, or still ships on mock/dummy
data. Findings and fixes below.

## Fixed in this pass

1. **Teachers module — Add/Edit/Delete were never persisted.**
   `teachers_dashboard_screen.dart` loaded the roster from Supabase, but
   `_addTeacher` / `_updateTeacher` / `_deleteTeacher` only mutated the
   in-memory list (`setState`), and `TeacherFormDialog` built a fake
   local `id` (`DateTime.now().millisecondsSinceEpoch`) instead of
   inserting into the `teachers` table. Fixed:
   - `teacher_form_dialog.dart` now does a real `insert()...select().single()`
     (add) or `update()...eq('id', ...)` (edit) against `teachers`,
     with a saving spinner and an error SnackBar if the call fails.
   - `teachers_dashboard_screen.dart`'s delete now calls
     `.from('teachers').delete().eq('id', id)`, with an optimistic
     removal that rolls back on failure.
   - Uses the same demo `institution_id` constant already used by the
     Students and Inventory modules.

2. **Auth documentation was stale.** `main.dart`'s `_resolveRole` and
   `login/models/erp_role.dart`'s `kErpCredentials` still had comments
   saying "replace this with a real backend call" — but the code had
   already been upgraded to real `Supabase.instance.client.auth.signInWithPassword()`
   + a `profiles.role` lookup. Comments and `LOGIN_CREDENTIALS.md` now
   describe the real flow; `kErpCredentials` is kept only as a reference
   sheet for provisioning demo Supabase accounts.

3. **Dead mock/dummy files removed** (no longer imported anywhere,
   confirmed by grep across the whole `lib/` tree before deleting):
   - `lib/modules/fees/core/models/mock_data.dart`
   - `lib/modules/hostel/data/mock/mock_data.dart`
   - `lib/modules/attendance/data/dummy_data.dart`

## Audited and already correctly wired (no change needed)

Students, Inventory, Attendance, Settings, Fees, Examination,
HR & Payroll, Parents, Transport, and Teacher Portal all read *and*
write through Supabase already (verified by tracing each module's
service/repository/state file for matching `insert`/`update`/`delete`
calls behind every form and dialog).

Some files in these modules still contain the words "mock" or "dummy"
in filenames or comments, but on inspection they're either:
- dead leftover files with no live imports (removed, see above), or
- static UI-only config: dropdown option lists, icon/color lookups,
  and quick-action tile labels that were never meant to come from the
  database (e.g. `inventory/data/dummy_data.dart`'s `styleFor()` icon
  colors, `parents/data/mock_data_service.dart`'s quick-link shortcuts,
  `teacher_portal`'s `teachingResources`/`quickActions` tiles).

## Known remaining gap (flagged, not changed)

**Transport module's dropdown lists** (`route names`, `driver names`,
`vehicle numbers` in `top_bar.dart` and `quick_action_dialogs.dart`)
are still static lists in `transport/data/mock_data.dart`, rather than
pulled from real `routes`/`drivers`/`vehicles` tables. The transport
KPIs and the rest of the dashboard already read real data — only these
selector lists are static. This wasn't changed because doing it safely
needs the actual Supabase schema for those tables (column names, how
drivers/vehicles are linked to routes), which isn't visible from the
Flutter code alone, and this environment has no way to inspect your
Supabase project or run/compile Flutter to verify a fix. Recommend
wiring these the same way `attendance_repository.dart`'s
`fetchClassOptions()`/`fetchSectionOptions()` do (a small `select()`
of distinct values) once you confirm the table/column names.

## Testing note

This environment doesn't have the Flutter/Dart SDK or network access
to pub.dev, so none of the above could be compiled or run here. Please
run `flutter pub get && flutter analyze` (and a quick manual pass on
Teachers → Add/Edit/Delete) after unzipping.

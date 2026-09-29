/// Reusable role-based permission service.
/// UI widgets call PermissionService.can(...) instead of hard-coding role checks.
enum AppRole {
  superAdmin,
  admin,
  warden,
  accountant,
  receptionist,
  messManager,
  maintenanceStaff,
  securityStaff,
}

enum Permission { view, create, edit, delete, approve, export, manage }

class PermissionService {
  PermissionService._();

  static const Map<AppRole, Set<Permission>> _matrix = {
    AppRole.superAdmin: {
      Permission.view, Permission.create, Permission.edit, Permission.delete,
      Permission.approve, Permission.export, Permission.manage,
    },
    AppRole.admin: {
      Permission.view, Permission.create, Permission.edit, Permission.delete,
      Permission.approve, Permission.export,
    },
    AppRole.warden: {Permission.view, Permission.create, Permission.edit, Permission.approve},
    AppRole.accountant: {Permission.view, Permission.create, Permission.edit, Permission.export},
    AppRole.receptionist: {Permission.view, Permission.create, Permission.edit},
    AppRole.messManager: {Permission.view, Permission.create, Permission.edit},
    AppRole.maintenanceStaff: {Permission.view, Permission.edit},
    AppRole.securityStaff: {Permission.view, Permission.create},
  };

  static bool can(AppRole role, Permission permission) =>
      _matrix[role]?.contains(permission) ?? false;
}

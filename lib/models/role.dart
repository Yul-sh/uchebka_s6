enum Role { client, manager, admin }

extension RoleLabels on Role {
  String get label => switch (this) {
    Role.client => 'Клиент',
    Role.manager => 'Менеджер',
    Role.admin => 'Администратор',
  };

  String get apiName => name;
}

Role roleFromApi(String? value) {
  return Role.values.firstWhere(
    (item) => item.name == value,
    orElse: () => Role.client,
  );
}

enum AppOp {
  viewCatalog,
  manageCatalog,
  softDelete,
  hardDelete,
  restore,
  manageClients,
  viewOwnBookings,
  extendOwnBooking,
  issueBooking,
  closeBooking,
  manageUsers,
  viewStats,
}

class RoleAccess {
  static const allowed = {
    Role.client: {
      AppOp.viewCatalog,
      AppOp.viewOwnBookings,
      AppOp.extendOwnBooking,
      AppOp.issueBooking,
    },
    Role.manager: {
      AppOp.viewCatalog,
      AppOp.manageCatalog,
      AppOp.softDelete,
      AppOp.manageClients,
      AppOp.issueBooking,
      AppOp.closeBooking,
    },
    Role.admin: {
      AppOp.viewCatalog,
      AppOp.hardDelete,
      AppOp.restore,
      AppOp.manageUsers,
      AppOp.viewStats,
    },
  };

  static bool allows(Role role, AppOp op) =>
      allowed[role]?.contains(op) ?? false;
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/role.dart';
import '../state/auth_notifier.dart';
import 'entity_row_actions.dart';

class Can extends StatelessWidget {
  final AppOp op;
  final Widget child;

  const Can({super.key, required this.op, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AuthNotifier>().can(op)) {
      return const SizedBox.shrink();
    }
    return child;
  }
}

class AuthRowActions extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onHideOrRestore;
  final VoidCallback onDelete;
  final bool isDeleted;

  final AppOp editOp;

  const AuthRowActions({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onHideOrRestore,
    required this.onDelete,
    this.isDeleted = false,
    this.editOp = AppOp.manageCatalog,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    return EntityRowActions(
      isDeleted: isDeleted,
      showEdit: auth.can(editOp),
      showHideOrRestore: isDeleted
          ? auth.can(AppOp.restore)
          : auth.can(AppOp.softDelete),
      showDelete: auth.can(AppOp.hardDelete),
      onView: onView,
      onEdit: onEdit,
      onHideOrRestore: onHideOrRestore,
      onDelete: onDelete,
    );
  }
}

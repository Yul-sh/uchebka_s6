import 'package:flutter/material.dart';

class EntityRowActions extends StatelessWidget {
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onHideOrRestore;
  final VoidCallback onDelete;
  final bool isDeleted;
  final bool showEdit;
  final bool showHideOrRestore;
  final bool showDelete;

  const EntityRowActions({
    super.key,
    required this.onView,
    required this.onEdit,
    required this.onHideOrRestore,
    required this.onDelete,
    this.isDeleted = false,
    this.showEdit = true,
    this.showHideOrRestore = true,
    this.showDelete = true,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 0,
      runSpacing: 0,
      children: [
        IconButton(
          tooltip: 'Карточка',
          icon: const Icon(Icons.visibility_outlined),
          onPressed: onView,
        ),
        if (showEdit)
          IconButton(
            tooltip: 'Изменить',
            icon: const Icon(Icons.edit_outlined),
            onPressed: onEdit,
          ),
        if (showHideOrRestore)
          IconButton(
            tooltip: isDeleted ? 'Восстановить' : 'Скрыть',
            icon: Icon(
              isDeleted ? Icons.restore : Icons.visibility_off_outlined,
            ),
            onPressed: onHideOrRestore,
          ),
        if (showDelete)
          IconButton(
            tooltip: 'Удалить навсегда',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../core/breakpoints.dart';

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Скрыть',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.dialogMaxWidth,
          ),
          child: AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

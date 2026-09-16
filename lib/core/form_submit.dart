import 'package:flutter/material.dart';

import '../widgets/api_error_dialog.dart';
import 'api_exceptions.dart';

Future<void> showApiMessage(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      alignment: Alignment.center,
      title: const Text('Готово', textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Понятно'),
        ),
      ],
    ),
  );
}

Future<bool> runApiSave({
  required BuildContext context,
  required Future<void> Function() action,
  required void Function(Map<String, String> errors) onValidation,
}) async {
  try {
    await action();
    return true;
  } on ValidationException catch (e) {
    onValidation(e.errors);
    if (context.mounted) await showApiError(context, e);
    return false;
  } on ApiException catch (e) {
    if (context.mounted) await showApiError(context, e);
    return false;
  }
}

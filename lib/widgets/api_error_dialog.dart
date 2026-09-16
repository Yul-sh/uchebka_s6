import 'package:flutter/material.dart';

import '../core/api_exceptions.dart';
import '../core/breakpoints.dart';

Future<void> showApiError(BuildContext context, ApiException error) {
  return showApiErrorText(
    context,
    message: error.message,
    kind: error.kindLabel,
  );
}

Future<void> showApiErrorText(
  BuildContext context, {
  required String message,
  required String kind,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.dialogMaxWidth,
          ),
          child: AlertDialog(
            alignment: Alignment.center,
            icon: Icon(Icons.error_outline, color: scheme.error, size: 40),
            title: const Text('Ошибка', textAlign: TextAlign.center),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  kind,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Понятно'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

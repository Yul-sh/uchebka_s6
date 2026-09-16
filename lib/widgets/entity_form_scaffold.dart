import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/breakpoints.dart';
import 'confirm_dialog.dart';

class EntityFormScaffold extends StatelessWidget {
  final String title;
  final String saveLabel;
  final String leavePath;
  final bool dirty;
  final bool loading;
  final GlobalKey<FormState> formKey;
  final Future<void> Function() onSave;
  final List<Widget> children;

  const EntityFormScaffold({
    super.key,
    required this.title,
    required this.saveLabel,
    required this.leavePath,
    required this.dirty,
    required this.loading,
    required this.formKey,
    required this.onSave,
    required this.children,
  });

  Future<void> _leave(BuildContext context) async {
    if (dirty) {
      final ok = await confirmAction(
        context,
        title: 'Несохранённые изменения',
        message: 'Выйти без сохранения?',
        confirmLabel: 'Выйти',
      );
      if (!ok) return;
    }
    if (context.mounted) context.go(leavePath);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !dirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _leave(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, overflow: TextOverflow.ellipsis),
          leading: IconButton(
            tooltip: 'Назад',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _leave(context),
          ),
        ),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Breakpoints.formMaxWidth,
                  ),
                  child: Form(
                    key: formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ...children,
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: loading ? null : onSave,
                          child: Text(saveLabel),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/app_user.dart';
import '../models/role.dart';
import '../repositories/admin_repository.dart';
import '../widgets/api_error_dialog.dart';
import '../widgets/list_status_views.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AppUser>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<AdminRepository>().users();
      if (mounted) setState(() => _items = items);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _error = '${e.message}\n\n${e.kindLabel}');
        await showApiError(context, e);
      }
    }
  }

  Future<void> _setRole(AppUser user, Role role) async {
    try {
      await context.read<AdminRepository>().setRole(user.id, role.apiName);
      await _load();
    } on ApiException catch (e) {
      if (mounted) await showApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Пользователи и роли')),
      body: _error != null && _items == null
          ? ErrorResultView(message: _error!, onRetry: _load)
          : _items == null
          ? const LoadingView()
          : ListView(
              children: [
                for (final user in _items!)
                  ListTile(
                    title: Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      user.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: DropdownButton<Role>(
                      value: user.role,
                      items: [
                        for (final role in Role.values)
                          DropdownMenuItem(
                            value: role,
                            child: Text(role.label),
                          ),
                      ],
                      onChanged: (role) {
                        if (role != null) _setRole(user, role);
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

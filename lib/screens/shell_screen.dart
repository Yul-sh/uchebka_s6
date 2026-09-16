import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/breakpoints.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool Function(AuthNotifier auth) visible;

  const _NavItem({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.visible,
  });
}

const _items = [
  _NavItem(
    path: '/tours',
    label: 'Туры',
    icon: Icons.flight_takeoff_outlined,
    selectedIcon: Icons.flight_takeoff,
    visible: _always,
  ),
  _NavItem(
    path: '/my-bookings',
    label: 'Мои брони',
    icon: Icons.confirmation_number_outlined,
    selectedIcon: Icons.confirmation_number,
    visible: _ownBookings,
  ),
  _NavItem(
    path: '/hotels',
    label: 'Отели',
    icon: Icons.hotel_outlined,
    selectedIcon: Icons.hotel,
    visible: _catalogStaff,
  ),
  _NavItem(
    path: '/destinations',
    label: 'Направления',
    icon: Icons.public_outlined,
    selectedIcon: Icons.public,
    visible: _catalogStaff,
  ),
  _NavItem(
    path: '/categories',
    label: 'Типы',
    icon: Icons.category_outlined,
    selectedIcon: Icons.category,
    visible: _catalogStaff,
  ),
  _NavItem(
    path: '/clients',
    label: 'Клиенты',
    icon: Icons.people_outlined,
    selectedIcon: Icons.people,
    visible: _clients,
  ),
  _NavItem(
    path: '/issues',
    label: 'Выдачи',
    icon: Icons.assignment_turned_in_outlined,
    selectedIcon: Icons.assignment_turned_in,
    visible: _issues,
  ),
  _NavItem(
    path: '/admin/users',
    label: 'Пользователи',
    icon: Icons.admin_panel_settings_outlined,
    selectedIcon: Icons.admin_panel_settings,
    visible: _users,
  ),
  _NavItem(
    path: '/admin/stats',
    label: 'Статистика',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    visible: _stats,
  ),
];

bool _always(AuthNotifier auth) => true;
bool _ownBookings(AuthNotifier auth) => auth.can(AppOp.viewOwnBookings);
bool _catalogStaff(AuthNotifier auth) =>
    auth.can(AppOp.manageCatalog) || auth.can(AppOp.hardDelete);
bool _clients(AuthNotifier auth) => auth.can(AppOp.manageClients);
bool _issues(AuthNotifier auth) => auth.can(AppOp.closeBooking);
bool _users(AuthNotifier auth) => auth.can(AppOp.manageUsers);
bool _stats(AuthNotifier auth) => auth.can(AppOp.viewStats);

class ShellScreen extends StatelessWidget {
  final Widget child;

  const ShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final visible = _items.where((item) => item.visible(auth)).toList();
    final location = GoRouterState.of(context).uri.path;
    var index = visible.indexWhere((item) => location.startsWith(item.path));
    if (index < 0) index = 0;
    final useRail = Breakpoints.useRail(context);
    final labeled = Breakpoints.railWithLabels(context);
    final user = auth.user;

    final destinations = [
      for (final item in visible)
        NavigationDestination(
          icon: Tooltip(message: item.label, child: Icon(item.icon)),
          selectedIcon: Tooltip(
            message: item.label,
            child: Icon(item.selectedIcon),
          ),
          label: item.label,
        ),
    ];

    return Scaffold(
      body: Column(
        children: [
          Material(
            color: const Color(0xFFD8EEF1),
            child: SafeArea(
              bottom: false,
              child: ListTile(
                dense: true,
                title: Text(
                  user?.displayName ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  user?.role.label ?? '',
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: TextButton(
                  onPressed: () => auth.logout(),
                  child: const Text('Выйти'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (useRail)
                  NavigationRail(
                    selectedIndex: index,
                    onDestinationSelected: (value) =>
                        context.go(visible[value].path),
                    labelType: labeled
                        ? NavigationRailLabelType.all
                        : NavigationRailLabelType.none,
                    destinations: [
                      for (final item in visible)
                        NavigationRailDestination(
                          icon: Tooltip(
                            message: item.label,
                            child: Icon(item.icon),
                          ),
                          selectedIcon: Tooltip(
                            message: item.label,
                            child: Icon(item.selectedIcon),
                          ),
                          label: Text(item.label),
                        ),
                    ],
                  ),
                Expanded(child: MaxWidthBody(child: child)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: index,
              destinations: destinations,
              onDestinationSelected: (value) => context.go(visible[value].path),
            ),
    );
  }
}

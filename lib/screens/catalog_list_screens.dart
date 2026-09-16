import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/catalog_query.dart';
import '../models/client.dart';
import '../models/lookups.dart';
import '../models/role.dart';
import '../routing/query_navigation.dart';
import '../routing/reload_when_visible.dart';
import '../state/auth_notifier.dart';
import '../state/catalog_list_notifiers.dart';
import '../state/catalog_lookups.dart';
import '../state/load_status.dart';
import '../widgets/adaptive_entity_list.dart';
import '../widgets/api_error_dialog.dart';
import '../widgets/can.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/debounced_search_field.dart';
import '../widgets/entity_table.dart';
import '../widgets/list_status_views.dart';
import '../widgets/pagination_bar.dart';

class DestinationListScreen extends StatefulWidget {
  final CatalogQuery query;
  const DestinationListScreen({super.key, required this.query});

  @override
  State<DestinationListScreen> createState() => _DestinationListScreenState();
}

class _DestinationListScreenState extends State<DestinationListScreen>
    with ReloadWhenVisible {
  @override
  String get visiblePath => '/destinations';

  @override
  void onBecameVisible() {
    context.read<DestinationListNotifier>().applyQuery(widget.query);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onBecameVisible();
    });
  }

  @override
  void didUpdateWidget(DestinationListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      context.read<DestinationListNotifier>().applyQuery(widget.query);
    }
  }

  void _go(CatalogQuery next) =>
      goWithQuery(context, '/destinations', next.toQueryParameters());

  Future<void> _hardDelete(Destination item) async {
    final ok = await confirmAction(
      context,
      title: 'Удалить навсегда',
      message: '«${item.name}» будет стёрто.',
      confirmLabel: 'Удалить навсегда',
    );
    if (!ok || !mounted) return;
    try {
      await context.read<DestinationListNotifier>().hardDelete(item.id);
      if (!mounted) return;
      await context.read<CatalogLookups>().reload();
    } on ApiException catch (e) {
      if (mounted) await showApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = context.watch<DestinationListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final q = widget.query;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Направления'),
        actions: [
          if (auth.can(AppOp.softDelete) && n.hasSelection)
            IconButton(
              tooltip: 'Скрыть (${n.selected.length})',
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Скрыть выбранные',
                  message: 'Скрыть ${n.selected.length} записей?',
                );
                if (ok && mounted) await n.deleteSelected();
              },
              icon: const Icon(Icons.visibility_off_outlined),
            ),
        ],
      ),
      floatingActionButton: auth.can(AppOp.manageCatalog)
          ? FloatingActionButton(
              onPressed: () => context.go('/destinations/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DebouncedSearchField(
              value: q.search,
              hint: 'Поиск по названию или стране',
              onSubmit: (text) => _go(q.copyWith(search: text)),
            ),
          ),
          SwitchListTile(
            title: const Text('Показывать скрытые'),
            value: q.includeDeleted,
            onChanged: (v) => _go(q.copyWith(includeDeleted: v)),
          ),
          _bulkHideBar(
            context: context,
            count: n.selected.length,
            title: 'Скрыть выбранные',
            message: 'Скрыть ${n.selected.length} записей?',
            onHide: n.deleteSelected,
          ),
          Expanded(child: _body(n, q)),
          if (n.status == LoadStatus.success)
            PaginationBar(
              page: n.result.page,
              totalPages: n.result.totalPages,
              total: n.result.total,
              size: n.result.size,
              hasPrevious: n.result.hasPrevious,
              hasNext: n.result.hasNext,
              onPage: (p) => _go(q.copyWith(page: p)),
              onSize: (s) => _go(q.copyWith(size: s)),
            ),
        ],
      ),
    );
  }

  Widget _body(DestinationListNotifier n, CatalogQuery q) {
    return switch (n.status) {
      LoadStatus.idle || LoadStatus.loading => const LoadingView(),
      LoadStatus.error => ErrorResultView(
        message: n.error ?? '',
        onRetry: n.load,
      ),
      LoadStatus.success when n.result.items.isEmpty => const EmptyResultView(),
      LoadStatus.success => AdaptiveEntityList<Destination>(
        items: n.result.items.cast<Destination>(),
        idOf: (d) => d.id,
        titleOf: (d) => d.name,
        selected: n.selected,
        onToggleSelect: n.toggleSelection,
        sortField: q.sortField,
        sortAscending: q.sortAscending,
        isDeleted: (d) => d.isDeleted,
        onSort: (field) => _go(
          q.copyWith(
            sortField: field,
            sortAscending: field == q.sortField ? !q.sortAscending : true,
          ),
        ),
        columns: [
          TableColumnSpec(
            label: 'Название',
            sortField: 'name',
            build: (d) =>
                Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          TableColumnSpec(
            label: 'Страна',
            sortField: 'country',
            build: (d) =>
                Text(d.country, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
        actions: (d) => [
          AuthRowActions(
            isDeleted: d.isDeleted,
            onView: () => context.go('/destinations/${d.id}'),
            onEdit: () => context.go('/destinations/${d.id}/edit'),
            onHideOrRestore: () =>
                d.isDeleted ? n.restore(d.id) : n.softDelete(d.id),
            onDelete: () => _hardDelete(d),
          ),
        ],
      ),
    };
  }
}

class CategoryListScreen extends StatefulWidget {
  final CatalogQuery query;
  const CategoryListScreen({super.key, required this.query});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with ReloadWhenVisible {
  @override
  String get visiblePath => '/categories';

  @override
  void onBecameVisible() {
    context.read<CategoryListNotifier>().applyQuery(widget.query);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onBecameVisible();
    });
  }

  @override
  void didUpdateWidget(CategoryListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      context.read<CategoryListNotifier>().applyQuery(widget.query);
    }
  }

  void _go(CatalogQuery next) =>
      goWithQuery(context, '/categories', next.toQueryParameters());

  @override
  Widget build(BuildContext context) {
    final n = context.watch<CategoryListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final q = widget.query;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Типы туров'),
        actions: [
          if (auth.can(AppOp.softDelete) && n.hasSelection)
            IconButton(
              tooltip: 'Скрыть (${n.selected.length})',
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Скрыть выбранные',
                  message: 'Скрыть ${n.selected.length} тип(ов)?',
                );
                if (!ok || !context.mounted) return;
                await n.deleteSelected();
                if (!context.mounted) return;
                await context.read<CatalogLookups>().reload();
              },
              icon: const Icon(Icons.visibility_off_outlined),
            ),
        ],
      ),
      floatingActionButton: auth.can(AppOp.manageCatalog)
          ? FloatingActionButton(
              onPressed: () => context.go('/categories/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DebouncedSearchField(
              value: q.search,
              hint: 'Поиск по названию',
              onSubmit: (text) => _go(q.copyWith(search: text)),
            ),
          ),
          SwitchListTile(
            title: const Text('Показывать скрытые'),
            value: q.includeDeleted,
            onChanged: (v) => _go(q.copyWith(includeDeleted: v)),
          ),
          _bulkHideBar(
            context: context,
            count: n.selected.length,
            title: 'Скрыть выбранные',
            message: 'Скрыть ${n.selected.length} тип(ов)?',
            onHide: () async {
              await n.deleteSelected();
              if (context.mounted) {
                await context.read<CatalogLookups>().reload();
              }
            },
          ),
          Expanded(
            child: switch (n.status) {
              LoadStatus.idle || LoadStatus.loading => const LoadingView(),
              LoadStatus.error => ErrorResultView(
                message: n.error ?? '',
                onRetry: n.load,
              ),
              LoadStatus.success when n.result.items.isEmpty =>
                const EmptyResultView(),
              LoadStatus.success => AdaptiveEntityList<TourCategory>(
                items: n.result.items.cast<TourCategory>(),
                idOf: (c) => c.id,
                titleOf: (c) => c.name,
                selected: n.selected,
                onToggleSelect: n.toggleSelection,
                sortField: q.sortField,
                sortAscending: q.sortAscending,
                isDeleted: (c) => c.isDeleted,
                onSort: (field) => _go(
                  q.copyWith(
                    sortField: field,
                    sortAscending: field == q.sortField
                        ? !q.sortAscending
                        : true,
                  ),
                ),
                columns: [
                  TableColumnSpec(
                    label: 'Название',
                    sortField: 'name',
                    build: (c) => Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                actions: (c) => [
                  AuthRowActions(
                    isDeleted: c.isDeleted,
                    onView: () => context.go('/categories/${c.id}'),
                    onEdit: () => context.go('/categories/${c.id}/edit'),
                    onHideOrRestore: () =>
                        c.isDeleted ? n.restore(c.id) : n.softDelete(c.id),
                    onDelete: () async {
                      try {
                        await n.hardDelete(c.id);
                        if (context.mounted) {
                          await context.read<CatalogLookups>().reload();
                        }
                      } on ApiException catch (e) {
                        if (context.mounted) await showApiError(context, e);
                      }
                    },
                  ),
                ],
              ),
            },
          ),
          if (n.status == LoadStatus.success)
            PaginationBar(
              page: n.result.page,
              totalPages: n.result.totalPages,
              total: n.result.total,
              size: n.result.size,
              hasPrevious: n.result.hasPrevious,
              hasNext: n.result.hasNext,
              onPage: (p) => _go(q.copyWith(page: p)),
              onSize: (s) => _go(q.copyWith(size: s)),
            ),
        ],
      ),
    );
  }
}

class ClientListScreen extends StatefulWidget {
  final CatalogQuery query;
  const ClientListScreen({super.key, required this.query});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen>
    with ReloadWhenVisible {
  @override
  String get visiblePath => '/clients';

  @override
  void onBecameVisible() {
    context.read<ClientListNotifier>().applyQuery(widget.query);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) onBecameVisible();
    });
  }

  @override
  void didUpdateWidget(ClientListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      context.read<ClientListNotifier>().applyQuery(widget.query);
    }
  }

  void _go(CatalogQuery next) => goWithQuery(
    context,
    '/clients',
    next.toQueryParameters(defaultSort: 'lastName'),
  );

  @override
  Widget build(BuildContext context) {
    final n = context.watch<ClientListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final q = widget.query;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Клиенты'),
        actions: [
          if (auth.can(AppOp.softDelete) && n.hasSelection)
            IconButton(
              tooltip: 'Скрыть (${n.selected.length})',
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Скрыть выбранных',
                  message: 'Скрыть ${n.selected.length} клиент(ов)?',
                );
                if (ok && mounted) await n.deleteSelected();
              },
              icon: const Icon(Icons.visibility_off_outlined),
            ),
        ],
      ),
      floatingActionButton: auth.can(AppOp.manageClients)
          ? FloatingActionButton(
              onPressed: () => context.go('/clients/new'),
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: DebouncedSearchField(
              value: q.search,
              hint: 'Поиск по фамилии или почте',
              onSubmit: (text) => _go(q.copyWith(search: text)),
            ),
          ),
          SwitchListTile(
            title: const Text('Показывать скрытых'),
            value: q.includeDeleted,
            onChanged: (v) => _go(q.copyWith(includeDeleted: v)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String?>(
              initialValue: q.status,
              decoration: const InputDecoration(
                labelText: 'Статус карты',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Все')),
                DropdownMenuItem(value: 'active', child: Text('Активна')),
                DropdownMenuItem(value: 'expired', child: Text('Истекла')),
              ],
              onChanged: (v) => _go(q.copyWith(status: v)),
            ),
          ),
          _bulkHideBar(
            context: context,
            count: n.selected.length,
            title: 'Скрыть выбранных',
            message: 'Скрыть ${n.selected.length} клиент(ов)?',
            onHide: n.deleteSelected,
          ),
          Expanded(
            child: switch (n.status) {
              LoadStatus.idle || LoadStatus.loading => const LoadingView(),
              LoadStatus.error => ErrorResultView(
                message: n.error ?? '',
                onRetry: n.load,
              ),
              LoadStatus.success when n.result.items.isEmpty =>
                const EmptyResultView(),
              LoadStatus.success => AdaptiveEntityList<Client>(
                items: n.result.items.cast<Client>(),
                idOf: (c) => c.id,
                titleOf: (c) => c.fullName,
                selected: n.selected,
                onToggleSelect: n.toggleSelection,
                sortField: q.sortField,
                sortAscending: q.sortAscending,
                isDeleted: (c) => c.isDeleted,
                onSort: (field) => _go(
                  q.copyWith(
                    sortField: field,
                    sortAscending: field == q.sortField
                        ? !q.sortAscending
                        : true,
                  ),
                ),
                columns: [
                  TableColumnSpec(
                    label: 'Фамилия',
                    sortField: 'lastName',
                    build: (c) => Text(
                      c.lastName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TableColumnSpec(
                    label: 'Имя',
                    sortField: 'firstName',
                    build: (c) => Text(
                      c.firstName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TableColumnSpec(
                    label: 'Почта',
                    sortField: 'email',
                    build: (c) => Text(
                      c.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TableColumnSpec(
                    label: 'Карта',
                    build: (c) => Text(
                      c.card.number,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                actions: (c) => [
                  AuthRowActions(
                    isDeleted: c.isDeleted,
                    editOp: AppOp.manageClients,
                    onView: () => context.go('/clients/${c.id}'),
                    onEdit: () => context.go('/clients/${c.id}/edit'),
                    onHideOrRestore: () =>
                        c.isDeleted ? n.restore(c.id) : n.softDelete(c.id),
                    onDelete: () async {
                      try {
                        await n.hardDelete(c.id);
                      } on ApiException catch (e) {
                        if (context.mounted) await showApiError(context, e);
                      }
                    },
                  ),
                ],
              ),
            },
          ),
          if (n.status == LoadStatus.success)
            PaginationBar(
              page: n.result.page,
              totalPages: n.result.totalPages,
              total: n.result.total,
              size: n.result.size,
              hasPrevious: n.result.hasPrevious,
              hasNext: n.result.hasNext,
              onPage: (p) => _go(q.copyWith(page: p)),
              onSize: (s) => _go(q.copyWith(size: s)),
            ),
        ],
      ),
    );
  }
}

Widget _bulkHideBar({
  required BuildContext context,
  required int count,
  required String title,
  required String message,
  required Future<void> Function() onHide,
}) {
  if (count == 0) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: FilledButton.tonalIcon(
        onPressed: () async {
          final ok = await confirmAction(
            context,
            title: title,
            message: message,
            confirmLabel: 'Скрыть',
          );
          if (ok) await onHide();
        },
        icon: const Icon(Icons.visibility_off_outlined),
        label: Text('Скрыть выбранные ($count)'),
      ),
    ),
  );
}

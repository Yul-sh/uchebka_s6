import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/role.dart';
import '../state/auth_notifier.dart';
import '../state/hotel_detail_notifier.dart';
import '../state/load_status.dart';
import '../widgets/api_error_dialog.dart';
import '../widgets/can.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/entity_detail_card.dart';
import '../widgets/list_status_views.dart';

class HotelDetailScreen extends StatelessWidget {
  const HotelDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<HotelDetailNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Карточка отеля'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/hotels');
            }
          },
        ),
        actions: [
          if (context.watch<AuthNotifier>().can(AppOp.manageCatalog))
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.go('/hotels/${notifier.id}/edit'),
            ),
        ],
      ),
      body: switch (notifier.status) {
        LoadStatus.idle || LoadStatus.loading => const LoadingView(),
        LoadStatus.error => ErrorResultView(
          message: notifier.error ?? 'Отель не найден',
          onRetry: notifier.load,
        ),
        LoadStatus.success => _HotelCard(notifier: notifier),
      },
    );
  }
}

class _HotelCard extends StatelessWidget {
  final HotelDetailNotifier notifier;

  const _HotelCard({required this.notifier});

  @override
  Widget build(BuildContext context) {
    final hotel = notifier.hotel!;
    final rows = <(String, String)>[
      ('Название', hotel.name),
      ('Страна', hotel.country),
      ('Город', hotel.city),
      ('Звёзды', '${hotel.stars}'),
      ('Статус', hotel.isDeleted ? 'Скрыт' : 'В каталоге'),
    ];

    return EntityDetailCard(
      rows: rows,
      actions: [
        if (hotel.isDeleted)
          Can(
            op: AppOp.restore,
            child: FilledButton.icon(
              onPressed: notifier.restore,
              icon: const Icon(Icons.restore),
              label: const Text('Восстановить'),
            ),
          )
        else
          Can(
            op: AppOp.softDelete,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Скрыть отель',
                  message: 'Отель будет скрыт из каталога.',
                  confirmLabel: 'Скрыть',
                );
                if (ok) await notifier.softDelete();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Скрыть'),
            ),
          ),
        Can(
          op: AppOp.hardDelete,
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: 'Удалить навсегда',
                message: 'Запись будет стёрта из памяти.',
                confirmLabel: 'Удалить навсегда',
              );
              if (ok && context.mounted) {
                try {
                  await notifier.hardDelete();
                  if (context.mounted) context.go('/hotels');
                } on ApiException catch (e) {
                  if (context.mounted) await showApiError(context, e);
                }
              }
            },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Удалить навсегда'),
          ),
        ),
      ],
    );
  }
}

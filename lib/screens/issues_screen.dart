import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_exceptions.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import '../widgets/api_error_dialog.dart';
import '../widgets/list_status_views.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  List<Booking>? _items;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await context.read<BookingRepository>().all();
      if (mounted) setState(() => _items = items);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = '${e.message}\n\n${e.kindLabel}');
    }
  }

  Future<void> _close(Booking item) async {
    try {
      await context.read<BookingRepository>().close(item.id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) await showApiError(context, e);
    }
  }

  Future<void> _reopen(Booking item) async {
    try {
      await context.read<BookingRepository>().reopen(item.id);
      await _load();
    } on ApiException catch (e) {
      if (mounted) await showApiError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Выдачи броней')),
      body: _error != null
          ? ErrorResultView(message: _error!, onRetry: _load)
          : _items == null
          ? const LoadingView()
          : _items!.isEmpty
          ? const EmptyResultView(message: 'Выдач пока нет')
          : ListView(
              children: [
                for (final item in _items!)
                  ListTile(
                    title: Text(
                      item.tourTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      item.managerSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: item.isActive
                        ? FilledButton.tonal(
                            onPressed: () => _close(item),
                            child: const Text('Закрыть'),
                          )
                        : FilledButton(
                            onPressed: () => _reopen(item),
                            child: const Text('Открыть'),
                          ),
                  ),
              ],
            ),
    );
  }
}

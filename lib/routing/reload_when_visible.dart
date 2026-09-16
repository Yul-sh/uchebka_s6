import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

mixin ReloadWhenVisible<T extends StatefulWidget> on State<T> {
  String get visiblePath;
  void onBecameVisible();

  GoRouter? _router;
  String? _seenPath;

  String? _currentPath() {
    try {
      return _router?.state.uri.path;
    } catch (_) {
      return null;
    }
  }

  void _handle() {
    final path = _currentPath();
    if (path == null) return;
    if (path == visiblePath && _seenPath != visiblePath) {
      _seenPath = path;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) onBecameVisible();
      });
    } else {
      _seenPath = path;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final router = GoRouter.of(context);
    if (!identical(_router, router)) {
      _router?.routerDelegate.removeListener(_handle);
      _router = router;
      _router!.routerDelegate.addListener(_handle);
    }
    _handle();
  }

  @override
  void dispose() {
    _router?.routerDelegate.removeListener(_handle);
    super.dispose();
  }
}

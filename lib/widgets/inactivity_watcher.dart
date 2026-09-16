import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/config.dart';

class InactivityWatcher extends StatefulWidget {
  final VoidCallback onTimeout;
  final VoidCallback onWarning;
  final VoidCallback onActivity;
  final Widget child;

  const InactivityWatcher({
    super.key,
    required this.onTimeout,
    required this.onWarning,
    required this.onActivity,
    required this.child,
  });

  @override
  State<InactivityWatcher> createState() => _InactivityWatcherState();
}

class _InactivityWatcherState extends State<InactivityWatcher> {
  Timer? _logout;
  Timer? _warn;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
    _restart();
  }

  bool _onKey(KeyEvent event) {
    _restart();
    return false;
  }

  void _restart() {
    _logout?.cancel();
    _warn?.cancel();
    widget.onActivity();
    final warnAfter = inactivityTimeout - inactivityWarning;
    _warn = Timer(warnAfter, widget.onWarning);
    _logout = Timer(inactivityTimeout, widget.onTimeout);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _logout?.cancel();
    _warn?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _restart(),
      onPointerMove: (_) => _restart(),
      onPointerSignal: (_) => _restart(),
      child: widget.child,
    );
  }
}

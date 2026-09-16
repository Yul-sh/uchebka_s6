import 'package:flutter/material.dart';

class ConnectivityRestorer extends StatefulWidget {
  final VoidCallback onBackOnline;
  final Widget child;

  const ConnectivityRestorer({
    super.key,
    required this.onBackOnline,
    required this.child,
  });

  @override
  State<ConnectivityRestorer> createState() => _ConnectivityRestorerState();
}

class _ConnectivityRestorerState extends State<ConnectivityRestorer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.onBackOnline();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

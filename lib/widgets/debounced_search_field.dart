import 'dart:async';

import 'package:flutter/material.dart';

class DebouncedSearchField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onSubmit;
  final Duration delay;

  const DebouncedSearchField({
    super.key,
    required this.value,
    required this.onSubmit,
    this.hint = 'Поиск',
    this.delay = const Duration(milliseconds: 350),
  });

  @override
  State<DebouncedSearchField> createState() => _DebouncedSearchFieldState();
}

class _DebouncedSearchFieldState extends State<DebouncedSearchField> {
  late final TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(DebouncedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () => widget.onSubmit(text));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      onSubmitted: widget.onSubmit,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Очистить',
                onPressed: () {
                  _controller.clear();
                  widget.onSubmit('');
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

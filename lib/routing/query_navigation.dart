import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void goWithQuery(
  BuildContext context,
  String path,
  Map<String, String> params,
) {
  final uri = Uri(path: path, queryParameters: params.isEmpty ? null : params);
  context.go(uri.toString());
}

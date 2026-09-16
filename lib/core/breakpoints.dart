import 'package:flutter/material.dart';

abstract final class Breakpoints {
  static const narrow = 360.0;
  static const medium = 768.0;
  static const wide = 1280.0;
  static const ultra = 1920.0;

  static bool useCards(BuildContext context) =>
      MediaQuery.sizeOf(context).width < wide;

  static bool useRail(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  static bool railWithLabels(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= wide;

  static bool twoColumnCards(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= medium && w < wide;
  }

  static const contentMaxWidth = 1280.0;
  static const formMaxWidth = 520.0;
  static const dialogMaxWidth = 420.0;
  static const yearFieldMaxWidth = 140.0;
}

class MaxWidthBody extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const MaxWidthBody({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

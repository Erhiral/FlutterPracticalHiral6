import 'package:flutter/material.dart';

/// Simple responsive size helper used across the app.
class Screen {
  static late double width;
  static late double height;
  static late double _textScale;

  static void init(BuildContext context) {
    final mq = MediaQuery.of(context);
    width = mq.size.width;
    height = mq.size.height;
    _textScale = mq.textScaleFactor;
  }

  /// width percent
  static double wp(double percent) => width * (percent / 100);

  /// height percent
  static double hp(double percent) => height * (percent / 100);

  /// Scaled font size (keeps system text scale into account)
  static double sp(double size) => size * _textScale;
}

class Gap extends SizedBox {
  const Gap.h(double h, {super.key}) : super(height: h);
  const Gap.w(double w, {super.key}) : super(width: w);
}

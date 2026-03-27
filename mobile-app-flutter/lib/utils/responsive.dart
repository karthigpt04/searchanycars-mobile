import 'dart:math';
import 'package:flutter/material.dart';

class Responsive {
  static late double _screenWidth;
  static late double _screenHeight;

  static const double _baseWidth = 393;
  static const double _baseHeight = 852;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
  }

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;

  /// Scale a value proportionally to screen width
  static double wp(double size) {
    return (_screenWidth / _baseWidth) * size;
  }

  /// Scale a value proportionally to screen height
  static double hp(double size) {
    return (_screenHeight / _baseHeight) * size;
  }

  /// Font scaling with upper limit to prevent massive text on tablets
  static double fp(double size) {
    final scale = _screenWidth / _baseWidth;
    final clampedScale = min(scale, 1.3);
    return size * clampedScale;
  }

  /// Screen horizontal padding (~5.5% of width)
  static double get screenPadding => _screenWidth * 0.055;

  /// Featured car card width (~56% of screen)
  static double get featuredCardWidth => _screenWidth * 0.56;
}

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.bgGlass;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

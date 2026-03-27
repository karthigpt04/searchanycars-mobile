import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../utils/responsive.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final EdgeInsetsGeometry? padding;

  const ScreenContainer({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    Widget content = Padding(
      padding: padding ??
          EdgeInsets.symmetric(horizontal: Responsive.screenPadding),
      child: child,
    );

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: content,
    );
  }
}

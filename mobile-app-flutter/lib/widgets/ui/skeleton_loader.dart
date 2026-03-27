import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgCardHover,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

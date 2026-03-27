import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class CarImage extends StatelessWidget {
  final String? imageUrl;
  final String brandInitial;
  final Color? gradientColor;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;

  const CarImage({
    super.key,
    this.imageUrl,
    required this.brandInitial,
    this.gradientColor,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final color = gradientColor ?? AppColors.gold;

    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback(color);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildFallback(color),
        errorWidget: (context, url, error) => _buildFallback(color),
      ),
    );
  }

  Widget _buildFallback(Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.3),
            AppColors.bgCard,
          ],
        ),
      ),
      child: Center(
        child: Text(
          brandInitial,
          style: GoogleFonts.dmSans(
            fontSize: (height ?? 100) * 0.4,
            fontWeight: FontWeight.w800,
            color: color.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class BadgeWidget extends StatelessWidget {
  final String text;
  final Color color;
  final double bgOpacity;

  const BadgeWidget({
    super.key,
    required this.text,
    this.color = AppColors.gold,
    this.bgOpacity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:bgOpacity),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

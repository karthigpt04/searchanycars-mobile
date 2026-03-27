import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle get screenTitle => GoogleFonts.dmSans(
    fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary,
  );
  static TextStyle get sectionHeading => GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle get carName => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle get body => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static TextStyle get priceFeatured => GoogleFonts.dmSans(
    fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.gold,
  );
  static TextStyle get priceCard => GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold,
  );
  static TextStyle get meta => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.5,
  );
  static TextStyle get label => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold, letterSpacing: 1,
  );
  static TextStyle get badge => GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold, letterSpacing: 0.5,
  );
  static TextStyle get navLabel => GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.textMuted,
  );
  static TextStyle get navLabelActive => GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gold,
  );
}

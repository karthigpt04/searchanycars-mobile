import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/mock_data.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'car':
        return LucideIcons.car;
      case 'heart':
        return LucideIcons.heart;
      case 'compare':
        return LucideIcons.arrowLeftRight;
      case 'shield':
        return LucideIcons.shield;
      case 'phone':
        return LucideIcons.phone;
      case 'bell':
        return LucideIcons.bell;
      default:
        return LucideIcons.circleEllipsis;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = MockData.currentUser;
    final menuItems = MockData.profileMenuItems;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      AppColors.gold.withValues(alpha:0.08),
                      AppColors.bg,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.gold,
                            AppColors.goldLight,
                            AppColors.gold,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withValues(alpha:0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.initials,
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.bg,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      user.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Member since
                    Text(
                      'Member since ${user.memberSince}',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Gold Member badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha:0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            LucideIcons.star,
                            size: 14,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${user.tier} Member',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: menuItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final icon = _mapIcon(item['icon'] as String);
                    final label = item['label'] as String;
                    final count = item['count'] as int;

                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Icon container
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.bgCard,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Icon(
                                icon,
                                size: 20,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Label
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // Count badge
                          if (count > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                count.toString(),
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          if (count > 0) const SizedBox(width: 8),
                          // Chevron
                          const Icon(
                            LucideIcons.chevronRight,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: Duration(milliseconds: 100 + index * 60),
                        )
                        .slideX(
                          begin: 0.05,
                          end: 0,
                          duration: 400.ms,
                          delay: Duration(milliseconds: 100 + index * 60),
                          curve: Curves.easeOut,
                        );
                  }).toList(),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  'SearchAnyCars v1.0.0',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

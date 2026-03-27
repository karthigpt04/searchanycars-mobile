import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../models/mock_data.dart';
import '../providers/app_provider.dart';
import '../widgets/car/car_card.dart';
import '../widgets/car/car_list_item.dart';
import '../widgets/ui/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  IconData _getTrustIcon(String name) {
    switch (name) {
      case 'shield':
        return LucideIcons.shield;
      case 'check':
        return LucideIcons.checkCircle;
      case 'car':
        return LucideIcons.car;
      case 'phone':
        return LucideIcons.phone;
      default:
        return LucideIcons.star;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredCars = ref.watch(featuredCarsProvider);
    final recentCars = ref.watch(recentCarsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenPadding = screenWidth * 0.055;
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 1. HEADER =====
            Padding(
              padding: EdgeInsets.only(
                top: topPadding,
                left: screenPadding,
                right: screenPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\u{1F4CD} CHENNAI',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              const TextSpan(text: 'Hello, '),
                              TextSpan(
                                text: 'Karthi',
                                style: GoogleFonts.dmSans(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  Stack(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.borderLight,
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.bell,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  // Avatar
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'KM',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.bg,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== 2. SEARCH BAR =====
            Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: screenPadding,
                right: screenPadding,
              ),
              child: GestureDetector(
                onTap: () => context.go('/search'),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Icon(LucideIcons.search, color: AppColors.gold, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Search any car, brand, model...',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.filter,
                          color: AppColors.gold,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
            ),

            // ===== 3. HERO BANNER =====
            Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: screenPadding,
                right: screenPadding,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A1428),
                      Color(0xFF0F1A2E),
                      Color(0xFF0A1520),
                    ],
                  ),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Decorative gradient circle
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withValues(alpha:0.12),
                                AppColors.gold.withValues(alpha:0.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Background car emoji
                      Positioned(
                        bottom: 12,
                        right: 16,
                        child: Opacity(
                          opacity: 0.15,
                          child: Text(
                            '\u{1F697}',
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'LIMITED TIME OFFER',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Zero Down Payment',
                              style: GoogleFonts.dmSans(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drive home your dream car with zero upfront cost. Limited period offer on select models.',
                              style: GoogleFonts.dmSans(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.gold,
                                    AppColors.goldLight,
                                    AppColors.gold,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Explore Offers',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.bg,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(
                                          LucideIcons.arrowRight,
                                          size: 16,
                                          color: AppColors.bg,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== 4. POPULAR BRANDS =====
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: SectionHeader(
                title: 'Popular Brands',
                actionText: 'View All',
                onAction: () {},
              ),
            ),
            SizedBox(
              height: 95,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: screenPadding),
                itemCount: MockData.brands.length,
                itemBuilder: (context, index) {
                  final brand = MockData.brands[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < MockData.brands.length - 1 ? 12 : screenPadding,
                    ),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 76),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.borderLight, width: 1),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha:0.06),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                brand.emoji,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            brand.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 80),
                        duration: const Duration(milliseconds: 400),
                      )
                      .slideY(
                        begin: 0.2,
                        end: 0,
                        delay: Duration(milliseconds: index * 80),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),

            // ===== 5. QUICK STATS =====
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: Row(
                children: [
                  _buildStatCard('10K+', 'Cars Listed'),
                  const SizedBox(width: 10),
                  _buildStatCard('200+', 'Dealers'),
                  const SizedBox(width: 10),
                  _buildStatCard('4.8\u2605', 'Rating'),
                ],
              ),
            ),

            // ===== 6. FEATURED CARS =====
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: SectionHeader(
                title: 'Featured Cars',
                actionText: 'See All',
                onAction: () {},
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: screenPadding),
                itemCount: featuredCars.length,
                itemBuilder: (context, index) {
                  final car = featuredCars[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < featuredCars.length - 1 ? 16 : screenPadding,
                    ),
                    child: SizedBox(
                      width: screenWidth * 0.56,
                      child: CarCard(
                        car: car,
                        onTap: () => context.push('/car/${car.id}'),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                      )
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),

            // ===== 7. RECENTLY ADDED =====
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: SectionHeader(
                title: 'Recently Added',
                actionText: 'View All',
                onAction: () {},
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenPadding),
              child: Column(
                children: List.generate(recentCars.length, (index) {
                  final car = recentCars[index];
                  return CarListItem(
                    car: car,
                    onTap: () => context.push('/car/${car.id}'),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 80),
                        duration: const Duration(milliseconds: 400),
                      )
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: index * 80),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                }),
              ),
            ),

            // ===== 8. TRUST SECTION =====
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
                bottom: 24,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.gold.withValues(alpha:0.06),
                      AppColors.gold.withValues(alpha:0.02),
                    ],
                  ),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why SearchAnyCars?',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(MockData.trustItems.length, (index) {
                      final item = MockData.trustItems[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < MockData.trustItems.length - 1 ? 12 : 0,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getTrustIcon(item['icon']!),
                                size: 16,
                                color: AppColors.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item['text']!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

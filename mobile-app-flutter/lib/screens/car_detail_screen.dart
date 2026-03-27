import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/car.dart';
import '../models/mock_data.dart';
import '../providers/app_provider.dart';

class CarDetailScreen extends ConsumerWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cars = ref.watch(carsProvider);
    final car = cars.firstWhere(
      (c) => c.id == carId,
      orElse: () => MockData.cars.first,
    );
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(car.id);
    final carColor = _parseHex(car.color);
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Main scrollable content
          CustomScrollView(
            slivers: [
              // a) Image Gallery
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  width: screenWidth,
                  child: Stack(
                    children: [
                      // Gradient background
                      Container(
                        width: screenWidth,
                        height: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              carColor.withValues(alpha:0.4),
                              AppColors.bg,
                            ],
                          ),
                        ),
                      ),
                      // Car brand letter placeholder
                      Center(
                        child: Text(
                          car.brand[0],
                          style: GoogleFonts.dmSans(
                            fontSize: 120,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withValues(alpha:0.08),
                          ),
                        ),
                      ),
                      // Back button
                      Positioned(
                        top: topPadding + 10,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xE60A0A0F),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.chevronLeft,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Heart button
                      Positioned(
                        top: topPadding + 10,
                        right: 20,
                        child: GestureDetector(
                          onTap: () {
                            ref
                                .read(wishlistProvider.notifier)
                                .toggle(car.id);
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xE60A0A0F),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : LucideIcons.heart,
                                size: 20,
                                color: isWishlisted
                                    ? AppColors.danger
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Photo count badge
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xE60A0A0F),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.camera,
                                size: 12,
                                color: AppColors.textPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '32 Photos',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Pagination dots
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            final isActive = index == 0;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.gold
                                    : Colors.white.withValues(alpha:0.3),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // b) Scrollable content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 100 + bottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // i) Title area
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // Certified badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    LucideIcons.checkCircle,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Certified',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.1, end: 0),
                            const SizedBox(height: 8),
                            // Car name
                            Text(
                              car.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            )
                                .animate()
                                .fadeIn(
                                  delay: 100.ms,
                                  duration: 400.ms,
                                )
                                .slideY(begin: 0.1, end: 0),
                            const SizedBox(height: 4),
                            Text(
                              '${car.year} Model \u2022 ${car.owner} Owner',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ii) Price card
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gold.withValues(alpha:0.08),
                                AppColors.gold.withValues(alpha:0.02),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha:0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Left - price
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ASKING PRICE',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\u20B9${car.price}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Right - EMI
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'EMI from',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    car.emi,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.05, end: 0),

                      // iii) Specs grid
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: _buildSpecsGrid(car),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.05, end: 0),

                      // iv) Inspection report
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: _buildInspectionReport(car),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 500.ms)
                          .slideY(begin: 0.05, end: 0),

                      // v) Dealer info
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: _buildDealerInfo(car),
                      )
                          .animate()
                          .fadeIn(delay: 500.ms, duration: 500.ms)
                          .slideY(begin: 0.05, end: 0),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // c) Bottom CTA bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withValues(alpha:0.0),
                    AppColors.bg.withValues(alpha:0.95),
                    AppColors.bg,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                16,
                24,
                16,
                bottomPadding + 16,
              ),
              child: Row(
                children: [
                  // Phone button
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha:0.3),
                        width: 1,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.phone,
                        size: 22,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Book Test Drive button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Navigate to booking flow
                      },
                      child: Container(
                        height: 56,
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
                          borderRadius: BorderRadius.circular(18),
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
                            'Book Test Drive',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsGrid(Car car) {
    final specs = [
      _SpecItem(LucideIcons.gauge, car.km, 'Driven'),
      _SpecItem(LucideIcons.fuel, car.fuel, 'Fuel'),
      _SpecItem(LucideIcons.settings2, car.transmission, 'Trans.'),
      _SpecItem(LucideIcons.calendar, car.year.toString(), 'Year'),
      _SpecItem(LucideIcons.user, car.owner, 'Owner'),
      _SpecItem(LucideIcons.mapPin, car.city, 'City'),
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: specs.map((spec) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                spec.icon,
                size: 18,
                color: AppColors.gold,
              ),
              const SizedBox(height: 6),
              Text(
                spec.value,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                spec.label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInspectionReport(Car car) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Inspection Report',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '200-point verified \u2022 Passed',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Score badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    car.inspection.overallScore.toString(),
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bars
          ...car.inspection.categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isLast =
                index == car.inspection.categories.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${category.score}%',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOutCubic,
                            width: constraints.maxWidth *
                                (category.score / 100),
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.success,
                                  Color(0xFF5EEAB4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDealerInfo(Car car) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Dealer avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold,
                  AppColors.goldLight,
                  AppColors.gold,
                ],
              ),
            ),
            child: Center(
              child: Text(
                car.dealer.initial,
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Dealer info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.dealer.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\u2B50 ${car.dealer.rating} \u2022 ${car.dealer.badge} \u2022 ${car.dealer.city}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            LucideIcons.chevronRight,
            size: 20,
            color: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String value;
  final String label;

  const _SpecItem(this.icon, this.value, this.label);
}

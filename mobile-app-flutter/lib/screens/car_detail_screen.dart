import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../models/listing.dart';
import '../providers/app_provider.dart';
import '../providers/config_provider.dart';
import '../repositories/car_repository.dart';
import '../widgets/ui/skeleton_loader.dart';

class CarDetailScreen extends ConsumerStatefulWidget {
  final int carId;

  const CarDetailScreen({super.key, required this.carId});

  @override
  ConsumerState<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends ConsumerState<CarDetailScreen> {
  late PageController _pageController;
  int _currentImagePage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.carId));
    final serverBaseUrl = ref.watch(serverBaseUrlProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: listingAsync.when(
        data: (listing) {
          if (listing == null) {
            return _buildNotFound(topPadding);
          }
          return _buildContent(
            listing,
            serverBaseUrl,
            screenWidth,
            topPadding,
            bottomPadding,
          );
        },
        loading: () => _buildLoadingState(screenWidth, topPadding, bottomPadding),
        error: (error, _) => _buildErrorState(topPadding),
      ),
    );
  }

  Widget _buildContent(
    Listing listing,
    String serverBaseUrl,
    double screenWidth,
    double topPadding,
    double bottomPadding,
  ) {
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(listing.id);
    final imageUrls = listing.imageUrls(serverBaseUrl);
    final imageCount = imageUrls.isNotEmpty ? imageUrls.length : 0;

    return Stack(
      children: [
        // Main scrollable content
        CustomScrollView(
          slivers: [
            // a) Image Gallery with PageView
            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                width: screenWidth,
                child: Stack(
                  children: [
                    // Image PageView or brand initial fallback
                    if (imageCount > 0)
                      PageView.builder(
                        controller: _pageController,
                        itemCount: imageCount,
                        onPageChanged: (index) {
                          setState(() => _currentImagePage = index);
                        },
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: imageUrls[index],
                            fit: BoxFit.cover,
                            width: screenWidth,
                            height: 300,
                            placeholder: (context, url) => Container(
                              width: screenWidth,
                              height: 300,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.bgCardHover,
                                    AppColors.bg,
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  listing.brandInitial,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 80,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildImageFallback(
                              listing,
                              screenWidth,
                            ),
                          );
                        },
                      )
                    else
                      _buildImageFallback(listing, screenWidth),

                    // Top gradient overlay for buttons visibility
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: topPadding + 60,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.bg.withValues(alpha: 0.7),
                              AppColors.bg.withValues(alpha: 0.0),
                            ],
                          ),
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
                              .toggle(listing.id);
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
                    if (imageCount > 0)
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
                                '$imageCount Photo${imageCount != 1 ? 's' : ''}',
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
                    if (imageCount > 1)
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            imageCount.clamp(0, 8),
                            (index) {
                              final isActive = index == _currentImagePage;
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: isActive ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.gold
                                      : Colors.white.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            },
                          ),
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
                          // Certified badge — only if certified
                          if (listing.isCertified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.1),
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
                          if (listing.isCertified) const SizedBox(height: 8),
                          // Car name
                          Text(
                            listing.title,
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
                            '${listing.modelYear ?? 'N/A'} Model \u2022 ${listing.ownerDisplay} Owner',
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
                              AppColors.gold.withValues(alpha: 0.08),
                              AppColors.gold.withValues(alpha: 0.02),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Left - price
                            Expanded(
                              child: Column(
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
                                    listing.priceFormatted,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                  listing.emiFormatted,
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
                      child: _buildSpecsGrid(listing),
                    )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 500.ms)
                        .slideY(begin: 0.05, end: 0),

                    // iv) Inspection report
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildInspectionReport(listing),
                    )
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.05, end: 0),

                    // v) Dealer info
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: _buildDealerInfo(listing),
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
                  AppColors.bg.withValues(alpha: 0.0),
                  AppColors.bg.withValues(alpha: 0.95),
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
                GestureDetector(
                  onTap: () => _handlePhoneCall(context, ref),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
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
                ),
                const SizedBox(width: 14),
                // Book Test Drive button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/book-test-drive/${widget.carId}');
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
                            color: AppColors.gold.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildImageFallback(Listing listing, double screenWidth) {
    return Container(
      width: screenWidth,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bgCardHover.withValues(alpha: 0.6),
            AppColors.bg,
          ],
        ),
      ),
      child: Center(
        child: Text(
          listing.brandInitial,
          style: GoogleFonts.dmSans(
            fontSize: 120,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsGrid(Listing listing) {
    final specs = [
      _SpecItem(LucideIcons.gauge, listing.kmCompact, 'Driven'),
      _SpecItem(LucideIcons.fuel, listing.fuelType ?? 'N/A', 'Fuel'),
      _SpecItem(
          LucideIcons.settings2, listing.transmissionType ?? 'N/A', 'Trans.'),
      _SpecItem(
          LucideIcons.calendar, (listing.modelYear ?? 'N/A').toString(), 'Year'),
      _SpecItem(LucideIcons.user, listing.ownerDisplay, 'Owner'),
      _SpecItem(LucideIcons.mapPin, listing.locationCity ?? 'N/A', 'City'),
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

  Widget _buildInspectionReport(Listing listing) {
    final score = listing.inspectionScore ?? 85;
    final categories = [
      {'name': 'Engine & Transmission', 'score': (score * 1.02).clamp(0, 100)},
      {'name': 'Exterior & Body', 'score': (score * 0.95).clamp(0, 100)},
      {'name': 'Interior & Electronics', 'score': (score * 0.98).clamp(0, 100)},
      {'name': 'Tyres & Suspension', 'score': (score * 0.93).clamp(0, 100)},
    ];

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
                      '200-point verified \u2022 ${listing.isCertified ? 'Passed' : 'Pending'}',
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
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    score.round().toString(),
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
          ...categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final catScore = (category['score'] as num).toDouble();
            final isLast = index == categories.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Text(
                        '${catScore.round()}%',
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
                            width: constraints.maxWidth * (catScore / 100),
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

  Widget _buildDealerInfo(Listing listing) {
    final sellerType = listing.sellerType ?? 'Dealer';
    final dealerInitial = sellerType.isNotEmpty ? sellerType[0] : 'D';
    final dealerRating = listing.dealerRating ?? 4.5;
    final city = listing.locationCity ?? 'N/A';

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
                dealerInitial,
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
                  sellerType,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\u2B50 ${dealerRating.toStringAsFixed(1)} \u2022 Trusted Dealer \u2022 $city',
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

  Widget _buildLoadingState(
    double screenWidth,
    double topPadding,
    double bottomPadding,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gallery skeleton
                  SkeletonLoader(
                    width: screenWidth,
                    height: 300,
                    borderRadius: 0,
                  ),
                  const SizedBox(height: 20),
                  // Title skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoader(width: 80, height: 24, borderRadius: 8),
                        const SizedBox(height: 10),
                        SkeletonLoader(
                            width: screenWidth * 0.7,
                            height: 26,
                            borderRadius: 8),
                        const SizedBox(height: 6),
                        SkeletonLoader(
                            width: screenWidth * 0.4,
                            height: 16,
                            borderRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Price card skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 90,
                      borderRadius: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Specs grid skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 200,
                      borderRadius: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Inspection skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: SkeletonLoader(
                      width: double.infinity,
                      height: 220,
                      borderRadius: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Back button on loading state
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
      ],
    );
  }

  Widget _buildNotFound(double topPadding) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.car,
                size: 56,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Car not found',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This listing may have been removed',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: topPadding + 10,
          left: 20,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
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
      ],
    );
  }

  void _handlePhoneCall(BuildContext context, WidgetRef ref) async {
    final siteConfigAsync = ref.read(siteConfigProvider);
    String phoneNumber = '+919876543210'; // Default fallback

    siteConfigAsync.whenData((config) {
      if (config.contactInfo?.phone != null && config.contactInfo!.phone!.isNotEmpty) {
        phoneNumber = config.contactInfo!.phone!;
      }
    });

    final uri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Call $phoneNumber',
                style: GoogleFonts.dmSans(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.bgCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Call $phoneNumber',
              style: GoogleFonts.dmSans(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Widget _buildErrorState(double topPadding) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.wifiOff,
                size: 56,
                color: AppColors.textMuted.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Unable to load details',
                style: GoogleFonts.dmSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your connection and try again',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () =>
                    ref.invalidate(listingDetailProvider(widget.carId)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Retry',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: topPadding + 10,
          left: 20,
          child: GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
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
      ],
    );
  }
}

class _SpecItem {
  final IconData icon;
  final String value;
  final String label;

  const _SpecItem(this.icon, this.value, this.label);
}

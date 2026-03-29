import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../models/brand.dart';
import '../models/listing.dart';
import '../models/mock_data.dart';
import '../providers/auth_provider.dart';
import '../providers/config_provider.dart';
import '../repositories/car_repository.dart';
import '../services/mock/mock_car_service.dart';
import '../utils/listing_helpers.dart';
import '../widgets/car/car_card.dart';
import '../widgets/car/car_list_item.dart';
import '../widgets/layout/offline_banner.dart';
import '../widgets/ui/section_header.dart';
import '../widgets/ui/skeleton_loader.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  IconData _getTrustIcon(String name) {
    switch (name.toLowerCase()) {
      case 'shield':
        return LucideIcons.shield;
      case 'check':
      case 'checkcircle':
        return LucideIcons.checkCircle;
      case 'car':
        return LucideIcons.car;
      case 'phone':
        return LucideIcons.phone;
      case 'star':
        return LucideIcons.star;
      case 'clock':
        return LucideIcons.clock;
      case 'award':
        return LucideIcons.award;
      case 'thumbsup':
        return LucideIcons.thumbsUp;
      default:
        return LucideIcons.star;
    }
  }

  /// Derive unique brands with counts from a list of listings.
  List<Brand> _deriveBrands(List<Listing> listings) {
    final brandCounts = <String, int>{};
    for (final l in listings) {
      if (l.brand.isNotEmpty) {
        brandCounts[l.brand] = (brandCounts[l.brand] ?? 0) + 1;
      }
    }
    if (brandCounts.isEmpty) return MockData.brands;

    const brandEmojis = {
      'Mercedes': '\u2B50',
      'Mercedes-Benz': '\u2B50',
      'BMW': '\uD83D\uDD35',
      'Audi': '\uD83D\uDD18',
      'Toyota': '\uD83D\uDD34',
      'Hyundai': '\uD83C\uDD77',
      'Tata': '\uD83C\uDDF9',
      'Kia': '\uD83C\uDD7A',
      'Mahindra': '\uD83C\uDD7C',
      'Honda': '\uD83D\uDD34',
      'Maruti': '\uD83D\uDD37',
      'Maruti Suzuki': '\uD83D\uDD37',
      'Volkswagen': '\uD83D\uDD35',
      'Ford': '\uD83D\uDD35',
      'Renault': '\uD83D\uDFE1',
      'Skoda': '\uD83D\uDFE2',
      'MG': '\uD83D\uDD34',
      'Nissan': '\uD83D\uDD34',
    };

    final sorted = brandCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(8).map((e) {
      return Brand(
        name: e.key,
        emoji: brandEmojis[e.key] ?? '\uD83D\uDE97',
        count: e.value,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final siteConfigAsync = ref.watch(siteConfigProvider);
    final featuredAsync = ref.watch(featuredListingsProvider);
    final recentAsync = ref.watch(recentListingsProvider);
    final allListingsAsync = ref.watch(allListingsProvider);
    final splusAsync = ref.watch(splusListingsProvider);
    final splusNewAsync = ref.watch(splusNewListingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenPadding = screenWidth * 0.055;
    final topPadding = MediaQuery.of(context).padding.top + 12;

    // Derive display values from auth state
    final userName = auth.isAuthenticated
        ? auth.user!.displayName
        : 'Guest';
    final userInitials = auth.isAuthenticated
        ? auth.user!.initials
        : 'G';

    // Derive location from site config
    final locationText = siteConfigAsync.whenOrNull(
      data: (config) {
        if (config.cities.isNotEmpty) return config.cities.first.name.toUpperCase();
        return null;
      },
    ) ?? 'INDIA';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: RefreshIndicator(
        color: AppColors.gold,
        backgroundColor: AppColors.bgCard,
        onRefresh: () async {
          // Invalidate all data providers to force re-fetch
          ref.invalidate(featuredListingsProvider);
          ref.invalidate(recentListingsProvider);
          ref.invalidate(allListingsProvider);
          ref.invalidate(splusListingsProvider);
          ref.invalidate(splusNewListingsProvider);
          ref.invalidate(siteConfigProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
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
                            '\uD83D\uDCCD $locationText',
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
                                  text: userName,
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
                          userInitials,
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

              // ===== OFFLINE BANNER =====
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: OfflineBanner(),
              ),

              // ===== 2. SEARCH BAR =====
              Padding(
                padding: EdgeInsets.only(
                  top: 12,
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
                            color: AppColors.gold.withValues(alpha: 0.1),
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
              _buildHeroBanner(context, ref, screenPadding, siteConfigAsync),

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
                  onAction: () => context.go('/search'),
                ),
              ),
              _buildBrandsSection(allListingsAsync, screenPadding, context),

              // ===== 5. QUICK STATS =====
              Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: screenPadding,
                  right: screenPadding,
                ),
                child: allListingsAsync.when(
                  data: (listings) {
                    final totalCars = listings.length;
                    final uniqueDealers = listings
                        .map((l) => l.sellerType)
                        .where((s) => s != null)
                        .toSet()
                        .length;
                    return Row(
                      children: [
                        _buildStatCard(
                          totalCars > 0 ? '$totalCars+' : '10K+',
                          'Cars Listed',
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard(
                          uniqueDealers > 0 ? '$uniqueDealers+' : '200+',
                          'Dealers',
                        ),
                        const SizedBox(width: 10),
                        _buildStatCard('4.8\u2605', 'Rating'),
                      ],
                    );
                  },
                  loading: () => Row(
                    children: [
                      _buildStatCard('10K+', 'Cars Listed'),
                      const SizedBox(width: 10),
                      _buildStatCard('200+', 'Dealers'),
                      const SizedBox(width: 10),
                      _buildStatCard('4.8\u2605', 'Rating'),
                    ],
                  ),
                  error: (e, s) => Row(
                    children: [
                      _buildStatCard('10K+', 'Cars Listed'),
                      const SizedBox(width: 10),
                      _buildStatCard('200+', 'Dealers'),
                      const SizedBox(width: 10),
                      _buildStatCard('4.8\u2605', 'Rating'),
                    ],
                  ),
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
                  onAction: () => context.go('/search'),
                ),
              ),
              _buildFeaturedSection(featuredAsync, screenWidth, screenPadding, context),

              // ===== S+ PREMIUM SECTION (guaranteed visible) =====
              _buildGuaranteedSplusSection(splusAsync, screenWidth, screenPadding, context, ref),

              // ===== S+ NEW CARS SECTION (guaranteed visible) =====
              _buildGuaranteedSplusNewSection(splusNewAsync, screenWidth, screenPadding, context, ref),

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
                  onAction: () => context.go('/search'),
                ),
              ),
              _buildRecentSection(recentAsync, screenPadding, context),

              // ===== 8. TRUST SECTION =====
              _buildTrustSection(siteConfigAsync, screenPadding),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // HERO BANNER
  // ─────────────────────────────────────────────────────────
  Widget _buildHeroBanner(
    BuildContext context,
    WidgetRef ref,
    double screenPadding,
    AsyncValue<dynamic> siteConfigAsync,
  ) {
    // Extract hero text from site config, with fallbacks
    String heroLabel = 'LIMITED TIME OFFER';
    String heroTitle = 'Zero Down Payment';
    String heroSubtitle =
        'Drive home your dream car with zero upfront cost. Limited period offer on select models.';

    siteConfigAsync.whenData((config) {
      if (config.hero != null) {
        if (config.hero!.title.isNotEmpty) heroTitle = config.hero!.title;
        if (config.hero!.subtitle.isNotEmpty) heroSubtitle = config.hero!.subtitle;
      }
    });

    return Padding(
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
                        AppColors.gold.withValues(alpha: 0.12),
                        AppColors.gold.withValues(alpha: 0.0),
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
                    '\uD83D\uDE97',
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
                      heroLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      heroTitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      heroSubtitle,
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
                          onTap: () => context.go('/search'),
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
    );
  }

  // ─────────────────────────────────────────────────────────
  // POPULAR BRANDS
  // ─────────────────────────────────────────────────────────
  Widget _buildBrandsSection(
    AsyncValue<List<Listing>> allListingsAsync,
    double screenPadding,
    BuildContext context,
  ) {
    return allListingsAsync.when(
      data: (listings) {
        final brands = _deriveBrands(listings);
        return _buildBrandsList(brands, screenPadding, context);
      },
      loading: () => SizedBox(
        height: 95,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: screenPadding),
          itemCount: 6,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              right: index < 5 ? 12 : screenPadding,
            ),
            child: const SkeletonLoader(width: 76, height: 95, borderRadius: 18),
          ),
        ),
      ),
      error: (e, s) => _buildBrandsList(MockData.brands, screenPadding, context),
    );
  }

  Widget _buildBrandsList(
    List<Brand> brands,
    double screenPadding,
    BuildContext context,
  ) {
    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: screenPadding),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < brands.length - 1 ? 12 : screenPadding,
            ),
            child: GestureDetector(
              onTap: () => context.go('/search'),
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
                        color: AppColors.gold.withValues(alpha: 0.06),
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
    );
  }

  // ─────────────────────────────────────────────────────────
  // FEATURED CARS
  // ─────────────────────────────────────────────────────────
  Widget _buildFeaturedSection(
    AsyncValue<List<Listing>> featuredAsync,
    double screenWidth,
    double screenPadding,
    BuildContext context,
  ) {
    return featuredAsync.when(
      data: (listings) {
        if (listings.isEmpty) {
          return _buildEmptySection('No featured cars yet');
        }
        final cars = listings.map(listingToCar).toList();
        return SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < cars.length - 1 ? 16 : screenPadding,
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
        );
      },
      loading: () => SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: screenPadding),
          itemCount: 3,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(
              right: index < 2 ? 16 : screenPadding,
            ),
            child: SkeletonLoader(
              width: screenWidth * 0.56,
              height: 240,
              borderRadius: 20,
            ),
          ),
        ),
      ),
      error: (e, s) {
        // Fallback to mock data on error
        final mockCars = MockData.cars.take(4).toList();
        return SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: mockCars.length,
            itemBuilder: (context, index) {
              final car = mockCars[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < mockCars.length - 1 ? 16 : screenPadding,
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
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // S+ PREMIUM SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildSplusSection(
    AsyncValue<List<Listing>> splusAsync,
    double screenWidth,
    double screenPadding,
    BuildContext context,
    WidgetRef ref,
  ) {
    return splusAsync.when(
      data: (listings) {
        if (listings.isEmpty) return const SizedBox.shrink();
        final serverBaseUrl = ref.watch(serverBaseUrlProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: SectionHeader(
                title: 'S+ Premium',
                actionText: 'Explore',
                onAction: () => context.go('/search'),
              ),
            ),
            SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: screenPadding),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  final imageUrls = listing.imageUrls(serverBaseUrl);
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < listings.length - 1 ? 16 : screenPadding,
                    ),
                    child: GestureDetector(
                      onTap: () => context.push('/car/${listing.id}'),
                      child: Container(
                        width: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gold.withValues(alpha: 0.08),
                              const Color(0xFF1A1428),
                              const Color(0xFF141420),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image area with S+ badge
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: SizedBox(
                                height: 130,
                                width: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (imageUrls.isNotEmpty)
                                      CachedNetworkImage(
                                        imageUrl: imageUrls.first,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.gold.withValues(alpha: 0.15),
                                                AppColors.bgCard,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              listing.brandInitial,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.gold.withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.gold.withValues(alpha: 0.15),
                                                AppColors.bgCard,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              listing.brandInitial,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.gold.withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.gold.withValues(alpha: 0.15),
                                              AppColors.bgCard,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            listing.brandInitial,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.gold.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Gradient overlay at bottom of image
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 40,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color(0xFF141420).withValues(alpha: 0.9),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // S+ badge
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [AppColors.gold, AppColors.goldLight],
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.gold.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          'S+',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.bg,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Title
                                    Text(
                                      listing.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    // Price
                                    Text(
                                      listing.priceFormatted,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    // Tags
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.shield,
                                          size: 11,
                                          color: AppColors.gold.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '300-Point Inspection  \u2022  2-Year Warranty',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.gold.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Location
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.mapPin,
                                          size: 11,
                                          color: AppColors.textMuted,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          listing.locationCity ?? 'N/A',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                      )
                      .slideX(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: screenPadding,
              right: screenPadding,
            ),
            child: SectionHeader(
              title: 'S+ Premium',
              actionText: 'Explore',
              onAction: () => context.go('/search'),
            ),
          ),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: screenPadding),
              itemCount: 2,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  right: index < 1 ? 16 : screenPadding,
                ),
                child: const SkeletonLoader(
                  width: 260,
                  height: 250,
                  borderRadius: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      error: (e, s) {
        // Fallback: show mock S+ data on error
        final mockSplus = MockCarService.mockListings
            .where((l) => l.isSplus && !l.isNewCar)
            .toList();
        if (mockSplus.isEmpty) return const SizedBox.shrink();
        final serverBaseUrl = ref.watch(serverBaseUrlProvider);
        return _buildSplusCards(mockSplus, serverBaseUrl, screenWidth, screenPadding, context);
      },
    );
  }

  Widget _buildSplusCards(List<Listing> listings, String serverBaseUrl, double screenWidth, double screenPadding, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24, left: screenPadding, right: screenPadding),
          child: SectionHeader(title: 'S+ Premium', actionText: 'Explore', onAction: () => context.go('/search')),
        ),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final imageUrls = listing.imageUrls(serverBaseUrl);
              return Padding(
                padding: EdgeInsets.only(right: index < listings.length - 1 ? 16 : screenPadding),
                child: GestureDetector(
                  onTap: () => context.push('/car/${listing.id}'),
                  child: Container(
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.gold.withValues(alpha: 0.08), const Color(0xFF1A1428), const Color(0xFF141420)]),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image area
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 130,
                            width: 260,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  CachedNetworkImage(imageUrl: imageUrls.first, fit: BoxFit.cover, errorWidget: (c, u, e) => _brandInitialFallback(listing))
                                else
                                  _brandInitialFallback(listing),
                                Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)), child: Text('S+', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.bg)))),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(listing.title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(listing.priceFormatted, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
                            const SizedBox(height: 8),
                            Row(children: [Icon(LucideIcons.shield, size: 12, color: AppColors.gold.withValues(alpha: 0.7)), const SizedBox(width: 4), Text('300-Point Inspection \u2022 2-Year Warranty', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary))]),
                            const SizedBox(height: 4),
                            Row(children: [Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted), const SizedBox(width: 4), Text(listing.locationCity ?? 'India', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted))]),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _brandInitialFallback(Listing listing) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.bgCardHover, AppColors.bgCard])),
      child: Center(child: Text(listing.brandInitial, style: GoogleFonts.dmSans(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.08)))),
    );
  }

  // ─────────────────────────────────────────────────────────
  // S+ NEW CARS SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildSplusNewSection(
    AsyncValue<List<Listing>> splusNewAsync,
    double screenWidth,
    double screenPadding,
    BuildContext context,
    WidgetRef ref,
  ) {
    return splusNewAsync.when(
      data: (listings) {
        if (listings.isEmpty) return const SizedBox.shrink();
        final serverBaseUrl = ref.watch(serverBaseUrlProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: screenPadding,
                right: screenPadding,
              ),
              child: SectionHeader(
                title: 'S+ New Cars',
                actionText: 'View All',
                onAction: () => context.go('/search'),
              ),
            ),
            SizedBox(
              height: 290,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(left: screenPadding),
                itemCount: listings.length,
                itemBuilder: (context, index) {
                  final listing = listings[index];
                  final imageUrls = listing.imageUrls(serverBaseUrl);
                  final carType = listing.newCarType ?? 'New';
                  // Build engine spec string
                  final specParts = <String>[];
                  if (listing.engineType != null && listing.engineType!.isNotEmpty) {
                    specParts.add(listing.engineType!);
                  }
                  if (listing.powerBhp != null) {
                    specParts.add('${listing.powerBhp!.round()} bhp');
                  }
                  if (listing.transmissionType != null) {
                    specParts.add(listing.transmissionType!);
                  }
                  final engineSpec = specParts.join(' \u2022 ');

                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < listings.length - 1 ? 16 : screenPadding,
                    ),
                    child: GestureDetector(
                      onTap: () => context.push('/car/${listing.id}'),
                      child: Container(
                        width: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.success.withValues(alpha: 0.06),
                              const Color(0xFF0F1A1A),
                              const Color(0xFF141420),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.15),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image area with badges
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                              child: SizedBox(
                                height: 140,
                                width: double.infinity,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (imageUrls.isNotEmpty)
                                      CachedNetworkImage(
                                        imageUrl: imageUrls.first,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.success.withValues(alpha: 0.1),
                                                AppColors.bgCard,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              listing.brandInitial,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.success.withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppColors.success.withValues(alpha: 0.1),
                                                AppColors.bgCard,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              listing.brandInitial,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 32,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.success.withValues(alpha: 0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.success.withValues(alpha: 0.1),
                                              AppColors.bgCard,
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            listing.brandInitial,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 32,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.success.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Gradient overlay at bottom of image
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      height: 40,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              const Color(0xFF141420).withValues(alpha: 0.9),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Car type badge (top-left)
                                    Positioned(
                                      top: 10,
                                      left: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.9),
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.success.withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          carType,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.bg,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // NEW badge (top-right)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.bg.withValues(alpha: 0.7),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppColors.success.withValues(alpha: 0.4),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          'NEW',
                                          style: GoogleFonts.dmSans(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.success,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Content
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Title
                                    Text(
                                      listing.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    // Price
                                    Text(
                                      listing.priceFormatted,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    // Tags
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.checkCircle,
                                          size: 11,
                                          color: AppColors.success.withValues(alpha: 0.7),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'Factory Fresh  \u2022  Full Warranty  \u2022  0 km',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.success.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Engine specs
                                    if (engineSpec.isNotEmpty)
                                      Row(
                                        children: [
                                          Icon(
                                            LucideIcons.gauge,
                                            size: 11,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              engineSpec,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.dmSans(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      const SizedBox.shrink(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                      )
                      .slideX(
                        begin: 0.15,
                        end: 0,
                        delay: Duration(milliseconds: index * 100),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                      );
                },
              ),
            ),
          ],
        );
      },
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24,
              left: screenPadding,
              right: screenPadding,
            ),
            child: SectionHeader(
              title: 'S+ New Cars',
              actionText: 'View All',
              onAction: () => context.go('/search'),
            ),
          ),
          SizedBox(
            height: 290,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: screenPadding),
              itemCount: 2,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  right: index < 1 ? 16 : screenPadding,
                ),
                child: const SkeletonLoader(
                  width: 280,
                  height: 280,
                  borderRadius: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      error: (e, s) {
        // Fallback: show mock new car data on error
        final mockNew = MockCarService.mockListings
            .where((l) => l.isNewCar)
            .toList();
        if (mockNew.isEmpty) return const SizedBox.shrink();
        final serverBaseUrl = ref.watch(serverBaseUrlProvider);
        return _buildSplusNewCards(mockNew, serverBaseUrl, screenWidth, screenPadding, context);
      },
    );
  }

  Widget _buildSplusNewCards(List<Listing> listings, String serverBaseUrl, double screenWidth, double screenPadding, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24, left: screenPadding, right: screenPadding),
          child: SectionHeader(title: 'S+ New Cars', actionText: 'View All', onAction: () => context.go('/search')),
        ),
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final imageUrls = listing.imageUrls(serverBaseUrl);
              return Padding(
                padding: EdgeInsets.only(right: index < listings.length - 1 ? 16 : screenPadding),
                child: GestureDetector(
                  onTap: () => context.push('/car/${listing.id}'),
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.success.withValues(alpha: 0.06), const Color(0xFF0F1A1A), const Color(0xFF141420)]),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.15), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 140,
                            width: 280,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  CachedNetworkImage(imageUrl: imageUrls.first, fit: BoxFit.cover, errorWidget: (c, u, e) => _brandInitialFallback(listing))
                                else
                                  _brandInitialFallback(listing),
                                Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)), child: Text(listing.newCarType ?? 'New', style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.bg)))),
                                Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(border: Border.all(color: AppColors.success, width: 1), borderRadius: BorderRadius.circular(8)), child: Text('NEW', style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)))),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(listing.title, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 6),
                            Text(listing.priceFormatted, style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold)),
                            const SizedBox(height: 8),
                            Row(children: [Icon(LucideIcons.checkCircle, size: 12, color: AppColors.success.withValues(alpha: 0.7)), const SizedBox(width: 4), Text('Factory Fresh \u2022 Full Warranty \u2022 0 km', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary))]),
                            const SizedBox(height: 4),
                            if (listing.engineType != null)
                              Row(children: [Icon(LucideIcons.gauge, size: 12, color: AppColors.textMuted), const SizedBox(width: 4), Expanded(child: Text('${listing.engineType} \u2022 ${listing.powerBhp?.round() ?? ''}bhp \u2022 ${listing.transmissionType ?? ''}', style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // RECENTLY ADDED
  // ─────────────────────────────────────────────────────────
  Widget _buildRecentSection(
    AsyncValue<List<Listing>> recentAsync,
    double screenPadding,
    BuildContext context,
  ) {
    return recentAsync.when(
      data: (listings) {
        if (listings.isEmpty) {
          return _buildEmptySection('No recent listings');
        }
        final cars = listings.map(listingToCar).toList();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenPadding),
          child: Column(
            children: List.generate(cars.length, (index) {
              final car = cars[index];
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
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(horizontal: screenPadding),
        child: Column(
          children: List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SkeletonLoader(
                width: double.infinity,
                height: 100,
                borderRadius: 18,
              ),
            ),
          ),
        ),
      ),
      error: (e, s) {
        // Fallback to mock data on error
        final mockCars = MockData.cars.skip(4).toList();
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: screenPadding),
          child: Column(
            children: List.generate(mockCars.length, (index) {
              final car = mockCars[index];
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
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────
  // TRUST SECTION
  // ─────────────────────────────────────────────────────────
  Widget _buildTrustSection(
    AsyncValue<dynamic> siteConfigAsync,
    double screenPadding,
  ) {
    // Build trust items from site config or fallback to MockData
    List<Map<String, String>> trustItems = MockData.trustItems;

    siteConfigAsync.whenData((config) {
      if (config.trustBar.isNotEmpty) {
        trustItems = config.trustBar.map<Map<String, String>>((item) {
          return {
            'icon': item.icon,
            'text': item.label,
          };
        }).toList();
      }
    });

    return Padding(
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
              AppColors.gold.withValues(alpha: 0.06),
              AppColors.gold.withValues(alpha: 0.02),
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
            ...List.generate(trustItems.length, (index) {
              final item = trustItems[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < trustItems.length - 1 ? 12 : 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getTrustIcon(item['icon'] ?? 'star'),
                        size: 16,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['text'] ?? '',
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
    );
  }

  // ─────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────
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

  Widget _buildEmptySection(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.car, size: 32, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // GUARANTEED S+ PREMIUM (always shows — mock fallback)
  // ─────────────────────────────────────────────────────────
  Widget _buildGuaranteedSplusSection(
    AsyncValue<List<Listing>> splusAsync,
    double screenWidth,
    double screenPadding,
    BuildContext context,
    WidgetRef ref,
  ) {
    // Always have data: use provider if loaded, otherwise mock
    final providerData = splusAsync.valueOrNull;
    final listings = (providerData != null && providerData.isNotEmpty)
        ? providerData
        : MockCarService.mockListings
            .where((l) => l.isSplus && !l.isNewCar)
            .toList();
    if (listings.isEmpty) return const SizedBox.shrink();

    final serverBaseUrl = ref.watch(serverBaseUrlProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24, left: screenPadding, right: screenPadding),
          child: SectionHeader(
            title: 'S+ Premium',
            actionText: 'Explore',
            onAction: () => context.go('/search'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final imageUrls = listing.imageUrls(serverBaseUrl);
              return Padding(
                padding: EdgeInsets.only(right: index < listings.length - 1 ? 16 : screenPadding),
                child: GestureDetector(
                  onTap: () => context.push('/car/${listing.id}'),
                  child: Container(
                    width: 260,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.gold.withValues(alpha: 0.08),
                          const Color(0xFF1A1428),
                          AppColors.bgCard,
                        ],
                      ),
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 130,
                            width: 260,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorWidget: (ctx, url, err) => _splusFallbackImage(listing),
                                  )
                                else
                                  _splusFallbackImage(listing),
                                // S+ Badge
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'S+',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.bg,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.title,
                                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                listing.priceFormatted,
                                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(LucideIcons.shield, size: 12, color: AppColors.gold.withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '300-Point Inspection \u2022 2-Year Warranty',
                                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    listing.locationCity ?? 'India',
                                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: index * 100),
                    duration: const Duration(milliseconds: 500),
                  ).slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: index * 100));
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // GUARANTEED S+ NEW CARS (always shows — mock fallback)
  // ─────────────────────────────────────────────────────────
  Widget _buildGuaranteedSplusNewSection(
    AsyncValue<List<Listing>> splusNewAsync,
    double screenWidth,
    double screenPadding,
    BuildContext context,
    WidgetRef ref,
  ) {
    final providerData = splusNewAsync.valueOrNull;
    final listings = (providerData != null && providerData.isNotEmpty)
        ? providerData
        : MockCarService.mockListings
            .where((l) => l.isNewCar)
            .toList();
    if (listings.isEmpty) return const SizedBox.shrink();

    final serverBaseUrl = ref.watch(serverBaseUrlProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 24, left: screenPadding, right: screenPadding),
          child: SectionHeader(
            title: 'S+ New Cars',
            actionText: 'View All',
            onAction: () => context.go('/search'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: screenPadding),
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              final imageUrls = listing.imageUrls(serverBaseUrl);
              return Padding(
                padding: EdgeInsets.only(right: index < listings.length - 1 ? 16 : screenPadding),
                child: GestureDetector(
                  onTap: () => context.push('/car/${listing.id}'),
                  child: Container(
                    width: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.success.withValues(alpha: 0.06),
                          const Color(0xFF0F1A1A),
                          AppColors.bgCard,
                        ],
                      ),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: SizedBox(
                            height: 140,
                            width: 280,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (imageUrls.isNotEmpty)
                                  CachedNetworkImage(
                                    imageUrl: imageUrls.first,
                                    fit: BoxFit.cover,
                                    errorWidget: (ctx, url, err) => _splusFallbackImage(listing),
                                  )
                                else
                                  _splusFallbackImage(listing),
                                // Car type badge
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      listing.newCarType ?? 'New',
                                      style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.bg),
                                    ),
                                  ),
                                ),
                                // NEW badge
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppColors.success),
                                      borderRadius: BorderRadius.circular(8),
                                      color: AppColors.bg.withValues(alpha: 0.7),
                                    ),
                                    child: Text(
                                      'NEW',
                                      style: GoogleFonts.dmSans(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Info
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                listing.title,
                                style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                listing.priceFormatted,
                                style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.gold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(LucideIcons.checkCircle, size: 12, color: AppColors.success.withValues(alpha: 0.7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Factory Fresh \u2022 Full Warranty \u2022 0 km',
                                    style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              if (listing.engineType != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.gauge, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${listing.engineType} \u2022 ${listing.powerBhp?.round() ?? ''}bhp \u2022 ${listing.transmissionType ?? ''}',
                                        style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(
                    delay: Duration(milliseconds: index * 100),
                    duration: const Duration(milliseconds: 500),
                  ).slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: index * 100));
            },
          ),
        ),
      ],
    );
  }

  Widget _splusFallbackImage(Listing listing) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgCardHover, AppColors.bgCard],
        ),
      ),
      child: Center(
        child: Text(
          listing.brandInitial,
          style: GoogleFonts.dmSans(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}

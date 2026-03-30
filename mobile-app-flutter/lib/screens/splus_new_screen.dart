import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/listing.dart';
import '../repositories/car_repository.dart';
import '../services/mock/mock_car_service.dart';
import '../widgets/ui/skeleton_loader.dart';

class SplusNewScreen extends ConsumerWidget {
  const SplusNewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final splusNewAsync = ref.watch(splusNewListingsProvider);
    final serverBaseUrl = ref.watch(serverBaseUrlProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.success, Color(0xFF2DD4BF)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'NEW',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.bg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'S+ New Cars',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 4),
              child: Text(
                'Brand new & unregistered vehicles',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: splusNewAsync.when(
                data: (listings) {
                  final items = listings.isNotEmpty
                      ? listings
                      : MockCarService.mockListings
                          .where((l) => l.isNewCar)
                          .toList();
                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildList(context, items, serverBaseUrl);
                },
                loading: () => _buildSkeletons(),
                error: (e, st) {
                  final fallback = MockCarService.mockListings
                      .where((l) => l.isNewCar)
                      .toList();
                  if (fallback.isEmpty) return _buildEmptyState();
                  return _buildList(context, fallback, serverBaseUrl);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<Listing> listings, String serverBaseUrl) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final imageUrls = listing.imageUrls(serverBaseUrl);
        final carType = listing.newCarType ?? 'New';

        return GestureDetector(
          onTap: () => context.push('/car/${listing.id}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withValues(alpha: 0.06),
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
                    height: 180,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrls.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: imageUrls.first,
                            fit: BoxFit.cover,
                            errorWidget: (ctx, url, err) => _fallbackImage(listing),
                          )
                        else
                          _fallbackImage(listing),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              carType,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.bg,
                              ),
                            ),
                          ),
                        ),
                        // 0 km badge
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.bg.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '0 KM',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            listing.priceFormatted,
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            listing.emiFormatted,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Engine specs
                      if (listing.engineType != null || listing.powerBhp != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            [
                              if (listing.engineType != null) listing.engineType!,
                              if (listing.powerBhp != null) '${listing.powerBhp!.round()} bhp',
                              if (listing.transmissionType != null) listing.transmissionType!,
                            ].join(' \u2022 '),
                            style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ),
                      Row(
                        children: [
                          Icon(LucideIcons.sparkles, size: 12, color: AppColors.success.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            'Brand New \u2022 Full Warranty',
                            style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textSecondary),
                          ),
                          const Spacer(),
                          Icon(LucideIcons.mapPin, size: 12, color: AppColors.textMuted),
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
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: index.clamp(0, 8) * 80),
              duration: const Duration(milliseconds: 400),
            )
            .slideY(
              begin: 0.1,
              end: 0,
              delay: Duration(milliseconds: index.clamp(0, 8) * 80),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _fallbackImage(Listing listing) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No new cars yet',
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for brand new listings',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      itemCount: 3,
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SkeletonLoader(width: double.infinity, height: 280, borderRadius: 20),
      ),
    );
  }
}

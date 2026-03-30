import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../models/listing.dart';
import '../repositories/car_repository.dart';
import '../utils/listing_helpers.dart';
import '../widgets/car/car_list_item.dart';
import '../widgets/ui/skeleton_loader.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final wishlistedListingsAsync = ref.watch(wishlistedListingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wishlist',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${wishlistIds.length} saved cars',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content — AsyncValue pattern
            Expanded(
              child: wishlistedListingsAsync.when(
                data: (listings) => _buildListContent(context, ref, listings),
                loading: () => _buildSkeletonList(),
                error: (error, _) => _buildErrorState(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(
      BuildContext context, WidgetRef ref, List<Listing> listings) {
    if (listings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 100,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        final serverBaseUrl = ref.watch(serverBaseUrlProvider);
        final car = listingToCar(listing, serverBaseUrl: serverBaseUrl);
        return CarListItem(
          car: car,
          onTap: () => context.push('/car/${car.id}'),
        )
            .animate()
            .fadeIn(
              duration: 400.ms,
              delay: Duration(milliseconds: index * 80),
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 400.ms,
              delay: Duration(milliseconds: index * 80),
              curve: Curves.easeOut,
            );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u{1F49B}',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved cars yet',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the heart icon on cars you love',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 100,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              const SkeletonLoader(
                width: 110,
                height: 85,
                borderRadius: 14,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(width: 160, height: 16, borderRadius: 8),
                    SizedBox(height: 8),
                    SkeletonLoader(width: 100, height: 14, borderRadius: 8),
                    SizedBox(height: 8),
                    SkeletonLoader(width: 80, height: 14, borderRadius: 8),
                  ],
                ),
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: index * 60),
            );
      },
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '\u{1F49B}',
            style: TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load wishlist',
            style: GoogleFonts.dmSans(
              fontSize: 18,
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
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => ref.invalidate(wishlistedListingsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.2),
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
    );
  }
}

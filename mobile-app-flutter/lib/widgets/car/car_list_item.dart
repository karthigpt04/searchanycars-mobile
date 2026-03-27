import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../models/car.dart';
import '../../providers/app_provider.dart';

class CarListItem extends ConsumerWidget {
  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final bool? isWishlisted;

  const CarListItem({
    super.key,
    required this.car,
    this.onTap,
    this.onWishlistTap,
    this.isWishlisted,
  });

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final wishlisted = isWishlisted ?? wishlist.contains(car.id);
    final carColor = _parseHex(car.color);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight, width: 1),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 110,
              height: 85,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    carColor.withValues(alpha:0.3),
                    AppColors.bgCard,
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  car.brand[0],
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: carColor.withValues(alpha:0.25),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          car.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onWishlistTap ??
                            () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(car.id),
                        child: Icon(
                          wishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: wishlisted
                              ? AppColors.danger
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${car.year} \u2022 ${car.km} km \u2022 ${car.transmission}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\u20B9${car.price}',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (car.badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            car.badge,
                            style: GoogleFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        car.city,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';
import '../../models/car.dart';
import '../../providers/app_provider.dart';

class CarCard extends ConsumerStatefulWidget {
  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  ConsumerState<CarCard> createState() => _CarCardState();
}

class _CarCardState extends ConsumerState<CarCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.contains(widget.car.id);
    final cardWidth = MediaQuery.of(context).size.width * 0.56;
    final carColor = _parseHex(widget.car.color);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          width: cardWidth,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image area
              SizedBox(
                height: 130,
                child: Stack(
                  children: [
                    // Gradient background
                    Container(
                      width: double.infinity,
                      height: 130,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
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
                          widget.car.brand[0],
                          style: GoogleFonts.dmSans(
                            fontSize: 56,
                            fontWeight: FontWeight.w800,
                            color: carColor.withValues(alpha:0.2),
                          ),
                        ),
                      ),
                    ),
                    // Badge
                    if (widget.car.badge.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha:0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.car.badge,
                                style: GoogleFonts.dmSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Heart icon
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onWishlistTap ??
                            () => ref
                                .read(wishlistProvider.notifier)
                                .toggle(widget.car.id),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.bg.withValues(alpha:0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 16,
                                color: isWishlisted
                                    ? AppColors.danger
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Info area
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.car.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.car.year} \u2022 ${widget.car.km} km \u2022 ${widget.car.fuel}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\u20B9${widget.car.price}',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.car.emi,
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
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
      ),
    );
  }
}

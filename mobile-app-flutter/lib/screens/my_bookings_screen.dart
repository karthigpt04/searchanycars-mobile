import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../providers/auth_provider.dart';
import '../services/api/api_booking_service.dart';
import '../services/api/dio_client.dart';
import '../utils/cache_manager.dart';
import '../widgets/ui/skeleton_loader.dart';

/// Provider that fetches bookings from API (auth) or local Hive (guest/offline).
final bookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.isAuthenticated && DioClient.isInitialized) {
    try {
      return await ApiBookingService().getBookings();
    } catch (_) {
      // Fallback to local
    }
  }
  return CacheManager.getBookings();
});

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 24, top: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.chevronLeft, size: 20, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Bookings',
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
              padding: const EdgeInsets.only(left: 68, top: 2),
              child: Text(
                'Your test drive appointments',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 16),

            // Content
            Expanded(
              child: bookingsAsync.when(
                data: (bookings) {
                  if (bookings.isEmpty) return _buildEmptyState(context);
                  return _buildBookingsList(context, ref, bookings);
                },
                loading: () => _buildSkeletons(),
                error: (e, st) => _buildErrorState(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingsList(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> bookings) {
    return RefreshIndicator(
      color: AppColors.gold,
      backgroundColor: AppColors.bgCard,
      onRefresh: () async => ref.invalidate(bookingsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];
          final status = (b['status'] as String?) ?? 'pending';
          final carTitle = (b['car_title'] as String?) ?? (b['carTitle'] as String?) ?? (b['listing_title'] as String?) ?? 'Car';
          final listingId = b['listing_id'] ?? b['listingId'];
          final preferredDate = b['preferred_date'] ?? b['preferredDate'];
          final preferredTime = b['preferred_time'] ?? b['preferredTime'];
          final phone = (b['phone'] as String?) ?? '';
          final notes = b['notes'] as String?;
          final locationPref = (b['location_preference'] as String?) ?? 'hub';
          final createdAt = b['created_at'] ?? b['createdAt'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Car title + status
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: listingId != null ? () => context.push('/car/$listingId') : null,
                        child: Text(
                          carTitle,
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    _statusBadge(status),
                  ],
                ),
                const SizedBox(height: 10),

                // Details row
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  children: [
                    if (preferredDate != null)
                      _detailChip(LucideIcons.calendar, '$preferredDate'),
                    if (preferredTime != null)
                      _detailChip(LucideIcons.clock, '$preferredTime'),
                    _detailChip(
                      LucideIcons.mapPin,
                      locationPref == 'home' ? 'Home' : 'Hub',
                    ),
                    if (phone.isNotEmpty)
                      _detailChip(LucideIcons.phone, phone),
                  ],
                ),

                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Note: $notes',
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Footer
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.borderLight)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _formatDate(createdAt),
                        style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textMuted),
                      ),
                      const Spacer(),
                      if (status == 'pending')
                        GestureDetector(
                          onTap: () => _cancelBooking(context, ref, b),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: index.clamp(0, 8) * 80), duration: 400.ms)
              .slideY(begin: 0.08, end: 0, delay: Duration(milliseconds: index.clamp(0, 8) * 80), duration: 400.ms);
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) {
      'confirmed' => AppColors.success,
      'completed' => AppColors.info,
      'cancelled' => AppColors.danger,
      _ => AppColors.gold,
    };
    final label = switch (status) {
      'confirmed' => 'Confirmed',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      _ => 'Pending',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }

  Widget _detailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _cancelBooking(BuildContext context, WidgetRef ref, Map<String, dynamic> booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Cancel Booking', style: GoogleFonts.dmSans(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Are you sure you want to cancel this booking?', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No', style: GoogleFonts.dmSans(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Yes, Cancel', style: GoogleFonts.dmSans(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final id = booking['id'];
      if (id != null && DioClient.isInitialized) {
        try {
          await ApiBookingService().cancelBooking(id as int);
        } catch (_) {}
      }
      ref.invalidate(bookingsProvider);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendarX, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No bookings yet', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text('Browse cars and book a test drive', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => context.go('/search'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
              ),
              child: Text('Browse Cars', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletons() {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 100),
      itemCount: 3,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: SkeletonLoader(width: double.infinity, height: 140, borderRadius: 18),
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('Unable to load bookings', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => ref.invalidate(bookingsProvider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
              ),
              child: Text('Retry', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.gold)),
            ),
          ),
        ],
      ),
    );
  }
}

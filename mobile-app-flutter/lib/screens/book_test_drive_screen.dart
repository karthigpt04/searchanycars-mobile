import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/test_drive_booking.dart';
import '../repositories/car_repository.dart';
import '../utils/cache_manager.dart';

class BookTestDriveScreen extends ConsumerStatefulWidget {
  final int carId;

  const BookTestDriveScreen({super.key, required this.carId});

  @override
  ConsumerState<BookTestDriveScreen> createState() =>
      _BookTestDriveScreenState();
}

class _BookTestDriveScreenState extends ConsumerState<BookTestDriveScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isSuccess = false;
  String _bookedCarTitle = '';

  static const List<String> _timeSlots = [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              onPrimary: AppColors.bg,
              surface: AppColors.bgCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: AppColors.bgCard),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd MMM yyyy').format(picked);
    }
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Preferred Time',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _timeSlots.map((slot) {
                  final isSelected = _timeController.text == slot;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _timeController.text = slot);
                      Navigator.of(ctx).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.gold.withValues(alpha: 0.15)
                            : AppColors.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        slot,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.gold
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit(String carTitle) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final booking = TestDriveBooking(
      listingId: widget.carId,
      carTitle: carTitle,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      preferredDate: _dateController.text.trim(),
      preferredTime: _timeController.text.trim(),
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: DateTime.now().toIso8601String(),
    );

    await CacheManager.saveBooking(booking.toJson());

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _bookedCarTitle = carTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingDetailProvider(widget.carId));
    final serverBaseUrl = ref.watch(serverBaseUrlProvider);
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: _isSuccess
          ? _buildSuccessState(topPadding, bottomPadding)
          : listingAsync.when(
              data: (listing) {
                if (listing == null) {
                  return _buildNotFound(topPadding);
                }
                return _buildForm(listing, serverBaseUrl, topPadding, bottomPadding);
              },
              loading: () => _buildLoading(topPadding),
              error: (error, _) => _buildError(topPadding),
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Success state
  // ---------------------------------------------------------------------------

  Widget _buildSuccessState(double topPadding, double bottomPadding) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated checkmark
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.checkCircle,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.0, 0.0),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              Text(
                'Booking Confirmed!',
                style: GoogleFonts.dmSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),

              const SizedBox(height: 12),

              Text(
                _bookedCarTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gold,
                ),
              )
                  .animate(delay: 350.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),

              const SizedBox(height: 16),

              Text(
                'Our team will contact you shortly to confirm your test drive schedule.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 40),

              // Back to car button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.gold,
                        AppColors.goldLight,
                        AppColors.gold,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
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
                      'Back to Car',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.bg,
                      ),
                    ),
                  ),
                ),
              )
                  .animate(delay: 650.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form
  // ---------------------------------------------------------------------------

  Widget _buildForm(
    dynamic listing,
    String serverBaseUrl,
    double topPadding,
    double bottomPadding,
  ) {
    final imageUrls = listing.imageUrls(serverBaseUrl);
    final firstImage = imageUrls.isNotEmpty ? imageUrls.first : null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gold gradient header
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.gold.withValues(alpha: 0.08),
                          AppColors.bg,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: topPadding + 12, left: 24, right: 24),
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
                                child: Icon(
                                  LucideIcons.chevronLeft,
                                  size: 20,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Book Test Drive',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Car info summary card
                        _buildCarSummary(listing, firstImage)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(
                              begin: 0.15,
                              end: 0,
                              duration: 400.ms,
                            ),

                        const SizedBox(height: 28),

                        // Section title
                        Text(
                          'Your Details',
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        )
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms),

                        const SizedBox(height: 16),

                        // Name input
                        _buildFormField(
                          controller: _nameController,
                          hint: 'Full Name',
                          icon: LucideIcons.user,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 150.ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: 14),

                        // Phone input
                        _buildFormField(
                          controller: _phoneController,
                          hint: 'Phone Number',
                          icon: LucideIcons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            final digits = value.trim().replaceAll(
                                RegExp(r'[^0-9]'), '');
                            if (digits.length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 230.ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: 14),

                        // Preferred date
                        _buildFormField(
                          controller: _dateController,
                          hint: 'Preferred Date',
                          icon: LucideIcons.calendar,
                          readOnly: true,
                          onTap: _pickDate,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a date';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 310.ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: 14),

                        // Preferred time
                        _buildFormField(
                          controller: _timeController,
                          hint: 'Preferred Time',
                          icon: LucideIcons.clock,
                          readOnly: true,
                          onTap: _showTimePicker,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please select a time slot';
                            }
                            return null;
                          },
                        )
                            .animate(delay: 390.ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: 14),

                        // Notes (optional)
                        _buildFormField(
                          controller: _notesController,
                          hint: 'Additional Notes (optional)',
                          icon: LucideIcons.messageSquare,
                          maxLines: 3,
                        )
                            .animate(delay: 470.ms)
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: 0.05, end: 0, duration: 400.ms),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Submit button pinned to bottom
        Container(
          padding: EdgeInsets.fromLTRB(24, 16, 24, bottomPadding + 16),
          decoration: BoxDecoration(
            color: AppColors.bg,
            border: Border(
              top: BorderSide(color: AppColors.borderLight, width: 1),
            ),
          ),
          child: GestureDetector(
            onTap: _isSubmitting ? null : () => _submit(listing.title),
            child: Container(
              height: 56,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.gold,
                    AppColors.goldLight,
                    AppColors.gold,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
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
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.bg,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.car,
                            size: 18,
                            color: AppColors.bg,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Book Test Drive',
                            style: GoogleFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.bg,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
            .animate(delay: 550.ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Car summary card
  // ---------------------------------------------------------------------------

  Widget _buildCarSummary(dynamic listing, String? imageUrl) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        children: [
          // Car image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 90,
              height: 68,
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.gold.withValues(alpha: 0.08),
                              AppColors.bgCard,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            listing.brandInitial,
                            style: GoogleFonts.dmSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildImageFallback(
                        listing.brandInitial,
                      ),
                    )
                  : _buildImageFallback(listing.brandInitial),
            ),
          ),
          const SizedBox(width: 14),
          // Car info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  listing.priceFormatted,
                  style: GoogleFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback(String brandInitial) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withValues(alpha: 0.08),
            AppColors.bgCard,
          ],
        ),
      ),
      child: Center(
        child: Text(
          brandInitial,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.gold.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Form field builder (matches login_screen.dart pattern)
  // ---------------------------------------------------------------------------

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textPrimary),
      cursorColor: AppColors.gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.dmSans(fontSize: 14, color: AppColors.textMuted),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(icon, size: 18, color: AppColors.textMuted),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 46),
        suffixIcon: readOnly && onTap != null
            ? Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  LucideIcons.chevronDown,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(minWidth: 46),
        filled: true,
        fillColor: AppColors.bgCard,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.danger.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.danger,
            width: 1,
          ),
        ),
        errorStyle: GoogleFonts.dmSans(
          fontSize: 12,
          color: AppColors.danger,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Loading / Error / Not-found states
  // ---------------------------------------------------------------------------

  Widget _buildLoading(double topPadding) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.gold.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading car details...',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(double topPadding) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 16, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.alertTriangle,
                    size: 48,
                    color: AppColors.danger.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Could not load car details. Please try again.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(double topPadding) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding + 16, left: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    LucideIcons.car,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Car not found',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This listing may no longer be available.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
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

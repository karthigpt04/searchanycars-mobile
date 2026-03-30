import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              // Profile Header — auth-aware
              if (auth.isAuthenticated)
                _buildAuthenticatedHeader(auth)
              else
                _buildGuestHeader(context),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // My Bookings
                    _buildMenuItem(
                      icon: LucideIcons.car,
                      label: 'My Bookings',
                      count: 0,
                      index: 0,
                      onTap: () => context.push('/my-bookings'),
                    ),

                    // Compare History
                    _buildMenuItem(
                      icon: LucideIcons.arrowLeftRight,
                      label: 'Compare History',
                      count: 0,
                      index: 1,
                      onTap: () => context.go('/compare'),
                    ),

                    // Support Center
                    _buildMenuItem(
                      icon: LucideIcons.phone,
                      label: 'Support Center',
                      count: 0,
                      index: 2,
                      onTap: () => _showSupportDialog(context),
                    ),

                    // Edit Profile — only if authenticated
                    if (auth.isAuthenticated)
                      _buildMenuItem(
                        icon: LucideIcons.userCog,
                        label: 'Edit Profile',
                        count: 0,
                        index: 3,
                        onTap: () => _showInfoDialog(
                          context,
                          'Edit Profile',
                          'Profile editing will be available soon.',
                        ),
                      ),

                    // Change Password — only if authenticated
                    if (auth.isAuthenticated)
                      _buildMenuItem(
                        icon: LucideIcons.lock,
                        label: 'Change Password',
                        count: 0,
                        index: 4,
                        onTap: () => _showInfoDialog(
                          context,
                          'Change Password',
                          'Password change will be available soon.',
                        ),
                      ),

                    // Server Settings
                    _buildMenuItem(
                      icon: LucideIcons.settings,
                      label: 'Server Settings',
                      count: 0,
                      index: 5,
                      onTap: () => context.push('/settings'),
                    ),

                    // About
                    _buildMenuItem(
                      icon: LucideIcons.info,
                      label: 'About SearchAnyCars',
                      count: 0,
                      index: 6,
                      onTap: () => _showAboutDialog(context),
                    ),

                    // Logout — only if authenticated
                    if (auth.isAuthenticated)
                      _buildMenuItem(
                        icon: LucideIcons.logOut,
                        label: 'Logout',
                        count: 0,
                        index: 7,
                        isDanger: true,
                        onTap: () async {
                          final confirmed = await _showLogoutDialog(context);
                          if (confirmed == true) {
                            ref.read(authProvider.notifier).logout();
                          }
                        },
                      ),
                  ],
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Text(
                  'SearchAnyCars v1.0.0',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header shown when the user is authenticated.
  Widget _buildAuthenticatedHeader(AuthState auth) {
    final user = auth.user!;
    final memberSince = user.createdAt != null
        ? DateTime.tryParse(user.createdAt!)?.year.toString() ?? ''
        : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            AppColors.gold.withValues(alpha: 0.08),
            AppColors.bg,
          ],
        ),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold,
                  AppColors.goldLight,
                  AppColors.gold,
                ],
              ),
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
                user.initials,
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            user.displayName,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            user.email,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (memberSince.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Member since $memberSince',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Admin / Member badge
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  LucideIcons.star,
                  size: 14,
                  color: AppColors.gold,
                ),
                const SizedBox(width: 6),
                Text(
                  user.isAdmin ? 'Admin' : 'Member',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.05, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  /// Header shown for guest / unauthenticated users.
  Widget _buildGuestHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            AppColors.gold.withValues(alpha: 0.08),
            AppColors.bg,
          ],
        ),
      ),
      child: Column(
        children: [
          // SA logo placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.gold,
                  AppColors.goldDark,
                ],
              ),
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
                'SA',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.bg,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to SearchAnyCars',
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to access your account',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Sign In button
          GestureDetector(
            onTap: () => context.push('/login'),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.gold,
                    AppColors.goldLight,
                    AppColors.gold,
                  ],
                ),
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
                  'Sign In',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.bg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.05, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required int count,
    required int index,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    final iconColor = isDanger ? AppColors.danger : AppColors.gold;
    final labelColor = isDanger ? AppColors.danger : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDanger
                    ? AppColors.danger.withValues(alpha: 0.1)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            // Count badge
            if (count > 0)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                ),
              ),
            if (count > 0) const SizedBox(width: 8),
            // Chevron
            Icon(
              isDanger ? LucideIcons.logOut : LucideIcons.chevronRight,
              size: 18,
              color: isDanger ? AppColors.danger : AppColors.textMuted,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 100 + index * 60),
        )
        .slideX(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 100 + index * 60),
          curve: Curves.easeOut,
        );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.dmSans(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Icon(LucideIcons.phone, size: 20, color: AppColors.gold),
            const SizedBox(width: 10),
            Text(
              'Support Center',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _supportRow(LucideIcons.phone, 'Call Us', '+91 98765 43210'),
            const SizedBox(height: 12),
            _supportRow(LucideIcons.mail, 'Email', 'support@searchanycars.com'),
            const SizedBox(height: 12),
            _supportRow(LucideIcons.messageCircle, 'WhatsApp', '+91 98765 43210'),
            const SizedBox(height: 16),
            Text(
              'Available 24/7 for your queries',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.dmSans(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _supportRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.gold),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'About SearchAnyCars',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "India's Trusted Used Car Platform",
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.gold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'SearchAnyCars aggregates dealer inventory and presents a unified brand experience for buying pre-owned and new cars.',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.dmSans(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.dmSans(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Logout',
              style: GoogleFonts.dmSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/colors.dart';
import '../../providers/connectivity_provider.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);

    if (connectivity.isConnected || connectivity.status == ConnectivityStatus.unknown) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: AppColors.gold.withValues(alpha: 0.15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            connectivity.status == ConnectivityStatus.reconnecting
                ? LucideIcons.refreshCw
                : LucideIcons.wifiOff,
            size: 14,
            color: AppColors.gold,
          ),
          const SizedBox(width: 8),
          Text(
            connectivity.status == ConnectivityStatus.reconnecting
                ? 'Reconnecting...'
                : connectivity.serverUrl == null
                    ? 'No server configured'
                    : 'Offline Mode',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../constants/colors.dart';
import '../providers/connectivity_provider.dart';
import '../utils/cache_manager.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _urlController;
  _TestStatus _testStatus = _TestStatus.idle;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(connectivityProvider).serverUrl ?? '';
    _urlController = TextEditingController(text: saved);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _testStatus = _TestStatus.testing);

    final success = await ref
        .read(connectivityProvider.notifier)
        .testConnection(url);

    if (mounted) {
      setState(() {
        _testStatus = success ? _TestStatus.success : _TestStatus.failed;
      });
    }
  }

  Future<void> _save() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _testStatus = _TestStatus.testing);

    final success = await ref
        .read(connectivityProvider.notifier)
        .setServerUrl(url);

    if (mounted) {
      setState(() {
        _testStatus = success ? _TestStatus.success : _TestStatus.failed;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connected to server',
              style: GoogleFonts.dmSans(color: AppColors.bg),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    await CacheManager.clearAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cache cleared',
            style: GoogleFonts.dmSans(color: AppColors.bg),
          ),
          backgroundColor: AppColors.gold,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(connectivityProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(
                top: topPadding + 12,
                left: 24,
                right: 24,
              ),
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
                    'Settings',
                    style: GoogleFonts.dmSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Server Connection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SERVER CONNECTION',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Server URL input
                  Text(
                    'Server Address',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.gold,
                    decoration: InputDecoration(
                      hintText: 'http://192.168.1.x:4000',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                      filled: true,
                      fillColor: AppColors.bgCard,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 16,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (_) {
                      if (_testStatus != _TestStatus.idle) {
                        setState(() => _testStatus = _TestStatus.idle);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Status indicator
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _statusColor(connectivity),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _statusText(connectivity),
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildButton(
                          'Test Connection',
                          _testConnection,
                          outlined: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildButton('Save & Connect', _save),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // App Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'APP INFO',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Version
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Version',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'SearchAnyCars v1.0.0',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Clear Cache
                  GestureDetector(
                    onTap: _clearCache,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Clear Cache',
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            LucideIcons.trash2,
                            size: 18,
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, {bool outlined = false}) {
    return GestureDetector(
      onTap: _testStatus == _TestStatus.testing ? null : onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: outlined
              ? null
              : const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight, AppColors.gold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: outlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(14),
          border: outlined
              ? Border.all(color: AppColors.gold.withValues(alpha: 0.3))
              : null,
        ),
        child: Center(
          child: _testStatus == _TestStatus.testing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.gold,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: outlined ? AppColors.gold : AppColors.bg,
                  ),
                ),
        ),
      ),
    );
  }

  Color _statusColor(ConnectivityState connectivity) {
    if (_testStatus == _TestStatus.testing ||
        connectivity.status == ConnectivityStatus.reconnecting) {
      return AppColors.gold;
    }
    if (_testStatus == _TestStatus.success || connectivity.isConnected) {
      return AppColors.success;
    }
    if (_testStatus == _TestStatus.failed) {
      return AppColors.danger;
    }
    return AppColors.textMuted;
  }

  String _statusText(ConnectivityState connectivity) {
    if (_testStatus == _TestStatus.testing ||
        connectivity.status == ConnectivityStatus.reconnecting) {
      return 'Testing...';
    }
    if (_testStatus == _TestStatus.success || connectivity.isConnected) {
      return 'Connected';
    }
    if (_testStatus == _TestStatus.failed) {
      return 'Connection failed';
    }
    if (connectivity.serverUrl == null) {
      return 'Not configured';
    }
    return 'Disconnected';
  }
}

enum _TestStatus { idle, testing, success, failed }

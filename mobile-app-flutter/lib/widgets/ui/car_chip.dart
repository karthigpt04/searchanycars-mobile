import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../constants/colors.dart';

class CarChip extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const CarChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<CarChip> createState() => _CarChipState();
}

class _CarChipState extends State<CarChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          decoration: BoxDecoration(
            color: widget.isActive ? AppColors.gold : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive ? AppColors.gold : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isActive ? AppColors.bg : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

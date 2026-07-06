import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FeatureTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final VoidCallback onTap;

  const FeatureTile({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    required this.onTap,
  });

  @override
  State<FeatureTile> createState() => _FeatureTileState();
}

class _FeatureTileState extends State<FeatureTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered
            ? (Matrix4.identity()..scaleByDouble(0.97, 0.97, 1.0, 1.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.cardDark,
              _isHovered ? AppColors.navy800 : AppColors.cardDark,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.accentBlue.withAlpha(60)
                : AppColors.navy700.withAlpha(80),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentBlue.withAlpha(_isHovered ? 15 : 5),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: (widget.iconColor ?? AppColors.accentBlue).withAlpha(20),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.icon,
                  size: 28,
                  color: widget.iconColor ?? AppColors.accentBlue,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

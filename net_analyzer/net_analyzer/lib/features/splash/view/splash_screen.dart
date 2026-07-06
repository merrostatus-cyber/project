import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    final curved = CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic);

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 10),
    ]).animate(curved);

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0, 0.3, curve: Curves.easeIn)),
    );

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.25, 0.5, curve: Curves.easeIn)),
    );

    _subtitleOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.4, 0.65, curve: Curves.easeIn)),
    );

    _dotsOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.6, 0.85, curve: Curves.easeIn)),
    );

    _animController.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final storage = await StorageService.getInstance();
    final route = storage.hasSeenOnboarding ? '/home' : '/welcome';
    if (mounted) context.go(route);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: const _NetworkLogo(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            AnimatedBuilder(
              animation: _textOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacity.value,
                  child: Text(
                    'NetAnalyzer',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _subtitleOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _subtitleOpacity.value,
                  child: Text(
                    'Professional Network Analysis Toolkit',
                    style: GoogleFonts.inter(
                      color: AppColors.accentBlue,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _dotsOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _dotsOpacity.value,
                  child: const _AnimatedDots(),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _NetworkLogo extends StatelessWidget {
  const _NetworkLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0x1A3B82F6),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomPaint(
        size: const Size(120, 120),
        painter: _NetworkLogoPainter(),
      ),
    );
  }
}

class _NetworkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Globe circles
    paint.color = AppColors.accentBlue.withAlpha(80);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.65, paint);

    // Horizontal ellipse
    canvas.save();
    canvas.rotate(0);
    final ovalRect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.6);
    canvas.drawOval(ovalRect, paint);
    canvas.restore();

    // Vertical arc
    canvas.save();
    canvas.rotate(0);
    final ovalRectV = Rect.fromCenter(center: center, width: radius * 0.6, height: radius * 2);
    canvas.drawOval(ovalRectV, paint);
    canvas.restore();

    // Diagonal arcs
    for (var i = 0; i < 2; i++) {
      canvas.save();
      canvas.rotate(i * pi / 2 + pi / 4);
      final ovalRectD = Rect.fromCenter(center: center, width: radius * 1.6, height: radius * 0.4);
      canvas.drawOval(ovalRectD, paint);
      canvas.restore();
    }

    // Network nodes
    paint.color = AppColors.accentBlue;
    paint.style = PaintingStyle.fill;
    final nodeRadius = 3.5;

    final nodes = [
      Offset(center.dx, center.dy - radius * 0.85), // top
      Offset(center.dx, center.dy + radius * 0.85), // bottom
      Offset(center.dx - radius * 0.85, center.dy), // left
      Offset(center.dx + radius * 0.85, center.dy), // right
      Offset(center.dx - radius * 0.55, center.dy - radius * 0.55), // top-left
      Offset(center.dx + radius * 0.55, center.dy - radius * 0.55), // top-right
      Offset(center.dx - radius * 0.55, center.dy + radius * 0.55), // bottom-left
      Offset(center.dx + radius * 0.55, center.dy + radius * 0.55), // bottom-right
    ];
    for (final node in nodes) {
      canvas.drawCircle(node, nodeRadius, paint);
    }

    // Center node
    canvas.drawCircle(center, 5, paint);

    // Glow around center
    paint.color = AppColors.accentBlue.withAlpha(20);
    canvas.drawCircle(center, 14, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final t = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = sin(t * pi);
            final size = 6.0 + (opacity * 4);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withAlpha((80 + (opacity * 175)).toInt()),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

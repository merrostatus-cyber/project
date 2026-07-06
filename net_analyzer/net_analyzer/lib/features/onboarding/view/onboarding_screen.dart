import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/storage_service.dart';
import '../../profile/provider/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameController.text.trim();
    final storage = await StorageService.getInstance();
    await storage.setUserName(name);
    await storage.setHasSeenOnboarding(true);
    ref.read(userNameProvider.notifier).state = name;
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const _NetworkNodesBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildIllustration(),
                          const SizedBox(height: 40),
                          _buildTitle(),
                          const SizedBox(height: 48),
                          _buildGreeting(),
                          const SizedBox(height: 28),
                          _buildNameField(),
                          const SizedBox(height: 36),
                          _buildContinueButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.accentBlue.withAlpha(20),
            Colors.transparent,
          ],
        ),
      ),
      child: CustomPaint(
        size: const Size(180, 180),
        painter: _OnboardingPainter(),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'NetAnalyzer',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Professional Network Analysis Toolkit',
          style: GoogleFonts.inter(
            color: AppColors.accentBlue,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      children: [
        Text(
          'Welcome!',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Before we start,\nwhat should we call you?',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Enter your name',
        filled: true,
        fillColor: AppColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.navy700.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: AppColors.navy700.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accentBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        if (value.trim().length < 2) {
          return 'Name must be at least 2 characters';
        }
        return null;
      },
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [AppColors.accentBlue, AppColors.accentBlueDark],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withAlpha(50),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _NetworkNodesBackground extends StatefulWidget {
  const _NetworkNodesBackground();

  @override
  State<_NetworkNodesBackground> createState() => _NetworkNodesBackgroundState();
}

class _NetworkNodesBackgroundState extends State<_NetworkNodesBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
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
        return CustomPaint(
          size: Size.infinite,
          painter: _NodesPainter(_controller.value),
        );
      },
    );
  }
}

class _NodesPainter extends CustomPainter {
  final double animation;

  _NodesPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final random = Random(42);
    final nodes = <Offset>[];
    for (var i = 0; i < 18; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      nodes.add(Offset(x, y));
    }

    // Draw connections
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < size.width * 0.25 && dist > 0) {
          final opacity = (1 - dist / (size.width * 0.25)) * 0.3;
          linePaint.color = AppColors.accentBlue.withAlpha((opacity * 255 * animation).toInt());
          canvas.drawLine(nodes[i], nodes[j], linePaint);
        }
      }
    }

    // Draw nodes
    for (final node in nodes) {
      paint.color = AppColors.accentBlue.withAlpha((30 * animation).toInt());
      canvas.drawCircle(node, 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(_NodesPainter oldDelegate) => oldDelegate.animation != animation;
}

class _OnboardingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Outer glow
    final glowPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.accentBlue.withAlpha(12);
    canvas.drawCircle(center, radius + 8, glowPaint);

    // Globe rings
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = AppColors.accentBlue.withAlpha(70);

    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.7, ringPaint);

    // Horizontal ellipse
    final ovalRect = Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.55);
    canvas.drawOval(ovalRect, ringPaint);

    // Nodes
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.accentBlue;
    final glowNodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.accentBlue.withAlpha(25);

    final positions = [
      Offset(center.dx, center.dy - radius * 0.85),
      Offset(center.dx, center.dy + radius * 0.85),
      Offset(center.dx - radius * 0.85, center.dy),
      Offset(center.dx + radius * 0.85, center.dy),
    ];

    for (final pos in positions) {
      canvas.drawCircle(pos, 10, glowNodePaint);
      canvas.drawCircle(pos, 3.5, nodePaint);
    }
    canvas.drawCircle(center, 14, glowNodePaint);
    canvas.drawCircle(center, 5, nodePaint);

    // Connection lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accentBlue.withAlpha(40);
    for (final pos in positions) {
      canvas.drawLine(center, pos, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

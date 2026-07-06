import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';

class SpeedTestScreen extends StatefulWidget {
  const SpeedTestScreen({super.key});

  @override
  State<SpeedTestScreen> createState() => _SpeedTestScreenState();
}

class _SpeedTestScreenState extends State<SpeedTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gaugeController;
  late Animation<double> _gaugeAnimation;

  bool _isTesting = false;
  bool _hasCompletedTest = false;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  double _ping = 0;
  double _jitter = 0;
  final String _selectedServer = 'Cloudflare (1.1.1.1)';

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _gaugeAnimation = CurvedAnimation(
      parent: _gaugeController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    super.dispose();
  }

  Future<void> _startTest() async {
    if (_isTesting) return;
    setState(() {
      _isTesting = true;
      _hasCompletedTest = false;
    });
    _gaugeController.reset();

    // Simulate speed test
    final random = Random();
    for (var i = 0; i < 60; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 50));
      setState(() {
        _downloadSpeed = 45 + random.nextDouble() * 55;
        _uploadSpeed = 10 + random.nextDouble() * 25;
        _ping = 5 + random.nextDouble() * 30;
        _jitter = random.nextDouble() * 8;
        _gaugeController.value = (i + 1) / 60.0;
      });
    }

    // Final values
    setState(() {
      _downloadSpeed = 95.7;
      _uploadSpeed = 23.4;
      _ping = 12.5;
      _jitter = 2.1;
      _isTesting = false;
      _hasCompletedTest = true;
      _gaugeController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Speed Test'),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSpeedometer(),
                const SizedBox(height: 24),
                _buildPingJitterRow(),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 24),
                _buildStartButton(),
                const SizedBox(height: 20),
                _buildServerSelector(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedometer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D30), Color(0xFF0A1525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navy700.withAlpha(50)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withAlpha(12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Download Speed',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final gaugeWidth = constraints.maxWidth * 0.85;
              return SizedBox(
                width: gaugeWidth,
                height: gaugeWidth * 1.30,
                child: AnimatedBuilder(
                  animation: _gaugeAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(gaugeWidth, gaugeWidth * 1.05),
                      painter: _SpeedometerPainter(
                        value: _gaugeAnimation.value,
                        downloadSpeed: _downloadSpeed,
                        isTesting: _isTesting,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPingJitterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatChip('Ping', '${_ping.toStringAsFixed(1)} ms'),
        const SizedBox(width: 16),
        _buildStatChip('Jitter', '${_jitter.toStringAsFixed(1)} ms'),
      ],
    );
  }

  Widget _buildStatChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.navy800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy700.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.inter(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Download', _downloadSpeed.toStringAsFixed(1), 'Mbps', AppColors.accentBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Upload', _uploadSpeed.toStringAsFixed(1), 'Mbps', AppColors.success)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, String unit, Color accentColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy700.withAlpha(40)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              label == 'Download' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  unit,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final buttonLabel = _isTesting
        ? 'Testing...'
        : _hasCompletedTest
            ? 'Run Again'
            : 'Start Test';
    return GestureDetector(
      onTap: _isTesting ? null : _startTest,
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: _isTesting
              ? LinearGradient(
                  colors: [
                    AppColors.navy700.withAlpha(100),
                    AppColors.navy700.withAlpha(60),
                  ],
                )
              : const LinearGradient(
                  colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                ),
          boxShadow: _isTesting
              ? []
              : [
                  BoxShadow(
                    color: AppColors.accentBlue.withAlpha(50),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: _isTesting
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.textMuted),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      buttonLabel,
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Text(
                  buttonLabel,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildServerSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy700.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.navy800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.dns_rounded, color: AppColors.accentBlue, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Server',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  _selectedServer,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }
}

class _SpeedometerPainter extends CustomPainter {
  final double value;
  final double downloadSpeed;
  final bool isTesting;

  _SpeedometerPainter({
    required this.value,
    required this.downloadSpeed,
    required this.isTesting,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.66);
    final radius = size.width * 0.38;
    const strokeWidth = 16.0;
    const arcStart = pi * 0.8;
    const arcSweep = pi * 1.4;

    // Background arc
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = AppColors.navy700.withAlpha(80);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      arcStart,
      arcSweep,
      false,
      bgPaint,
    );

    // Value arc
    if (value > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: arcStart,
          endAngle: arcStart + arcSweep,
          colors: const [
            AppColors.success,
            AppColors.warning,
            AppColors.error,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(rect);

      canvas.drawArc(
        rect,
        arcStart,
        arcSweep * value,
        false,
        progressPaint,
      );
    }

    // Speed text
    final textPainter = TextPainter(
      text: TextSpan(
        text: isTesting
            ? (downloadSpeed * value).toStringAsFixed(0)
            : downloadSpeed > 0
                ? downloadSpeed.toStringAsFixed(1)
                : '0',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 64,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final centerX = center.dx - textPainter.width / 2;
    final centerY = center.dy - (textPainter.height + 14) / 2;
    textPainter.paint(canvas, Offset(centerX, centerY));

    // Unit label
    final unitPainter = TextPainter(
      text: TextSpan(
        text: 'Mbps',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    unitPainter.layout();
    final unitX = center.dx - unitPainter.width / 2;
    final unitY = centerY + textPainter.height + 10;
    unitPainter.paint(canvas, Offset(unitX, unitY));
  }

  @override
  bool shouldRepaint(_SpeedometerPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.downloadSpeed != downloadSpeed;
}

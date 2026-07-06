import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../provider/ip_providers.dart';
import '../model/ip_info_model.dart';

class IPToolsScreen extends ConsumerStatefulWidget {
  const IPToolsScreen({super.key});

  @override
  ConsumerState<IPToolsScreen> createState() => _IPToolsScreenState();
}

class _IPToolsScreenState extends ConsumerState<IPToolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IP Tools'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navy700.withAlpha(40)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.accentBlue.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.accentBlue,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
              tabs: const [
                Tab(text: 'My IP'),
                Tab(text: 'Local IP'),
                Tab(text: 'IP Lookup'),
                Tab(text: 'Reverse DNS'),
              ],
            ),
          ),
        ),
      ),
      body: ResponsiveContent(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _MyIPTab(),
            _LocalIPTab(),
            _IPLookupTab(),
            _ReverseDNSTab(),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: isHighlight ? AppColors.accentBlue : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MyIPTab extends ConsumerWidget {
  const _MyIPTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ipAsync = ref.watch(myPublicIPProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          ipAsync.when(
            data: (info) => _buildIPCard(info),
            loading: () => const _LoadingState(),
            error: (_, _) => _buildError(() => ref.invalidate(myPublicIPProvider)),
          ),
          const SizedBox(height: 32),
          _buildBottomNetworkArt(),
        ],
      ),
    );
  }

  Widget _buildIPCard(IPInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
            color: AppColors.accentBlue.withAlpha(15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accentBlue.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.language_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Public IP',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            info.ip,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          if (info.country.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.navy700.withAlpha(60)),
            const SizedBox(height: 16),
            if (info.country.isNotEmpty) _InfoRow(label: 'Country', value: info.country),
            if (info.region.isNotEmpty) _InfoRow(label: 'Region', value: info.region),
            if (info.city.isNotEmpty) _InfoRow(label: 'City', value: info.city),
            if (info.isp.isNotEmpty) _InfoRow(label: 'ISP', value: info.isp),
            if (info.org.isNotEmpty) _InfoRow(label: 'Org', value: info.org),
            if (info.timezone.isNotEmpty) _InfoRow(label: 'Timezone', value: info.timezone),
            if (info.lat != 0 || info.lon != 0)
              _InfoRow(
                label: 'Coordinates',
                value: '${info.lat.toStringAsFixed(4)}, ${info.lon.toStringAsFixed(4)}',
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNetworkArt() {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        size: const Size(double.infinity, 80),
        painter: _NetworkDecoPainter(),
      ),
    );
  }
}

class _LocalIPTab extends ConsumerWidget {
  const _LocalIPTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localAsync = ref.watch(localIPProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          localAsync.when(
            data: (info) => _buildLocalCard(info),
            loading: () => const _LoadingState(),
            error: (_, _) => _buildError(() => ref.invalidate(localIPProvider)),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalCard(LocalIPInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
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
            color: AppColors.success.withAlpha(12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gradientGreenStart, AppColors.gradientGreenEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gradientGreenStart.withAlpha(40),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 34),
          ),
          const SizedBox(height: 20),
          Text(
            'Local IP Address',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            info.ip,
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          if (info.interfaceName.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.navy700.withAlpha(60)),
            const SizedBox(height: 16),
            _InfoRow(label: 'Interface', value: info.interfaceName),
            _InfoRow(
              label: 'Type',
              value: info.isWiFi ? 'Wi-Fi' : 'Ethernet',
              isHighlight: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _IPLookupTab extends ConsumerStatefulWidget {
  const _IPLookupTab();

  @override
  ConsumerState<_IPLookupTab> createState() => _IPLookupTabState();
}

class _IPLookupTabState extends ConsumerState<_IPLookupTab> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;
    setState(() => _hasSearched = true);
    ref.invalidate(ipLookupProvider(ip));
  }

  @override
  Widget build(BuildContext context) {
    final lookupAsync = _hasSearched ? ref.watch(ipLookupProvider(_controller.text.trim())) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.navy700.withAlpha(50)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter IP address (e.g. 8.8.8.8)',
                    prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _lookup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Lookup', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (lookupAsync != null)
            lookupAsync.when(
              data: (info) => _buildLookupResult(info),
              loading: () => const _LoadingState(),
              error: (_, _) => _buildError(() => _lookup()),
            ),
        ],
      ),
    );
  }

  Widget _buildLookupResult(IPInfo info) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy700.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: info.country != 'Invalid / Private IP'
                      ? AppColors.success
                      : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Lookup Result',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'IP', value: info.ip, isHighlight: true),
          if (info.country.isNotEmpty) _InfoRow(label: 'Country', value: info.country),
          if (info.region.isNotEmpty) _InfoRow(label: 'Region', value: info.region),
          if (info.city.isNotEmpty) _InfoRow(label: 'City', value: info.city),
          if (info.isp.isNotEmpty) _InfoRow(label: 'ISP', value: info.isp),
          if (info.org.isNotEmpty) _InfoRow(label: 'Org', value: info.org),
          if (info.timezone.isNotEmpty) _InfoRow(label: 'Timezone', value: info.timezone),
          if (info.lat != 0 || info.lon != 0)
            _InfoRow(
              label: 'Coordinates',
              value: '${info.lat.toStringAsFixed(4)}, ${info.lon.toStringAsFixed(4)}',
            ),
        ],
      ),
    );
  }
}

class _ReverseDNSTab extends ConsumerStatefulWidget {
  const _ReverseDNSTab();

  @override
  ConsumerState<_ReverseDNSTab> createState() => _ReverseDNSTabState();
}

class _ReverseDNSTabState extends ConsumerState<_ReverseDNSTab> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final ip = _controller.text.trim();
    if (ip.isEmpty) return;
    setState(() => _hasSearched = true);
    ref.invalidate(reverseDNSProvider(ip));
  }

  @override
  Widget build(BuildContext context) {
    final dnsAsync = _hasSearched ? ref.watch(reverseDNSProvider(_controller.text.trim())) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.navy700.withAlpha(50)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Enter IP address',
                    prefixIcon: Icon(Icons.wifi_tethering, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _lookup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Lookup', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (dnsAsync != null)
            dnsAsync.when(
              data: (result) => _buildResult(result),
              loading: () => const _LoadingState(),
              error: (_, _) => _buildError(() => _lookup()),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(ReverseDNSResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy700.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: result.hasReverse ? AppColors.success : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                result.hasReverse ? 'PTR Record Found' : 'No PTR Record',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'IP', value: result.ip, isHighlight: true),
          if (result.hasReverse)
            _InfoRow(label: 'Hostname', value: result.hostname ?? '', isHighlight: true)
          else
            _InfoRow(
              label: 'Status',
              value: 'No reverse DNS record configured for this IP',
            ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue)),
      ),
    );
  }
}

Widget _buildError(VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textMuted, size: 48),
          const SizedBox(height: 12),
          Text(
            'Failed to fetch data',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

class _NetworkDecoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.accentBlue.withAlpha(25);

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    final random = Random(42);
    var x = 0.0;
    while (x < size.width) {
      x += 20 + random.nextDouble() * 30;
      final y = size.height * (0.4 + random.nextDouble() * 0.4);
      path.lineTo(x, y);
    }
    canvas.drawPath(path, paint);

    // nodes
    final nodePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AppColors.accentBlue.withAlpha(30);
    x = 0;
    while (x < size.width) {
      x += 40 + random.nextDouble() * 50;
      final y = size.height * (0.4 + random.nextDouble() * 0.4);
      canvas.drawCircle(Offset(x, y), 2.5, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../provider/network_providers.dart';
import '../model/network_models.dart';

class NetworkToolsScreen extends ConsumerStatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  ConsumerState<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends ConsumerState<NetworkToolsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        title: const Text('Network Tools'),
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
                Tab(text: 'Ping'),
                Tab(text: 'Traceroute'),
                Tab(text: 'Port Scanner'),
              ],
            ),
          ),
        ),
      ),
      body: ResponsiveContent(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _PingTab(),
            _TracerouteTab(),
            _PortScannerTab(),
          ],
        ),
      ),
    );
  }
}

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

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

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
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
}

class _PingTab extends ConsumerStatefulWidget {
  const _PingTab();

  @override
  ConsumerState<_PingTab> createState() => _PingTabState();
}

class _PingTabState extends ConsumerState<_PingTab> {
  final _controller = TextEditingController(text: '8.8.8.8');
  bool _hasRun = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startPing() {
    final host = _controller.text.trim();
    if (host.isEmpty) return;
    setState(() => _hasRun = true);
    ref.invalidate(pingProvider(host));
  }

  @override
  Widget build(BuildContext context) {
    final host = _controller.text.trim();
    final pingAsync = _hasRun && host.isNotEmpty ? ref.watch(pingProvider(host)) : null;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ping',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter Domain or IP',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'google.com',
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
                    child: ElevatedButton.icon(
                      onPressed: _startPing,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                      label: const Text('Start Ping'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (pingAsync != null)
            pingAsync.when(
              data: (result) => _buildPingResult(result, host),
              loading: () => const _LoadingWidget(),
              error: (_, _) => _ErrorWidget(
                message: 'Ping failed',
                onRetry: _startPing,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPingResult(PingResult result, String host) {
    final isSuccess = result.received > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            color: isSuccess
                ? AppColors.success.withAlpha(10)
                : AppColors.error.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isSuccess ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Results — $host',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isSuccess
                      ? AppColors.success.withAlpha(20)
                      : AppColors.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isSuccess ? 'Reachable' : 'Failed',
                  style: GoogleFonts.inter(
                    color: isSuccess ? AppColors.success : AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Packets Sent', '${result.sent}'),
              _statItem('Packets Received', '${result.received}'),
              _statItem('Packet Loss', '${result.packetLossPercent.toStringAsFixed(0)}%'),
            ],
          ),
          if (result.received > 0) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.navy700.withAlpha(50)),
            const SizedBox(height: 16),
            Text(
              'Response Time',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem('Min', '${result.minRtt} ms'),
                _statItem('Average', '${result.avgRtt} ms'),
                _statItem('Max', '${result.maxRtt} ms'),
              ],
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.navy700.withAlpha(50)),
            const SizedBox(height: 16),
            ...result.rttsMs.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'Reply ${e.key + 1}:',
                        style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: result.maxRtt > 0 ? e.value / result.maxRtt : 0,
                          backgroundColor: AppColors.navy700,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            e.value < 100
                                ? AppColors.success
                                : e.value < 300
                                    ? AppColors.warning
                                    : AppColors.error,
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${e.value} ms',
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TracerouteTab extends ConsumerStatefulWidget {
  const _TracerouteTab();

  @override
  ConsumerState<_TracerouteTab> createState() => _TracerouteTabState();
}

class _TracerouteTabState extends ConsumerState<_TracerouteTab> {
  final _controller = TextEditingController();
  bool _hasRun = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTrace() {
    final target = _controller.text.trim();
    if (target.isEmpty) return;
    setState(() => _hasRun = true);
    ref.invalidate(tracerouteProvider(target));
  }

  @override
  Widget build(BuildContext context) {
    final target = _controller.text.trim();
    final traceAsync =
        _hasRun && target.isNotEmpty ? ref.watch(tracerouteProvider(target)) : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildInputCard(target),
          const SizedBox(height: 20),
          if (traceAsync != null)
            traceAsync.when(
              data: (result) => _buildResult(result),
              loading: () => const _LoadingWidget(),
              error: (_, _) => _ErrorWidget(
                message: 'Traceroute failed',
                onRetry: _startTrace,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputCard(String target) {
    return Container(
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
              hintText: 'Domain or IP to trace',
              prefixIcon: Icon(Icons.alt_route_rounded, color: AppColors.textMuted),
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
                  colors: [AppColors.gradientGreenStart, AppColors.gradientGreenEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientGreenStart.withAlpha(40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _startTrace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('Trace'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(TracerouteResult result) {
    if (result.hops.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.navy700.withAlpha(50)),
        ),
        child: Column(
          children: [
            const Icon(Icons.alt_route_rounded, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 12),
            Text(
              'No hops found.\nTraceroute may not be available on this platform.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D30), Color(0xFF0A1525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.navy700.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: AppColors.accentBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Route to ${result.target}',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...result.hops.map((hop) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accentBlue, AppColors.accentBlueDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${hop.hop}',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hop.ip,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.navy800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${hop.rttMs} ms',
                    style: GoogleFonts.inter(
                      color: AppColors.accentBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _PortScannerTab extends ConsumerStatefulWidget {
  const _PortScannerTab();

  @override
  ConsumerState<_PortScannerTab> createState() => _PortScannerTabState();
}

class _PortScannerTabState extends ConsumerState<_PortScannerTab> {
  final _controller = TextEditingController();
  bool _hasRun = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startScan() {
    final host = _controller.text.trim();
    if (host.isEmpty) return;
    setState(() => _hasRun = true);
    ref.invalidate(portScanProvider(host));
  }

  @override
  Widget build(BuildContext context) {
    final host = _controller.text.trim();
    final scanAsync =
        _hasRun && host.isNotEmpty ? ref.watch(portScanProvider(host)) : null;

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
                    hintText: 'Target IP address',
                    prefixIcon: Icon(Icons.wifi_find_rounded, color: AppColors.textMuted),
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
                        colors: [AppColors.gradientOrangeStart, AppColors.gradientOrangeEnd],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientOrangeStart.withAlpha(40),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _startScan,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.search_rounded, size: 18),
                      label: const Text('Scan Common Ports'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if (scanAsync != null)
            scanAsync.when(
              data: (summary) => _buildScanResult(summary),
              loading: () => const _LoadingWidget(),
              error: (_, _) => _ErrorWidget(
                message: 'Scan failed',
                onRetry: _startScan,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanResult(PortScanSummary summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1D30), Color(0xFF0A1525)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
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
                  color: summary.openCount > 0 ? AppColors.warning : AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Results — ${summary.target}',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scanStatItem('Open', '${summary.openCount}', AppColors.error),
              _scanStatItem('Closed', '${summary.closedCount}', AppColors.success),
              _scanStatItem('Total', '${summary.results.length}', AppColors.textPrimary),
            ],
          ),
          if (summary.openCount > 0) ...[
            const SizedBox(height: 20),
            Container(height: 1, color: AppColors.navy700.withAlpha(50)),
            const SizedBox(height: 12),
            Text(
              'Open Ports',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...summary.results.where((r) => r.open).map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 10),
                  Text(
                    '${r.port}',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (r.service != null)
                    Text(
                      r.service!,
                      style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
                    ),
                  const Spacer(),
                  Text(
                    '${r.responseTimeMs} ms',
                    style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _scanStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

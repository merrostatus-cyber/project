import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../provider/lookup_providers.dart';
import '../model/lookup_models.dart';

class LookupScreen extends ConsumerStatefulWidget {
  const LookupScreen({super.key});

  @override
  ConsumerState<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends ConsumerState<LookupScreen>
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
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Lookup'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.navy800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                color: AppColors.accentBlue.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: AppColors.accentBlue,
              unselectedLabelColor: AppColors.textMuted,
              labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'DNS Lookup'),
                Tab(text: 'Whois'),
                Tab(text: 'MAC Vendor'),
              ],
            ),
          ),
        ),
      ),
      body: ResponsiveContent(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _DNSTab(),
            _WhoisTab(),
            _MACTab(),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DNSTab extends ConsumerStatefulWidget {
  const _DNSTab();

  @override
  ConsumerState<_DNSTab> createState() => _DNSTabState();
}

class _DNSTabState extends ConsumerState<_DNSTab> {
  final _controller = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final domain = _controller.text.trim();
    if (domain.isEmpty) return;
    setState(() => _hasSearched = true);
    ref.invalidate(dnsLookupProvider(domain));
  }

  @override
  Widget build(BuildContext context) {
    final domain = _controller.text.trim();
    final dnsAsync = _hasSearched && domain.isNotEmpty
        ? ref.watch(dnsLookupProvider(domain))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navy700.withAlpha(80)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. google.com',
                    labelText: 'Domain',
                    prefixIcon: Icon(Icons.language, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _lookup,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('DNS Lookup'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (dnsAsync != null)
            dnsAsync.when(
              data: (result) => _buildResult(result),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                ),
              ),
              error: (_, _) => _buildRetry(),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(DNSResult result) {
    if (result.records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navy700.withAlpha(80)),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppColors.warningOrange, size: 40),
            const SizedBox(height: 12),
            Text(
              'No DNS records found for ${result.domain}',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final grouped = <String, List<DNSRecord>>{};
    for (final record in result.records) {
      grouped.putIfAbsent(record.type, () => []).add(record);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy700.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.cyberGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                '${result.records.length} records found',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...grouped.entries.expand((entry) {
            return [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    color: AppColors.accentBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...entry.value.map((r) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.value,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'TTL: ${r.ttl}s',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildRetry() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _lookup,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _WhoisTab extends ConsumerStatefulWidget {
  const _WhoisTab();

  @override
  ConsumerState<_WhoisTab> createState() => _WhoisTabState();
}

class _WhoisTabState extends ConsumerState<_WhoisTab> {
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
    ref.invalidate(whoisLookupProvider(ip));
  }

  @override
  Widget build(BuildContext context) {
    final ip = _controller.text.trim();
    final whoisAsync = _hasSearched && ip.isNotEmpty
        ? ref.watch(whoisLookupProvider(ip))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navy700.withAlpha(80)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 8.8.8.8',
                    labelText: 'IP Address',
                    prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _lookup,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Whois Lookup'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (whoisAsync != null)
            whoisAsync.when(
              data: (info) => _buildResult(info),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                ),
              ),
              error: (_, _) => _buildRetry(),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(WhoisInfo info) {
    final hasData = info.orgName != null ||
        info.netName != null ||
        info.country != null;

    if (!hasData) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.navy700.withAlpha(80)),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppColors.warningOrange, size: 40),
            const SizedBox(height: 12),
            Text(
              'No WHOIS data found for ${info.query}',
              style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy700.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.cyberGreen, size: 18),
              const SizedBox(width: 8),
              Text(
                'WHOIS — ${info.query}',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (info.orgName != null) _InfoRow(label: 'Org', value: info.orgName!),
          if (info.netName != null) _InfoRow(label: 'Net Name', value: info.netName!),
          if (info.netRange != null) _InfoRow(label: 'Net Range', value: info.netRange!),
          if (info.country != null) _InfoRow(label: 'Country', value: info.country!),
          if (info.city != null) _InfoRow(label: 'City', value: info.city!),
          if (info.address != null) _InfoRow(label: 'Address', value: info.address!),
          if (info.regDate != null) _InfoRow(label: 'Registered', value: info.regDate!),
          if (info.updatedDate != null) _InfoRow(label: 'Updated', value: info.updatedDate!),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navy800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Data from ARIN RDAP',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetry() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _lookup,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _MACTab extends ConsumerStatefulWidget {
  const _MACTab();

  @override
  ConsumerState<_MACTab> createState() => _MACTabState();
}

class _MACTabState extends ConsumerState<_MACTab> {
  final _controller = TextEditingController();
  bool _hasSearched = false;
  String? _validationError;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final mac = _controller.text.trim();
    if (mac.isEmpty) return;
    setState(() {
      _validationError = null;
      _hasSearched = true;
    });
    ref.invalidate(macLookupProvider(mac));
  }

  @override
  Widget build(BuildContext context) {
    final mac = _controller.text.trim();
    final macAsync = _hasSearched && mac.isNotEmpty
        ? ref.watch(macLookupProvider(mac))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.navy700.withAlpha(80)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 00:1A:2B:3C:4D:5E',
                    labelText: 'MAC Address',
                    prefixIcon: Icon(Icons.memory, color: AppColors.textMuted),
                  ),
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _validationError!,
                    style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _lookup,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Lookup Vendor'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (macAsync != null)
            macAsync.when(
              data: (result) => _buildResult(result),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: AppColors.accentBlue),
                ),
              ),
              error: (_, _) => _buildRetry(),
            ),
        ],
      ),
    );
  }

  Widget _buildResult(MACVendorResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy700.withAlpha(80)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: (result.found ? AppColors.cyberGreen : AppColors.warningOrange)
                  .withAlpha(20),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              result.found ? Icons.check_circle : Icons.help_outline,
              color: result.found ? AppColors.cyberGreen : AppColors.warningOrange,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            result.mac.toUpperCase(),
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          if (result.found) ...[
            Text(
              result.vendor!,
              style: GoogleFonts.inter(
                color: AppColors.accentBlue,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            Text(
              'Vendor not found',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The MAC may be from a private range or invalid.',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.navy800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Data from macvendors.com',
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetry() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _lookup,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

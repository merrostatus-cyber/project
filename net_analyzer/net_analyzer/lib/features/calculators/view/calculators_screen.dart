import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/responsive_content.dart';
import '../service/calc_service.dart';
import '../model/calc_models.dart';
import '../provider/calc_providers.dart';

class CalculatorsScreen extends ConsumerStatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  ConsumerState<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends ConsumerState<CalculatorsScreen>
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
        title: const Text('Calculators'),
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
                Tab(text: 'Subnet'),
                Tab(text: 'CIDR'),
                Tab(text: 'IPv4 Info'),
              ],
            ),
          ),
        ),
      ),
      body: ResponsiveContent(
        child: TabBarView(
          controller: _tabController,
          children: [
            _SubnetTab(calcService: ref.read(calcServiceProvider)),
            _CIDRTab(calcService: ref.read(calcServiceProvider)),
            _IPv4Tab(calcService: ref.read(calcServiceProvider)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _InfoRow({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                color: highlight ? AppColors.accentBlue : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubnetTab extends StatefulWidget {
  final CalcService calcService;
  const _SubnetTab({required this.calcService});

  @override
  State<_SubnetTab> createState() => _SubnetTabState();
}

class _SubnetTabState extends State<_SubnetTab> {
  final _ipController = TextEditingController();
  int _cidr = 24;
  SubnetResult? _result;
  String? _error;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _calculate() {
    final ip = _ipController.text.trim();
    if (!widget.calcService.isValidIP(ip)) {
      setState(() => _error = 'Invalid IP address');
      return;
    }
    if (!widget.calcService.isValidCIDR(_cidr)) {
      setState(() => _error = 'Invalid CIDR (must be 0-32)');
      return;
    }
    setState(() {
      _error = null;
      _result = widget.calcService.calculateSubnet(ip, _cidr);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _ipController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 192.168.1.0',
                    labelText: 'IP Address',
                    prefixIcon: Icon(Icons.language, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'CIDR: /$_cidr',
                      style: GoogleFonts.inter(
                        color: AppColors.accentBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _cidr.toDouble(),
                        min: 0,
                        max: 32,
                        divisions: 32,
                        activeColor: AppColors.accentBlue,
                        inactiveColor: AppColors.navy700,
                        onChanged: (v) => setState(() => _cidr = v.toInt()),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$_cidr',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Calculate'),
                ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _buildResultCard(SubnetResult r) {
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
                '${r.ipAddress}/${r.cidr}',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Network', value: r.networkAddress, highlight: true),
          _InfoRow(label: 'Broadcast', value: r.broadcastAddress, highlight: true),
          _InfoRow(label: 'First Usable', value: r.firstUsable),
          _InfoRow(label: 'Last Usable', value: r.lastUsable),
          const Divider(color: AppColors.navy700),
          _InfoRow(label: 'Subnet Mask', value: r.subnetMask),
          _InfoRow(label: 'Total Hosts', value: '${r.totalHosts}'),
          _InfoRow(label: 'Usable Hosts', value: '${r.usableHosts}'),
          _InfoRow(label: 'Class', value: r.ipClass),
          _InfoRow(label: 'Private', value: r.isPrivate ? 'Yes' : 'No'),
          const Divider(color: AppColors.navy700),
          _InfoRow(label: 'Binary IP', value: r.binaryIp),
          _InfoRow(label: 'Binary Mask', value: r.binaryMask),
        ],
      ),
    );
  }
}

class _CIDRTab extends StatefulWidget {
  final CalcService calcService;
  const _CIDRTab({required this.calcService});

  @override
  State<_CIDRTab> createState() => _CIDRTabState();
}

class _CIDRTabState extends State<_CIDRTab> {
  final _ipController = TextEditingController();
  int _cidr = 24;
  SubnetResult? _result;
  String? _error;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _calculate() {
    final ip = _ipController.text.trim();
    if (!widget.calcService.isValidIP(ip)) {
      setState(() => _error = 'Invalid IP address');
      return;
    }
    if (!widget.calcService.isValidCIDR(_cidr)) {
      setState(() => _error = 'Invalid CIDR (must be 0-32)');
      return;
    }
    setState(() {
      _error = null;
      _result = widget.calcService.calculateSubnet(ip, _cidr);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _ipController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 10.0.0.0',
                    labelText: 'Network IP',
                    prefixIcon: Icon(Icons.language, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Prefix: /$_cidr',
                      style: GoogleFonts.inter(
                        color: AppColors.accentBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _cidr.toDouble(),
                        min: 0,
                        max: 32,
                        divisions: 32,
                        activeColor: AppColors.accentBlue,
                        inactiveColor: AppColors.navy700,
                        onChanged: (v) => setState(() => _cidr = v.toInt()),
                      ),
                    ),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '$_cidr',
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCIDRFastSelect(),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _calculate,
                    child: const Text('Calculate CIDR'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildResultCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _buildCIDRFastSelect() {
    final presets = [
      ('/24', 24, '254 hosts'),
      ('/25', 25, '126 hosts'),
      ('/26', 26, '62 hosts'),
      ('/27', 27, '30 hosts'),
      ('/28', 28, '14 hosts'),
      ('/29', 29, '6 hosts'),
      ('/30', 30, '2 hosts'),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: presets.map((p) {
        final selected = _cidr == p.$2;
        return GestureDetector(
          onTap: () => setState(() => _cidr = p.$2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppColors.accentBlue.withAlpha(25) : AppColors.navy800,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.accentBlue : AppColors.navy700,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              '${p.$1} (${p.$3})',
              style: GoogleFonts.inter(
                color: selected ? AppColors.accentBlue : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultCard(SubnetResult r) {
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
                '${r.ipAddress}/${r.cidr}',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'Subnet Mask', value: r.subnetMask, highlight: true),
          _InfoRow(label: 'Network', value: r.networkAddress),
          _InfoRow(label: 'Broadcast', value: r.broadcastAddress),
          _InfoRow(label: 'Range', value: '${r.firstUsable} - ${r.lastUsable}'),
          const Divider(color: AppColors.navy700),
          _InfoRow(label: 'Total Hosts', value: '${r.totalHosts}'),
          _InfoRow(label: 'Usable Hosts', value: '${r.usableHosts}'),
          _InfoRow(label: 'Class', value: r.ipClass),
          _InfoRow(label: 'Wildcard', value: _wildcardFromCidr(r.cidr)),
        ],
      ),
    );
  }

  String _wildcardFromCidr(int cidr) {
    final inverted = cidr == 0 ? 0xFFFFFFFF : (~(0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF);
    return '${(inverted >> 24) & 0xFF}.${(inverted >> 16) & 0xFF}.${(inverted >> 8) & 0xFF}.${inverted & 0xFF}';
  }
}

class _IPv4Tab extends StatefulWidget {
  final CalcService calcService;
  const _IPv4Tab({required this.calcService});

  @override
  State<_IPv4Tab> createState() => _IPv4TabState();
}

class _IPv4TabState extends State<_IPv4Tab> {
  final _ipController = TextEditingController();
  IPv4Info? _result;
  String? _error;

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  void _analyze() {
    final ip = _ipController.text.trim();
    if (!widget.calcService.isValidIP(ip)) {
      setState(() => _error = 'Invalid IP address');
      return;
    }
    setState(() {
      _error = null;
      _result = widget.calcService.analyzeIPv4(ip);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _ipController,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'e.g. 192.168.1.1',
                    labelText: 'IP Address',
                    prefixIcon: Icon(Icons.info_outline, color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _analyze,
                    child: const Text('Analyze'),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: GoogleFonts.inter(color: AppColors.errorRed, fontSize: 13),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 16),
            _buildInfoCard(_result!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(IPv4Info info) {
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Class ${info.ipClass}',
                    style: GoogleFonts.inter(
                      color: AppColors.accentBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.ipAddress,
                      style: GoogleFonts.inter(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      info.networkType,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.navy700),
          const SizedBox(height: 8),
          _InfoRow(label: 'Binary', value: info.binary),
          _InfoRow(label: 'Hex', value: info.hex),
          _InfoRow(label: 'Decimal', value: '${info.decimalValue}'),
          _InfoRow(label: 'Class', value: info.ipClass, highlight: true),
          _InfoRow(label: 'Private', value: info.isPrivate ? 'Yes' : 'No'),
          _InfoRow(label: 'Loopback', value: info.isLoopback ? 'Yes' : 'No'),
          _InfoRow(label: 'Multicast', value: info.isMulticast ? 'Yes' : 'No'),
        ],
      ),
    );
  }
}

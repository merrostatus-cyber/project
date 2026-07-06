import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Tools',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a tool to get started',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 24),
              ..._buildToolGroups(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.navy700.withAlpha(50)),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: 'Search tools...',
          hintStyle: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 15),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 22),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  List<Widget> _buildToolGroups(BuildContext context) {
    final groups = [
      _ToolGroup(
        title: 'IP Tools',
        icon: Icons.language,
        gradientStart: AppColors.gradientStart,
        gradientEnd: AppColors.gradientEnd,
        items: [
          _ToolGroupItem(name: 'What Is My IP', desc: 'View your public IP and location', route: '/ip-tools'),
          _ToolGroupItem(name: 'Local IP', desc: 'Your local network address', route: '/ip-tools'),
          _ToolGroupItem(name: 'IP Lookup', desc: 'Look up any IP address', route: '/ip-tools'),
          _ToolGroupItem(name: 'Reverse DNS', desc: 'PTR record lookup', route: '/ip-tools'),
        ],
      ),
      _ToolGroup(
        title: 'Network Tools',
        icon: Icons.wifi_tethering,
        gradientStart: AppColors.gradientGreenStart,
        gradientEnd: AppColors.gradientGreenEnd,
        items: [
          _ToolGroupItem(name: 'Ping', desc: 'Check host reachability', route: '/network-tools'),
          _ToolGroupItem(name: 'Traceroute', desc: 'Trace network path', route: '/network-tools'),
          _ToolGroupItem(name: 'Port Checker', desc: 'Scan common ports', route: '/network-tools'),
        ],
      ),
      _ToolGroup(
        title: 'Calculators',
        icon: Icons.calculate_outlined,
        gradientStart: AppColors.gradientOrangeStart,
        gradientEnd: AppColors.gradientOrangeEnd,
        items: [
          _ToolGroupItem(name: 'Subnet Calculator', desc: 'Calculate network details', route: '/calculators'),
          _ToolGroupItem(name: 'CIDR Calculator', desc: 'CIDR notation helper', route: '/calculators'),
          _ToolGroupItem(name: 'IPv4 Info', desc: 'IP address analysis', route: '/calculators'),
        ],
      ),
      _ToolGroup(
        title: 'Lookup Tools',
        icon: Icons.search,
        gradientStart: AppColors.gradientPurpleStart,
        gradientEnd: AppColors.gradientPurpleEnd,
        items: [
          _ToolGroupItem(name: 'DNS Lookup', desc: 'Resolve domain records', route: '/lookup'),
          _ToolGroupItem(name: 'Whois Lookup', desc: 'IP ownership info', route: '/lookup'),
          _ToolGroupItem(name: 'MAC Vendor', desc: 'Find device manufacturer', route: '/lookup'),
        ],
      ),
      _ToolGroup(
        title: 'Utilities',
        icon: Icons.build_outlined,
        gradientStart: AppColors.gradientCyanStart,
        gradientEnd: AppColors.gradientCyanEnd,
        items: [
          _ToolGroupItem(name: 'Base64', desc: 'Encode / decode Base64', route: '/utilities'),
          _ToolGroupItem(name: 'URL', desc: 'Encode / decode URLs', route: '/utilities'),
          _ToolGroupItem(name: 'Binary', desc: 'Text to / from binary', route: '/utilities'),
          _ToolGroupItem(name: 'Hex', desc: 'Text to / from hex', route: '/utilities'),
        ],
      ),
      _ToolGroup(
        title: 'Wi-Fi Information',
        icon: Icons.wifi,
        gradientStart: AppColors.accentBlue,
        gradientEnd: AppColors.accentBlueDark,
        items: [
          _ToolGroupItem(name: 'Speed Test', desc: 'Internet speed check', route: '/speed-test'),
          _ToolGroupItem(name: 'Network Info', desc: 'Current connection details', route: '/network-tools'),
        ],
      ),
    ];

    final filtered = groups.map((group) {
      final filteredItems = group.items.where((item) {
        return _searchQuery.isEmpty ||
            item.name.toLowerCase().contains(_searchQuery) ||
            item.desc.toLowerCase().contains(_searchQuery) ||
            group.title.toLowerCase().contains(_searchQuery);
      }).toList();
      return _ToolGroup(
        title: group.title,
        icon: group.icon,
        gradientStart: group.gradientStart,
        gradientEnd: group.gradientEnd,
        items: filteredItems,
      );
    }).where((g) => g.items.isNotEmpty).toList();

    return filtered.map((group) => _buildToolGroup(context, group)).toList();
  }

  Widget _buildToolGroup(BuildContext context, _ToolGroup group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [group.gradientStart, group.gradientEnd],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  group.title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...group.items.map((item) => _buildToolCard(context, group, item)),
        ],
      ),
    );
  }

  Widget _buildToolCard(BuildContext context, _ToolGroup group, _ToolGroupItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.navy700.withAlpha(40)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push(item.route),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [group.gradientStart, group.gradientEnd],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: group.gradientStart.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(group.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.desc,
                        style: GoogleFonts.inter(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.navy800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: group.gradientStart,
                    size: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolGroupItem {
  final String name;
  final String desc;
  final String route;
  const _ToolGroupItem({required this.name, required this.desc, required this.route});
}

class _ToolGroup {
  final String title;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final List<_ToolGroupItem> items;
  const _ToolGroup({
    required this.title,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.items,
  });
}

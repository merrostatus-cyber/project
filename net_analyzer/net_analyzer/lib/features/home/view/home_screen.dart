import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/provider/profile_provider.dart';
import '../../ip_tools/service/ip_service.dart';
import '../../ip_tools/model/ip_info_model.dart';

/// Emits a monotonically increasing integer every 30 seconds to trigger
/// automatic network info refreshes while the Home screen is visible.
final _networkRefreshProvider = StreamProvider.autoDispose<int>((ref) {
  final controller = StreamController<int>();
  int count = 0;
  controller.add(count++);
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    controller.add(count++);
  });
  ref.onDispose(() {
    controller.close();
    timer.cancel();
  });
  return controller.stream;
});

final networkInfoProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  ref.watch(_networkRefreshProvider);

  final ipService = IPService();

  LocalIPInfo localIpInfo;
  try {
    localIpInfo = await ipService
        .getLocalIP()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('networkInfoProvider: getLocalIP error — $e');
    localIpInfo = const LocalIPInfo(ip: 'Unavailable');
  }

  IPInfo publicIpInfo;
  try {
    publicIpInfo = await ipService
        .getMyPublicIP()
        .timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint('networkInfoProvider: getMyPublicIP error — $e');
    publicIpInfo = const IPInfo(ip: 'Unavailable');
  }

  bool connected = false;
  try {
    final list = await InternetAddress
        .lookup('google.com')
        .timeout(const Duration(seconds: 5));
    connected = list.isNotEmpty && list[0].rawAddress.isNotEmpty;
  } catch (e) {
    try {
      final list = await InternetAddress
          .lookup('1.1.1.1')
          .timeout(const Duration(seconds: 5));
      connected = list.isNotEmpty && list[0].rawAddress.isNotEmpty;
    } catch (e2) {
      debugPrint('networkInfoProvider: connectivity check error — $e2');
      connected = false;
    }
  }

  return {
    'publicIP': publicIpInfo.ip,
    'localIP': localIpInfo.ip,
    'status': connected ? 'Connected' : 'Disconnected',
    'type': localIpInfo.isWiFi ? 'Wi-Fi' : 'Ethernet',
  };
});

class _ToolItem {
  final String title;
  final String description;
  final IconData icon;
  final Color gradientStart;
  final Color gradientEnd;
  final String route;

  const _ToolItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientStart,
    required this.gradientEnd,
    required this.route,
  });
}

class HomeScreen extends ConsumerWidget {
  final void Function(String path) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final networkInfoAsync = ref.watch(networkInfoProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildAppBar(context, userName),
              const SizedBox(height: 24),
              _buildGreeting(userName),
              const SizedBox(height: 24),
              _buildNetworkOverview(networkInfoAsync),
              const SizedBox(height: 28),
              _buildQuickToolsSection(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String userName) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => _showMenu(context),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.navy700.withAlpha(60)),
            ),
            child: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.navy700,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Menu',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _menuItem(context, Icons.home_rounded, 'Home', '/home'),
              _menuItem(context, Icons.grid_view_rounded, 'Tools', '/tools'),
              _menuItem(context, Icons.person_rounded, 'Profile', '/profile'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.navy800,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accentBlue, size: 20),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.maybeOf(context)?.pop();
        context.go(route);
      },
    );
  }

  Widget _buildGreeting(String userName) {
    final displayName = userName.isNotEmpty ? userName : 'Guest';
    final greeting = _getGreeting();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👋 $greeting, $displayName',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Good to see you again!',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildNetworkOverview(AsyncValue<Map<String, String>> infoAsync) {
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
        border: Border.all(
          color: AppColors.navy700.withAlpha(50),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentBlue.withAlpha(10),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Network Overview',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              const Icon(Icons.wifi, color: AppColors.accentBlue, size: 22),
            ],
          ),
          const SizedBox(height: 20),
          infoAsync.when(
            data: (info) => Column(
              children: [
                ...info.entries.map((e) => _buildInfoRow(e.key, e.value)),
                const SizedBox(height: 16),
                _buildStatusBadge(info['status'] ?? 'Disconnected'),
              ],
            ),
            loading: () => Column(
              children: [
                _buildInfoRow('Public IP', '---'),
                _buildInfoRow('Local IP', '---'),
                _buildInfoRow('Status', 'Scanning...'),
                _buildInfoRow('Type', '---'),
                const SizedBox(height: 16),
                _buildStatusBadge('Checking...'),
              ],
            ),
            error: (_, _) => Column(
              children: [
                _buildInfoRow('Public IP', 'Unavailable'),
                _buildInfoRow('Local IP', 'Unavailable'),
                _buildInfoRow('Status', 'Offline'),
                _buildInfoRow('Type', 'Unknown'),
                const SizedBox(height: 16),
                _buildStatusBadge('Offline'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isConnected = status == 'Connected';
    final color = isConnected ? AppColors.success : AppColors.error;
    final label = status;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatLabel(label),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    switch (key) {
      case 'publicIP': return 'Public IP';
      case 'localIP': return 'Local IP';
      case 'status': return 'Connection Status';
      case 'type': return 'Network Type';
      default: return key;
    }
  }

  Widget _buildQuickToolsSection(BuildContext context) {
    final tools = [
      const _ToolItem(
        title: 'IP Tools',
        description: 'Lookup & analyze IP addresses',
        icon: Icons.language,
        gradientStart: AppColors.gradientStart,
        gradientEnd: AppColors.gradientEnd,
        route: '/ip-tools',
      ),
      const _ToolItem(
        title: 'Network Tools',
        description: 'Ping, port check & more',
        icon: Icons.wifi_tethering,
        gradientStart: AppColors.gradientGreenStart,
        gradientEnd: AppColors.gradientGreenEnd,
        route: '/network-tools',
      ),
      const _ToolItem(
        title: 'Calculators',
        description: 'Subnet, CIDR & IPv4',
        icon: Icons.calculate_outlined,
        gradientStart: AppColors.gradientOrangeStart,
        gradientEnd: AppColors.gradientOrangeEnd,
        route: '/calculators',
      ),
      const _ToolItem(
        title: 'Lookup Tools',
        description: 'DNS, Whois & MAC',
        icon: Icons.search,
        gradientStart: AppColors.gradientPurpleStart,
        gradientEnd: AppColors.gradientPurpleEnd,
        route: '/lookup',
      ),
      const _ToolItem(
        title: 'Utilities',
        description: 'Encode, decode & convert',
        icon: Icons.build_outlined,
        gradientStart: AppColors.gradientCyanStart,
        gradientEnd: AppColors.gradientCyanEnd,
        route: '/utilities',
      ),
      const _ToolItem(
        title: 'Wi-Fi Info',
        description: 'Network details & signal',
        icon: Icons.wifi,
        gradientStart: AppColors.accentBlue,
        gradientEnd: AppColors.accentBlueDark,
        route: '/network-tools',
      ),
      const _ToolItem(
        title: 'Speed Test',
        description: 'Internet speed check',
        icon: Icons.speed,
        gradientStart: AppColors.gradientGreenStart,
        gradientEnd: AppColors.gradientGreenEnd,
        route: '/speed-test',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Tools',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.92,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
          ),
          itemCount: tools.length,
          itemBuilder: (context, index) {
            final tool = tools[index];
            return _QuickToolCard(
              icon: tool.icon,
              title: tool.title,
              description: tool.description,
              gradientStart: tool.gradientStart,
              gradientEnd: tool.gradientEnd,
              onTap: () => onNavigate(tool.route),
            );
          },
        ),
      ],
    );
  }
}

class _QuickToolCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color gradientStart;
  final Color gradientEnd;
  final VoidCallback onTap;

  const _QuickToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onTap,
  });

  @override
  State<_QuickToolCard> createState() => _QuickToolCardState();
}

class _QuickToolCardState extends State<_QuickToolCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isPressed
            ? (Matrix4.identity()..setTranslationRaw(0.0, 2.0, 0.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed
                ? widget.gradientStart.withAlpha(40)
                : AppColors.navy700.withAlpha(50),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.gradientStart.withAlpha(_isPressed ? 15 : 8),
              blurRadius: _isPressed ? 16 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.gradientStart, widget.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradientStart.withAlpha(40),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              const Spacer(),
              Text(
                widget.title,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                widget.description,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

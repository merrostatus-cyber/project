import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  final void Function(String path) onNavigate;

  const ProfileScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(userName),
              const SizedBox(height: 32),
              _buildMenuSection(context, ref, userName),
              const SizedBox(height: 32),
              _buildVersionSection(context, ref),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.accentBlue, AppColors.accentBlueDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentBlue.withAlpha(45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          userName.isNotEmpty ? userName : 'User',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Network Administrator',
            style: GoogleFonts.inter(
              color: AppColors.accentBlue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    String userName,
  ) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        title: 'Change Name',
        subtitle: 'Tap to edit your name',
        trailing: Icons.chevron_right_rounded,
        onTap: () => _showNameEditDialog(context, ref, userName),
      ),
      _MenuItem(
        icon: Icons.info_outline_rounded,
        title: 'About App',
        subtitle: 'Version ${AppConstants.appVersion}',
        trailing: Icons.chevron_right_rounded,
        onTap: () => _showAboutDialog(context),
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        title: 'Privacy Policy',
        subtitle: 'How we handle your data',
        trailing: Icons.open_in_new_rounded,
        onTap: () => _showPrivacyPolicy(context),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
            color: AppColors.accentBlue.withAlpha(8),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: List.generate(menuItems.length, (index) {
          final item = menuItems[index];
          return Column(
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(height: 1, color: AppColors.navy700.withAlpha(50)),
                ),
              _buildMenuTile(item),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildMenuTile(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.navy800,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: AppColors.accentBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (item.trailing != null)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.navy800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.trailing,
                  color: AppColors.textMuted,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersionSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          'NetAnalyzer v${AppConstants.appVersion}',
          style: GoogleFonts.inter(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showLogoutDialog(context, ref),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withAlpha(30)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Logout',
                  style: GoogleFonts.inter(
                    color: AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showNameEditDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Change Name',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.navy800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(ctx);
            },
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueDark],
              ),
            ),
            child: TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  controller.dispose();
                  ref.read(updateUserNameProvider)(name);
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.language_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              AppConstants.appName,
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aboutRow('Version', AppConstants.appVersion),
            const SizedBox(height: 8),
            _aboutRow('Developer', 'NetAnalyzer Team'),
            const SizedBox(height: 8),
            _aboutRow('Platform', 'Flutter + Dart'),
            const SizedBox(height: 16),
            Text(
              'Professional network analysis toolkit for students, network engineers, and cybersecurity learners.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueDark],
              ),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
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
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textMuted)),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.error, AppColors.error],
              ),
            ),
            child: TextButton(
              onPressed: () {
                ref.read(userNameProvider.notifier).state = '';
                Navigator.pop(ctx);
                context.go('/welcome');
              },
              child: Text(
                'Logout',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            'NetAnalyzer respects your privacy.\n\n'
            '• All network scans and lookups are performed locally or via public APIs.\n'
            '• Your name and preferences are stored locally on your device.\n'
            '• No personal data is collected, stored, or transmitted to third parties.\n'
            '• Network tool queries (IP lookups, DNS) are sent to public API endpoints.\n'
            '• No analytics or tracking SDKs are used.\n\n'
            'For questions, contact the developer.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [AppColors.accentBlue, AppColors.accentBlueDark],
              ),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Close',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });
}

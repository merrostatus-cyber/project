import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/view/splash_screen.dart';
import '../../features/onboarding/view/onboarding_screen.dart';
import '../../features/home/view/home_screen.dart';
import '../../features/profile/view/profile_screen.dart';
import '../../features/ip_tools/view/ip_tools_screen.dart';
import '../../features/network_tools/view/network_tools_screen.dart';
import '../../features/calculators/view/calculators_screen.dart';
import '../../features/lookup/view/lookup_screen.dart';
import '../../features/utilities/view/utilities_screen.dart';
import '../../features/tools/view/tools_screen.dart';
import '../../features/speed_test/view/speed_test_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_content.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(String initialLocation) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const OnboardingScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => _HomeShell(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => NoTransitionPage(
                child: HomeScreen(
                  onNavigate: (path) => context.push(path),
                ),
              ),
            ),
            GoRoute(
              path: '/tools',
              pageBuilder: (context, state) => NoTransitionPage(
                child: const ToolsScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => NoTransitionPage(
                child: ProfileScreen(
                  onNavigate: (path) => context.push(path),
                ),
              ),
            ),
          ],
        ),
        GoRoute(path: '/ip-tools', builder: (_, _) => const IPToolsScreen()),
        GoRoute(
          path: '/network-tools',
          builder: (_, _) => const NetworkToolsScreen(),
        ),
        GoRoute(
          path: '/calculators',
          builder: (_, _) => const CalculatorsScreen(),
        ),
        GoRoute(path: '/lookup', builder: (_, _) => const LookupScreen()),
        GoRoute(
          path: '/utilities',
          builder: (_, _) => const UtilitiesScreen(),
        ),
        GoRoute(
          path: '/speed-test',
          builder: (_, _) => const SpeedTestScreen(),
        ),
      ],
    );
  }
}

class _HomeShell extends StatefulWidget {
  final Widget child;
  const _HomeShell({required this.child});

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 1;

  final List<String> _routes = ['/profile', '/home', '/tools'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContent(child: widget.child),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.navy700.withAlpha(60)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index != _currentIndex) {
              setState(() => _currentIndex = index);
              context.go(_routes[index]);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.accentBlue,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view_rounded),
              label: 'Tools',
            ),
          ],
        ),
      ),
    );
  }
}

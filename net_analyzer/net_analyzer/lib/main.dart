import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.getInstance();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: NetAnalyzerApp()));
}

class NetAnalyzerApp extends StatelessWidget {
  final String? initialLocation;

  const NetAnalyzerApp({super.key, this.initialLocation});

  @override
  Widget build(BuildContext context) {
    final location = initialLocation ?? _getInitialLocation();

    return MaterialApp.router(
      title: 'NetAnalyzer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router(location),
    );
  }

  String _getInitialLocation() {
    return '/';
  }
}

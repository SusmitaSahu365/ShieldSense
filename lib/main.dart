// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'engine/risk_engine.dart';
import 'models/risk_model.dart';
import 'screens/setup_screen.dart';
import 'screens/monitor_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF080A0F),
  ));
  runApp(const ProviderScope(child: ShieldSenseApp()));
}

// ─── Router ────────────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const SetupScreen(),
    ),
    GoRoute(
      path: '/monitor',
      builder: (_, __) => const MonitorScreen(),
    ),
  ],
);

// ─── App ───────────────────────────────────────────────────────────────────────
class ShieldSenseApp extends ConsumerWidget {
  const ShieldSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch state changes for navigation
    ref.listen<RiskEngineState>(riskEngineProvider, (prev, next) {
      final ctx = _router.routerDelegate.navigatorKey.currentContext;
      if (ctx == null) return;
      if (next.monitoringState == MonitoringState.monitoring &&
          prev?.monitoringState == MonitoringState.setup) {
        ctx.go('/monitor');
      }
      if (next.monitoringState == MonitoringState.idle &&
          prev?.monitoringState != MonitoringState.idle) {
        ctx.go('/');
      }
    });

    return MaterialApp.router(
      title: 'ShieldSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E5A0),
          surface: Color(0xFF0F1117),
        ),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

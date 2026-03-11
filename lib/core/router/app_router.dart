// lib/core/router/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/splash_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/main_shell_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/dashboard_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/today_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/map_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/stats_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/journal_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/kpi_update_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/onboarding_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/badges_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/deep_work_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/settings_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/weekly_report_page.dart';
import 'package:iron_mind/features/roadmap/presentation/pages/mission_history_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const MissionHistoryPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShellPage(child: child),
        routes: [
          GoRoute(path: '/',        builder: (_, __) => DashboardPage()),
          GoRoute(path: '/today',   builder: (_, __) => const TodayPage()),
          GoRoute(path: '/stats',   builder: (_, __) => const StatsPage()),
          GoRoute(path: '/journal', builder: (_, __) => const JournalPage()),
          GoRoute(path: '/kpi',     builder: (_, __) => const KpiUpdatePage()),
          GoRoute(path: '/badges',  builder: (_, __) => const BadgesPage()),
          GoRoute(path: '/deepwork',builder: (_, __) => const DeepWorkPage()),
          GoRoute(path: '/map',     builder: (_, __) => const MapPage()),
          GoRoute(path: '/settings',builder: (_, __) => const SettingsPage()),
          GoRoute(path: '/report',  builder: (_, __) => const WeeklyReportPage()),
        ],
      ),
    ],
  );
});

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/router/app_router.dart';
import 'package:iron_mind/core/services/hive_service.dart';
import 'package:iron_mind/core/services/notification_service.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialiser Hive (CRITIQUE pour le démarrage)
  try {
    await HiveService.init();
  } catch (e) {
    debugPrint('🚨 Hive Init Error: $e');
  }

  // 2. Lancer les services secondaires en arrière-plan
  unawaited(_initSecondaryServices());

  // Forcer l'orientation portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Style de la barre système
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:            Colors.transparent,
    statusBarIconBrightness:   Brightness.light,
    systemNavigationBarColor:  Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(
    const ProviderScope(
      child: IronMindApp(),
    ),
  );
}

/// Initialise les services qui ne bloquent pas l'affichage du Splash
Future<void> _initSecondaryServices() async {
  try {
    // Demander la permission sur Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
    
    await NotificationService.init();
    await NotificationService.scheduleDailyReminder(hour: 8, minute: 0);
    await NotificationService.scheduleSmartReminders();
  } catch (e) {
    debugPrint('🚨 Secondary Services Error: $e');
  }
}

class IronMindApp extends ConsumerWidget {
  const IronMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router   = ref.watch(routerProvider);
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final variant  = settings?.themeVariant ?? ThemeVariant.emerald;

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'IRON MIND',
          debugShowCheckedModeBanner: false,
          theme: IronMindTheme.build(variant),
          routerConfig: router,
        );
      },
    );
  }
}

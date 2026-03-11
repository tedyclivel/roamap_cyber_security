// lib/features/roadmap/presentation/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/features/roadmap/domain/entities/app_settings_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  late TextEditingController _agentIdController;
  bool _initialized = false;

  @override
  void dispose() {
    _agentIdController.dispose();
    super.dispose();
  }

  void _initIfNeeded(AppSettingsEntity settings) {
    if (!_initialized) {
      _agentIdController = TextEditingController(text: settings.agentId);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ SYSTEM CONFIG', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
      ),
      body: settingsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        error: (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.red))),
        data: (settings) {
          _initIfNeeded(settings);
          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HUDCard(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'AGENT_IDENTITY_PROFILE',
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CORE_COGNITIVE_ID',
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: IronMindColors.glassBorder),
                        ),
                        child: TextField(
                          controller: _agentIdController,
                          style: TextStyle(fontFamily: 'Orbitron', fontSize: 18.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 2),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: Icon(Icons.qr_code_scanner_rounded, color: Theme.of(context).colorScheme.primary, size: 18.w),
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          onSubmitted: (v) {
                            ref.read(appSettingsProvider.notifier).updateSettings(
                              settings.copyWith(agentId: v),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                HUDCard(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'MISSION_HISTORY_MODULE',
                  onTap: () => context.push('/history'),
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(Icons.history_edu_rounded, color: Theme.of(context).colorScheme.primary, size: 24.w),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ARCHIVES DES MISSIONS', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                            Text('Consulte tes rapports passés et tes notes de journal.', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textSecondary)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: Theme.of(context).colorScheme.primary),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                HUDCard(
                  color: Theme.of(context).colorScheme.secondary,
                  label: 'NEURAL_ALERT_CONFIG',
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('NOTIFICATIONS PUSH', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textPrimary)),
                          Switch(
                            value: settings.notificationsEnabled,
                            activeColor: Theme.of(context).colorScheme.secondary,
                            onChanged: (v) {
                              ref.read(appSettingsProvider.notifier).updateSettings(
                                settings.copyWith(notificationsEnabled: v),
                              );
                            },
                          ),
                        ],
                      ),
                      Divider(color: Theme.of(context).colorScheme.secondary, thickness: 0.2),
                      SizedBox(height: 12.h),
                      Text(
                        'HEURE DU RAPPEL : ${settings.notificationHour.toString().padLeft(2, '0')}:00',
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11.sp, color: IronMindColors.textSecondary),
                      ),
                      Slider(
                        value: settings.notificationHour.toDouble(),
                        min: 0,
                        max: 23,
                        divisions: 23,
                        activeColor: Theme.of(context).colorScheme.secondary,
                        inactiveColor: IronMindColors.surfaceVariant,
                        onChanged: (v) {
                           ref.read(appSettingsProvider.notifier).updateSettings(
                             settings.copyWith(notificationHour: v.toInt()),
                           );
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                HUDCard(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'NEURAL_INTERFACE_COLOR',
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HUD_THEME_VARIANT', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textPrimary)),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ThemeVariant.values.map((v) {
                          final isSelected = settings.themeVariant == v;
                          final palette = IronMindPalette.fromVariant(v);
                          return InkWell(
                            onTap: () {
                              ref.read(appSettingsProvider.notifier).updateSettings(
                                settings.copyWith(themeVariant: v),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 64.w,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: isSelected ? palette.primary.withOpacity(0.12) : IronMindColors.card,
                                border: Border.all(
                                  color: isSelected ? palette.primary : IronMindColors.glassBorder,
                                  width: isSelected ? 1.5.w : 1.w,
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: isSelected ? [
                                  BoxShadow(color: palette.primary.withOpacity(0.2), blurRadius: 10.r, spreadRadius: -2.r),
                                ] : null,
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 22.w,
                                    height: 22.w,
                                    decoration: BoxDecoration(
                                      color: palette.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: isSelected ? [
                                        BoxShadow(color: palette.primary.withOpacity(0.6), blurRadius: 8.r),
                                      ] : null,
                                    ),
                                    child: isSelected ? Icon(Icons.check, size: 12.w, color: Colors.black) : null,
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    v.name.toUpperCase().substring(0, 3),
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      fontSize: 9.sp,
                                      color: isSelected ? palette.primary : IronMindColors.textDisabled,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                HUDCard(
                  color: Colors.redAccent,
                  label: 'DANGER_ZONE',
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RÉINITIALISATION DE LA MÉMOIRE',
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: Colors.redAccent),
                      ),
                      SizedBox(height: 8.h),
                      const Text(
                        'Cette action efface définitivement toutes tes données de mission. Aucune récupération possible.',
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: IronMindColors.textDisabled),
                      ),
                      SizedBox(height: 16.h),
                      NeonButton(
                        label: 'SYSTEM_WIPE_DATA',
                        onPressed: () => _showWipeConfirmation(context),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40.h),
                
                Center(
                  child: Text(
                    'IRON MIND OS v1.0.4-STABLE\nENCRYPTED DATA LINK ACTIVE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8.sp, color: IronMindColors.textDisabled.withOpacity(0.5), height: 1.5),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWipeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IronMindColors.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.redAccent, width: 1.w),
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text('[ CRITICAL_ALERT ]', style: TextStyle(fontFamily: 'Orbitron', color: Colors.redAccent, fontSize: 13.sp, letterSpacing: 1)),
        content: Text(
          'WARNING: Cette action est irréversible. Toutes les archives neurales seront définitivement effacées du système.',
          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANNULER', style: TextStyle(fontFamily: 'JetBrainsMono', color: IronMindColors.textDisabled)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              // Fermer impérativement le dialogue avant de détruire les données pour le router
              Navigator.of(context).pop();
              
              await ref.read(repositoryProvider).wipeData();
              if (context.mounted) {
                // Invalidation de tous les providers pour vider le cache mémoire
                ref.invalidate(todayDayProvider);
                ref.invalidate(userProgressProvider);
                ref.invalidate(allDaysProvider);
                ref.invalidate(appSettingsProvider);
                
                // Petit délai pour laisser Hive flusher
                await Future.delayed(const Duration(milliseconds: 300));
                
                if (context.mounted) {
                  context.go('/splash');
                }
              }
            },
            child: Text('PROCEED_WIPE', style: TextStyle(fontFamily: 'Orbitron', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp)),
          ),
        ],
      ),
    );
  }
}

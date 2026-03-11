// lib/features/roadmap/presentation/pages/mission_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:intl/intl.dart';

class MissionHistoryPage extends ConsumerWidget {
  const MissionHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allDaysAsync = ref.watch(allDaysProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ MISSION_LOGS', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (progress) {
          return allDaysAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (allDays) {
              final pastDays = allDays.where((d) => d.dayNumber <= progress.currentDay).toList().reversed.toList();

              if (pastDays.isEmpty) {
                return Center(
                  child: Text(
                    'AUCUNE DONNÉE DE MISSION DISPONIBLE',
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: pastDays.length,
                itemBuilder: (context, index) {
                  final day = pastDays[index];
                  final isCurrent = day.dayNumber == progress.currentDay;
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: HUDCard(
                      color: isCurrent ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                      label: 'DAY_${day.dayNumber.toString().padLeft(3, '0')}',
                      onTap: () => _showDayDetail(context, day),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: (day.isCheckedIn ? IronMindColors.neonGreen : IronMindColors.textDisabled).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: (day.isCheckedIn ? IronMindColors.neonGreen : IronMindColors.textDisabled).withOpacity(0.3)),
                            ),
                            child: Icon(
                              day.isCheckedIn ? Icons.verified_user_rounded : Icons.pending_rounded,
                              color: day.isCheckedIn ? IronMindColors.neonGreen : IronMindColors.textDisabled,
                              size: 18.w,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy').format(day.date).toUpperCase(),
                                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  day.isDayComplete ? 'MISSION_READY' : 'MISSION_INCOMPLETE',
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    color: day.isDayComplete ? IronMindColors.neonGreen : IronMindColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: IronMindColors.textDisabled),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showDayDetail(BuildContext context, RoadmapDayEntity day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: IronMindColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.w)),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: IronMindColors.textDisabled.withOpacity(0.3), borderRadius: BorderRadius.circular(2.r)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOG_ENTRY: DAY_${day.dayNumber}',
                      style: TextStyle(fontFamily: 'Orbitron', fontSize: 18.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      DateFormat('EEEE dd MMMM yyyy').format(day.date).toUpperCase(),
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11.sp, color: IronMindColors.textDisabled),
                    ),
                    
                    SizedBox(height: 32.h),
                    
                    _buildSectionHeader(context, 'TÂCHES_EFFECTUÉES'),
                    if (day.tasks.isEmpty)
                      Text('AUCUNE TÂCHE ENREGISTRÉE', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled))
                    else
                      ...day.tasks.map((task) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          children: [
                            Icon(
                              task.isCompleted ? Icons.check_circle_outline_rounded : Icons.radio_button_unchecked_rounded,
                              color: task.isCompleted ? IronMindColors.neonGreen : IronMindColors.textDisabled,
                              size: 18.w,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                task.title,
                                style: TextStyle(
                                  fontFamily: 'JetBrainsMono',
                                  fontSize: 13.sp,
                                  color: task.isCompleted ? IronMindColors.textPrimary : IronMindColors.textDisabled,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),

                    if (day.journalNote != null && day.journalNote!.isNotEmpty) ...[
                      SizedBox(height: 32.h),
                      _buildSectionHeader(context, 'JOURNAL_DE_BORD'),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: IronMindColors.glassBorder),
                        ),
                        child: Text(
                          day.journalNote!,
                          style: TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 13.sp,
                            color: IronMindColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 32.h),
                      _buildSectionHeader(context, 'JOURNAL_DE_BORD'),
                      Text('AUCUNE NOTE ENREGISTRÉE POUR CE JOUR.', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled)),
                    ],

                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(width: 4.w, height: 16.h, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(fontFamily: 'Orbitron', fontSize: 12.sp, color: Theme.of(context).colorScheme.primary, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}

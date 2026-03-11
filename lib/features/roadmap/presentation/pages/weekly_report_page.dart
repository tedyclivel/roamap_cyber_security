// lib/features/roadmap/presentation/pages/weekly_report_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final daysAsync     = ref.watch(allDaysProvider);
    
    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ WEEKLY NEURAL REPORT', style: TextStyle(fontFamily: 'Orbitron', fontSize: 13.sp, color: IronMindColors.neonCyan, letterSpacing: 2)),
      ),
      body: daysAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: IronMindColors.neonCyan, strokeWidth: 2.w)),
        error:   (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: Colors.red))),
        data: (allDays) {
          final progress = progressAsync.valueOrNull;
          final currentDay = progress?.currentDay ?? 1;
          
          // Récupérer les 7 derniers jours d'activité (ou les n derniers si < 7)
          final last7Days = allDays
              .where((d) => d.dayNumber <= currentDay)
              .toList()
              ..sort((a, b) => a.dayNumber.compareTo(b.dayNumber));
          
          final displayDays = last7Days.length > 7 ? last7Days.sublist(last7Days.length - 7) : last7Days;
          
          // Moyenne de complétion globale sur les jours affichés
          final avgCompletion = displayDays.isEmpty 
              ? 0.0 
              : displayDays.map((d) => d.completionRate).reduce((a, b) => a + b) / displayDays.length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                HUDCard(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'MISSION_SUMMARY_CORE',
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Text(
                        'DISCIPLINE_EFFICIENCY (7D)',
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled, letterSpacing: 2),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '${(avgCompletion * 100).toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Orbitron', 
                          fontSize: 32.sp, 
                          fontWeight: FontWeight.w900, 
                          color: Theme.of(context).colorScheme.primary,
                          shadows: [
                            Shadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 10.r),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        height: 150.h,
                        child: BarChart(
                          BarChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(7, (i) {
                              final rate = i < displayDays.length ? displayDays[i].completionRate : 0.01;
                              return _makeGroup(context, i, rate);
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 20.h),
                
                _DomainPerformanceRow(days: displayDays),
                
                SizedBox(height: 20.h),
                
                HUDCard(
                  color: IronMindColors.neonPurple,
                  label: 'NEURAL_ADVISORY_LOG',
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: IronMindColors.neonPurple.withOpacity(0.7), size: 16.w),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          avgCompletion >= 0.8
                              ? 'STABLE: Ta discipline est exemplaire sur les 7 derniers jours. Maintiens ce niveau d\'intensité pour le prochain cycle neural.'
                              : 'CRITICAL: Alerte de baisse de performance détectée. Recommandation : Reprendre le cycle de sommeil et prioriser le module Physique.',
                          style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11.sp, color: IronMindColors.textPrimary, height: 1.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  BarChartGroupData _makeGroup(BuildContext context, int x, double y) {
    final color = Theme.of(context).colorScheme.primary;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.clamp(0.01, 1.0),
          color: color,
          width: 8.w,
          borderRadius: BorderRadius.circular(2.r),
          backDrawRodData: BackgroundBarChartRodData(show: true, toY: 1.0, color: IronMindColors.surfaceVariant),
        ),
      ],
    );
  }
}

class _DomainPerformanceRow extends StatelessWidget {
  final List<RoadmapDayEntity> days;
  const _DomainPerformanceRow({required this.days});

  @override
  Widget build(BuildContext context) {
    // Calculer la moyenne par domaine
    double calculateDomainAvg(String domainName) {
      if (days.isEmpty) return 0;
      double total = 0;
      int count = 0;
      for (var d in days) {
        final tasks = d.tasks.where((t) => t.domain.name == domainName).toList();
        if (tasks.isEmpty) continue;
        count++;
        final completed = tasks.where((t) => t.isCompleted).length;
        total += completed / tasks.length;
      }
      return count == 0 ? 0 : total / count;
    }

    final cyberAvg = calculateDomainAvg('cyber');
    final algoAvg  = calculateDomainAvg('algorithmique');

    return Row(
      children: [
        Expanded(child: _miniPerfCard('CYBER', (cyberAvg * 100).toInt(), IronMindColors.cyber)),
        SizedBox(width: 12.w),
        Expanded(child: _miniPerfCard('ALGO', (algoAvg * 100).toInt(), IronMindColors.algo)),
      ],
    );
  }

  Widget _miniPerfCard(String label, int val, Color color) {
    return HUDCard(
      color: color,
      label: 'SUB_$label',
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        children: [
          Text('$val%', style: TextStyle(fontFamily: 'Orbitron', fontSize: 20.sp, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}

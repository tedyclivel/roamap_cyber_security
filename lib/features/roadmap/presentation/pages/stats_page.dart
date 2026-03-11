// lib/features/roadmap/presentation/pages/stats_page.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/constants/app_constants.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final allDays       = ref.watch(allDaysProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ STATISTIQUES', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16.sp, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
      ),
      body: progressAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        error:   (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: IronMindColors.error))),
        data:    (progress) => SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              allDays.when(
                loading: () => SizedBox(height: 220.h, child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2))),
                error:   (_, __) => const SizedBox(),
                data: (days) {
                  // Calcul dynamique de la progression par domaine
                  double getProgress(DomainType type) {
                    final tasks = days.expand((d) => d.tasks).where((t) => t.domain == type).toList();
                    if (tasks.isEmpty) return 0.0;
                    final completed = tasks.where((t) => t.isCompleted).length;
                    return completed / tasks.length;
                  }

                  return HUDCard(
                    color: Theme.of(context).colorScheme.primary,
                    label: 'NEURAL_SCAN_OVERVIEW',
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    child: _DomainRadarCard(
                      physiqueProgress:   getProgress(DomainType.physique),
                      algoProgress:       getProgress(DomainType.algorithmique),
                      cyberProgress:      getProgress(DomainType.cyber),
                      linuxProgress:      getProgress(DomainType.linux),
                    ),
                  ).animate().fadeIn(duration: 600.ms);
                },
              ),

              const SizedBox(height: 24),

              // ── KPIs principaux ────────────────────────────────
              const _SectionTitle(title: 'KPI_CORE_METRICS'),
              const SizedBox(height: 16),
              _KpiList(progress: progress)
                  .animate(delay: 200.ms)
                  .fadeIn(),

              const SizedBox(height: 24),

              // ── Heatmap (activité) ─────────────────────────────
              const _SectionTitle(title: 'ACTIVITY_MATRIX_120D'),
              const SizedBox(height: 16),
              allDays.when(
                loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: IronMindColors.neonGreen, strokeWidth: 2))),
                error:   (_, __) => const SizedBox(),
                data:    (days) => _HeatmapGrid(days: days.map((d) => d.completionRate).toList()),
              ).animate(delay: 400.ms).fadeIn(),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 2, height: 12,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10.sp,
            color: IronMindColors.textDisabled,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DomainRadarCard extends StatelessWidget {
  final double physiqueProgress;
  final double algoProgress;
  final double cyberProgress;
  final double linuxProgress;
  const _DomainRadarCard({
    required this.physiqueProgress,
    required this.algoProgress,
    required this.cyberProgress,
    required this.linuxProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.h,
      child: RadarChart(
        RadarChartData(
          dataSets: [
            RadarDataSet(
              fillColor:          Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderColor:        Theme.of(context).colorScheme.primary,
              borderWidth:        2,
              entryRadius:        4,
              dataEntries: [
                RadarEntry(value: (physiqueProgress * 100).clamp(0, 100)),
                RadarEntry(value: (algoProgress * 100).clamp(0, 100)),
                RadarEntry(value: (cyberProgress * 100).clamp(0, 100)),
                RadarEntry(value: (linuxProgress * 100).clamp(0, 100)),
              ],
            ),
          ],
          radarShape:  RadarShape.polygon,
          tickCount:   4,
          ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
          radarBorderData: const BorderSide(color: IronMindColors.glassBorder),
          tickBorderData:  const BorderSide(color: IronMindColors.glassBorder, width: 0.5),
          gridBorderData:  const BorderSide(color: IronMindColors.glassBorder, width: 0.5),
          getTitle: (index, angle) {
            final labels = ['Physique', 'Algo', 'Cyber', 'Linux'];
            return RadarChartTitle(
              text: labels[index],
              angle: 0,
              positionPercentageOffset: 0.2,
            );
          },
          titleTextStyle: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textSecondary),
          titlePositionPercentageOffset: 0.15,
        ),
      ),
    );
  }
}

class _KpiList extends ConsumerWidget {
  final UserProgressEntity progress;
  const _KpiList({required this.progress});

  void _showKpiEditor(BuildContext context, WidgetRef ref, String label, int current, String key) {
    final ctrl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IronMindColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        title: Text('[ EDIT_METRIC ]', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Orbitron', fontSize: 13.sp, letterSpacing: 1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Saisissez la nouvelle valeur cumulée :', style: TextStyle(color: IronMindColors.textSecondary, fontFamily: 'JetBrainsMono', fontSize: 12.sp)),
            SizedBox(height: 16.h),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Orbitron', fontSize: 24.sp, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: '000',
                counterText: label,
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: IronMindColors.glassBorder)),
                focusedBorder: InputBorder.none,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: IronMindColors.textDisabled))),
          TextButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text) ?? current;
              _updateValue(ref, key, val);
              Navigator.pop(ctx);
            },
            child: Text('SAVE_DATA', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontFamily: 'JetBrainsMono')),
          ),
        ],
      ),
    );
  }

  void _updateValue(WidgetRef ref, String key, int val) {
    if (key == 'cf') ref.read(userProgressProvider.notifier).updateKpi(codeforcesProblems: val);
    if (key == 'ctf') ref.read(userProgressProvider.notifier).updateKpi(ctfMachines: val);
    if (key == 'labs') ref.read(userProgressProvider.notifier).updateKpi(cyberLabs: val);
    if (key == 'contests') ref.read(userProgressProvider.notifier).updateKpi(contests: val);
    if (key == 'pompes') ref.read(userProgressProvider.notifier).updateKpi(pompesPR: val);
    if (key == 'gainage') ref.read(userProgressProvider.notifier).updateKpi(gainagePR: val);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = [
      (Icons.fitness_center_rounded, 'Pompes (Record)',       progress.pompesPR,                      AppConstants.targetPompes,         IronMindColors.physique, 'pompes'),
      (Icons.timer_rounded,          'Gainage (secondes)',    progress.gainagePR,                     AppConstants.targetGainage,        IronMindColors.physique, 'gainage'),
      (Icons.code_rounded,           'Problèmes Codeforces',  progress.completedCodeforcesProblems,   AppConstants.targetCodeforces,     IronMindColors.algo,     'cf'),
      (Icons.emoji_events_rounded,   'Contests',              progress.completedContests,             AppConstants.targetContests,       IronMindColors.algo,     'contests'),
      (Icons.security_rounded,       'Machines CTF',          progress.completedCtfMachines,          AppConstants.targetCtfMachines,    IronMindColors.cyber,    'ctf'),
      (Icons.terminal_rounded,       'Labs Cyber',            progress.completedCyberLabs,            40,                                IronMindColors.linux,    'labs'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.8,
      ),
      itemCount: kpis.length,
      itemBuilder: (_, i) {
        final item = kpis[i];
        final pct  = (item.$3 / item.$4).clamp(0.0, 1.0);
        return HUDCard(
          color: item.$5,
          label: 'METRIC_ID:00${i+1}',
          padding: EdgeInsets.all(12.w),
          onTap: () => _showKpiEditor(context, ref, item.$2, item.$3, item.$6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:  MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.$1, size: 14.w, color: item.$5.withOpacity(0.8)),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: item.$5, fontWeight: FontWeight.bold, fontSize: 10.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${item.$3}',
                    style: TextStyle(fontFamily: 'Orbitron', fontSize: 18.sp, fontWeight: FontWeight.w800, color: item.$5),
                  ),
                  Text(
                    ' / ${item.$4}',
                    style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textDisabled),
                  ),
                ],
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: LinearProgressIndicator(
                  value:           pct,
                  minHeight:       3,
                  backgroundColor: IronMindColors.surfaceVariant,
                  valueColor:      AlwaysStoppedAnimation(item.$5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  final List<double> days;
  const _HeatmapGrid({required this.days});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return HUDCard(
      color: primaryColor,
      label: 'ACTIVITY_MATRIX_120D',
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text('Moins', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8.sp, color: IronMindColors.textDisabled)),
              SizedBox(width: 4.w),
              ...[0.1, 0.4, 0.7, 1.0].map((v) => Container(
                width: 8.w, height: 8.w,
                margin: EdgeInsets.symmetric(horizontal: 1.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(v),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              )),
              SizedBox(width: 4.w),
              Text('Plus', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8.sp, color: IronMindColors.textDisabled)),
            ],
          ),
          SizedBox(height: 12.h),

          // Grille 120 jours (24 colonnes × 5 lignes)
          AspectRatio(
            aspectRatio: 24 / 5,
            child: GridView.builder(
              physics:    const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:  24,
                mainAxisSpacing: 2.h,
                crossAxisSpacing: 2.w,
              ),
              itemCount: 120,
              itemBuilder: (context, index) {
                final rate = index < days.length ? days[index] : 0.0;
                final opacity = rate == 0 ? 0.05 : (rate * 0.8) + 0.2;
                return Container(
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(opacity.clamp(0.05, 1.0)),
                    borderRadius: BorderRadius.circular(1.5.r),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

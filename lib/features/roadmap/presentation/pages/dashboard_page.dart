// lib/features/roadmap/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:iron_mind/core/services/sound_service.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final todayAsync    = ref.watch(todayDayProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('IRON MIND', style: TextStyle(fontFamily: 'Orbitron', fontSize: 24.sp, fontWeight: FontWeight.w900, color: IronMindColors.neonGreen, letterSpacing: 2)),
            Text('>_ TABLEAU DE BORD', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12.sp, color: IronMindColors.textDisabled, letterSpacing: 1)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: Icon(Icons.settings, color: IronMindColors.neonGreen, size: 24.w),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 1. BIG PROGRESS HEADER
            progressAsync.when(
              data: (p) => _BigProgressHeader(progress: p),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            SizedBox(height: 16.h),

            // 2. QUOTE CARD
            const _QuoteCard(),

            SizedBox(height: 16.h),

            // 3. MINI STATS CHIPS (Streak, Codeforces, CTF, Pompes)
            progressAsync.when(
              data: (p) => _MiniStatsGrid(progress: p),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            SizedBox(height: 24.h),

            // 4. TODAY SUMMARY
            todayAsync.when(
              data: (day) => _TodaySummaryCard(day: day),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            SizedBox(height: 24.h),

            // 5. 2x2 KPI GRID
            progressAsync.when(
              data: (p) => _KpiSquareGrid(progress: p),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),

            SizedBox(height: 24.h),

            // 6. FOCUS / REPORT ROW
            const _FocusReportRow(),

            SizedBox(height: 24.h),

            // 7. FINAL LARGE BUTTON
            NeonButton(
              label: 'VOIR LES TÂCHES DU JOUR   →',
              onPressed: () => context.go('/today'),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}

class _BigProgressHeader extends StatelessWidget {
  final UserProgressEntity progress;
  const _BigProgressHeader({required this.progress});

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: IronMindColors.glassBorder,
      label: 'CORE_PROGRESS_V2.1',
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('JOUR ${progress.currentDay} / 120', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Niv. ${progress.level}', style: TextStyle(fontFamily: 'Orbitron', fontSize: 12.sp, color: IronMindColors.textPrimary)),
                  Text(UserProgressEntity.levelTitle(progress.level), style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled)),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${(progress.globalProgression * 100).toStringAsFixed(1)}%', style: TextStyle(fontFamily: 'Orbitron', fontSize: 36.sp, fontWeight: FontWeight.w900, color: IronMindColors.neonGreen)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r), border: Border.all(color: Colors.amber.withOpacity(0.4))),
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, size: 14.w, color: Colors.amber),
                    SizedBox(width: 4.w),
                    Text('${progress.currentStreak} jours', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: Colors.amber, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          LinearProgressIndicator(value: progress.globalProgression, backgroundColor: IronMindColors.surfaceVariant, valueColor: const AlwaysStoppedAnimation(IronMindColors.neonGreen), minHeight: 4.h),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('XP', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled)),
              Text('${progress.totalPoints} pts', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled)),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();
  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: IronMindColors.neonPurple.withOpacity(0.3),
      label: 'NEURAL_SYNC_FEED',
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.format_quote_rounded, color: IronMindColors.neonPurple, size: 24.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "La douleur d'aujourd'hui est la force de demain.",
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatsGrid extends StatelessWidget {
  final UserProgressEntity progress;
  const _MiniStatsGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStatItem(label: 'Streak', value: '${progress.currentStreak}j', color: IronMindColors.neonGreen),
        SizedBox(width: 8.w),
        _MiniStatItem(label: 'Codeforces', value: '${progress.completedCodeforcesProblems}', color: IronMindColors.algo),
        SizedBox(width: 8.w),
        _MiniStatItem(label: 'CTF', value: '${progress.completedCtfMachines}', color: IronMindColors.cyber),
        SizedBox(width: 8.w),
        _MiniStatItem(label: 'Pompes PR', value: '${progress.pompesPR}', color: IronMindColors.physique),
      ],
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(color: IronMindColors.card, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: color.withOpacity(0.2))),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 7.sp, color: IronMindColors.textDisabled)),
          ],
        ),
      ),
    );
  }
}

class _TodaySummaryCard extends StatelessWidget {
  final dynamic day;
  const _TodaySummaryCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: IronMindColors.neonCyan,
      label: 'BIO_SYNC:PENDING',
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AUJOURD\'HUI', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, color: IronMindColors.neonCyan, letterSpacing: 1)),
          SizedBox(height: 4.h),
          Text(day.phaseLabel, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled)),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: LinearProgressIndicator(value: 0, backgroundColor: IronMindColors.surfaceVariant, valueColor: const AlwaysStoppedAnimation(IronMindColors.neonCyan), minHeight: 4.h)),
              SizedBox(width: 12.w),
              Text('${(day.completionRate * 100).toInt()}%', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, fontWeight: FontWeight.bold, color: IronMindColors.neonCyan)),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiSquareGrid extends StatelessWidget {
  final UserProgressEntity progress;
  const _KpiSquareGrid({required this.progress});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      children: [
        _KpiSquare(label: 'Pompes PR', value: '${progress.pompesPR}', target: '60', color: IronMindColors.physique, icon: Icons.fitness_center, index: '001'),
        _KpiSquare(label: 'Codeforces', value: '${progress.completedCodeforcesProblems}', target: '150', color: IronMindColors.algo, icon: Icons.code, index: '002'),
        _KpiSquare(label: 'CTF Machines', value: '${progress.completedCtfMachines}', target: '40', color: IronMindColors.cyber, icon: Icons.security, index: '003'),
        _KpiSquare(label: 'Labs Cyber', value: '${progress.completedCyberLabs}', target: '40', color: Colors.amber, icon: Icons.terminal, index: '004'),
      ],
    );
  }
}

class _KpiSquare extends StatelessWidget {
  final String label;
  final String value;
  final String target;
  final Color color;
  final IconData icon;
  final String index;
  const _KpiSquare({required this.label, required this.value, required this.target, required this.color, required this.icon, required this.index});

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: color,
      label: 'SUB-SYS:$index',
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.w),
              SizedBox(width: 6.w),
              Text(label, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: TextStyle(fontFamily: 'Orbitron', fontSize: 18.sp, fontWeight: FontWeight.w900, color: color)),
              Text(' / $target', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textDisabled)),
            ],
          ),
          SizedBox(height: 2.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(value: 0.1, backgroundColor: color.withOpacity(0.1), valueColor: AlwaysStoppedAnimation(color), minHeight: 2.h),
          ),
        ],
      ),
    );
  }
}

class _FocusReportRow extends ConsumerWidget {
  const _FocusReportRow();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dwState = ref.watch(deepWorkProvider);
    final h = (dwState.seconds / 3600).floor().toString().padLeft(2, '0');
    final m = ((dwState.seconds % 3600) / 60).floor().toString().padLeft(2, '0');
    final s = (dwState.seconds % 60).floor().toString().padLeft(2, '0');
    final timeStr = '$h:$m:$s';

    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/deepwork'),
              child: HUDCard(
                color: IronMindColors.neonPurple,
                label: 'DEEP_WORK_CPU',
                padding: EdgeInsets.fromLTRB(12.w, 28.h, 12.w, 16.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.psychology_rounded,
                        color: dwState.isActive ? IronMindColors.neonPurple : IronMindColors.textDisabled,
                        size: 28.w),
                    SizedBox(height: 6.h),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: dwState.isActive ? IronMindColors.neonPurple : IronMindColors.textPrimary,
                      ),
                    ),
                    Text(
                      dwState.isActive ? 'EN COURS  ▶' : 'DEEP FOCUS',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 8.sp,
                        color: dwState.isActive ? IronMindColors.neonPurple : IronMindColors.textDisabled,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/report'),
              child: HUDCard(
                color: IronMindColors.neonCyan,
                label: 'NEURAL_REPORT',
                padding: EdgeInsets.fromLTRB(12.w, 28.h, 12.w, 16.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded, color: IronMindColors.neonCyan, size: 28.w),
                    SizedBox(height: 16.h),
                    Text('RAPPORT',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 13.sp,
                          color: IronMindColors.textPrimary,
                          letterSpacing: 1.5,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

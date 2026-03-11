// lib/features/roadmap/presentation/pages/today_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/core/services/sound_service.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/domain_type.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/task_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';

class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  bool _showCheckin = false;
  bool _isSyncing   = false;
  int  _mood        = 3;
  final _journalCtrl = TextEditingController();

  @override
  void dispose() {
    _journalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayAsync = ref.watch(todayDayProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: dayAsync.maybeWhen(
          data: (d) => Column(
            children: [
              Text('JOUR ${d.dayNumber} / 120',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
              Text(d.phaseLabel,
                style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textSecondary)),
            ],
          ),
          orElse: () => const Text('AUJOURD\'HUI'),
        ),
      ),
      body: Stack(
        children: [
          dayAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
            error:   (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: IronMindColors.error))),
            data:    (day) => _buildContent(day),
          ),
          if (_isSyncing) const _CyberSyncOverlay(),
        ],
      ),
    );
  }

  Widget _buildContent(RoadmapDayEntity day) {
    final domains = DomainType.values;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(20.w),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Progression du jour ─────────────────────────────
              _DayProgressHeader(day: day),

              SizedBox(height: 20.h),

              // ── Tâches par domaine ──────────────────────────────
              ...domains.map((domain) {
                final tasks = day.tasks.where((t) => t.domain == domain && !t.isBonus).toList();
                if (tasks.isEmpty) return const SizedBox();
                return _DomainSection(
                  domain:   domain,
                  tasks:    tasks,
                  onToggle: (taskId, val) async {
                    await ref.read(todayDayProvider.notifier).toggleTask(taskId, val);
                    if (val) await SoundService.taskComplete();
                  },
                ).animate().fadeIn(delay: Duration(milliseconds: 100 * domains.indexOf(domain)));
              }),

              // ── Défis bonus ─────────────────────────────────────
              if (day.bonusTasks.isNotEmpty) ...[
                SizedBox(height: 8.h),
                _BonusSection(
                  tasks:    day.bonusTasks,
                  onToggle: (taskId, val) => ref.read(todayDayProvider.notifier).toggleTask(taskId, val),
                ).animate(delay: 500.ms).fadeIn(),
              ],

              SizedBox(height: 20.h),

              // ── Check-in quotidien ───────────────────────────────
              if (!day.isCheckedIn) ...[
                if (day.isDayComplete) ...[
                  NeonButton(
                    label:      'VALIDER LA JOURNÉE  ✓',
                    onPressed:  () => setState(() => _showCheckin = true),
                    color:      Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 12.h),
                ] else ...[
                  HUDCard(
                    color: IronMindColors.textDisabled,
                    label: 'SYSTEM_LOCK',
                    padding: EdgeInsets.all(16.w),
                    child: Center(
                      child: Text(
                        'ACHEVEZ TOUTES LES MISSIONS REQUISES POUR VALIDER LA JOURNÉE.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.textDisabled, letterSpacing: 1),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                ]
              ] else
                _CheckInDone(day: day),

              if (_showCheckin)
                _CheckInSheet(
                  mood:       _mood,
                  controller: _journalCtrl,
                  onMood:     (v) => setState(() => _mood = v),
                  onConfirm: () async {
                    setState(() => _showCheckin = false);
                    await ref.read(todayDayProvider.notifier).checkIn(
                      journalNote: _journalCtrl.text.trim(),
                      moodScore:   _mood,
                    );
                    _journalCtrl.clear();
                    await SoundService.checkIn();
                    
                    if (mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: IronMindColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.w),
                          ),
                          title: Row(
                            children: [
                              Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 24.w),
                              SizedBox(width: 8.w),
                              Expanded(child: Text('JOURNÉE VALIDÉE', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontFamily: 'Orbitron', fontSize: 16.sp))),
                            ],
                          ),
                          content: Text(
                            'Excellent travail. Vos statistiques ont été mises à jour pour cette session.\n\nPréparez-vous pour le jour suivant.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontFamily: 'JetBrainsMono', fontSize: 13.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                Navigator.of(ctx).pop();
                                
                                // Lancer l'animation cyber
                                setState(() => _isSyncing = true);
                                await SoundService.playBeep();
                                
                                // Attendre la fin de l'animation
                                await Future.delayed(const Duration(milliseconds: 2800));
                                
                                if (mounted) {
                                  setState(() => _isSyncing = false);
                                  // Forcer le rafraîchissement pour voir le jour suivant
                                  ref.invalidate(todayDayProvider);
                                }
                              },
                              child: Text('OK', style: TextStyle(color: IronMindColors.neonCyan, fontFamily: 'JetBrainsMono', fontWeight: FontWeight.bold, fontSize: 16.sp)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ).animate().fadeIn().slideY(begin: 0.3),

              SizedBox(height: 40.h),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────

class _DayProgressHeader extends StatelessWidget {
  final RoadmapDayEntity day;
  const _DayProgressHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    final pct = day.completionRate;
    return HUDCard(
      color: Theme.of(context).colorScheme.secondary,
      label: 'DAILY_SYNC_STATUS',
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${day.requiredTasks.where((t) => t.isCompleted).length} / ${day.requiredTasks.length} tâches',
                style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textSecondary),
              ),
              Text(
                '${(pct * 100).toInt()}%',
                style: TextStyle(fontFamily: 'Orbitron', fontSize: 18.sp, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 800),
              builder: (_, v, __) => LinearProgressIndicator(
                value:         v,
                minHeight:     10.h,
                backgroundColor: IronMindColors.surfaceVariant,
                valueColor:    AlwaysStoppedAnimation(Theme.of(context).colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DomainSection extends StatelessWidget {
  final DomainType         domain;
  final List<TaskEntity>   tasks;
  final void Function(String, bool) onToggle;

  const _DomainSection({required this.domain, required this.tasks, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isCompleted).length;
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: HUDCard(
        color: domain.color,
        label: 'DOMAIN_LINK_${domain.name.toUpperCase()}',
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(domain.icon, size: 18.w, color: domain.color),
                SizedBox(width: 8.w),
                Text(
                  domain.label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color:      domain.color,
                    letterSpacing: 2,
                    fontSize: 12.sp,
                  ),
                ),
                const Spacer(),
                Text(
                  '$completedCount/${tasks.length}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: domain.color.withOpacity(0.7), fontSize: 10.sp),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            ...tasks.map((task) => _TaskTile(task: task, onToggle: onToggle)),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final TaskEntity task;
  final void Function(String, bool) onToggle;
  const _TaskTile({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle(task.id, !task.isCompleted),
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? task.domain.color.withOpacity(0.08)
              : IronMindColors.card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: task.isCompleted
                ? task.domain.color.withOpacity(0.5)
                : IronMindColors.glassBorder,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? task.domain.color : Colors.transparent,
                border: Border.all(color: task.domain.color, width: 1.5.w),
              ),
              child: task.isCompleted
                  ? Icon(Icons.check, size: 14.w, color: Colors.black)
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: task.isCompleted ? IronMindColors.textDisabled : IronMindColors.textPrimary,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          fontSize: 14.sp,
                        ),
                  ),
                  if (task.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: IronMindColors.textSecondary,
                            height: 1.4,
                            fontSize: 11.sp,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '+${task.points}',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 10.sp,
                color: task.isCompleted ? task.domain.color : IronMindColors.textDisabled,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BonusSection extends StatelessWidget {
  final List<TaskEntity> tasks;
  final void Function(String, bool) onToggle;
  const _BonusSection({required this.tasks, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: Theme.of(context).colorScheme.tertiary,
      label: 'ELITE_CHALLENGE_STREAM',
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt_rounded, color: Theme.of(context).colorScheme.tertiary, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'DÉFIS AVANCÉS',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.tertiary, letterSpacing: 2, fontSize: 12.sp),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'Optionnel — Pour aller au-delà des objectifs',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: IronMindColors.textSecondary, fontSize: 11.sp),
          ),
          SizedBox(height: 12.h),
          ...tasks.map((t) => _TaskTile(task: t, onToggle: onToggle)),
        ],
      ),
    );
  }
}

class _CheckInDone extends StatelessWidget {
  final RoadmapDayEntity day;
  const _CheckInDone({required this.day});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HUDCard(
          color: Theme.of(context).colorScheme.primary,
          label: 'BIO_LOCK_TERMINATED',
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_rounded, color: Theme.of(context).colorScheme.primary, size: 22.w),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'JOURNÉE VALIDÉE — EXCELLENT TRAVAIL.',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, letterSpacing: 1, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
        if (day.journalNote != null && day.journalNote!.isNotEmpty) ...[
          SizedBox(height: 16.h),
          HUDCard(
            color: IronMindColors.textDisabled,
            label: 'JOURNAL_ENTRY_RECAP',
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.history_edu_rounded, size: 14.w, color: IronMindColors.textDisabled),
                    SizedBox(width: 8.w),
                    Text('NOTES ENREGISTRÉES :', style: TextStyle(fontFamily: 'Orbitron', fontSize: 10.sp, color: IronMindColors.textDisabled)),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  day.journalNote!,
                  style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CyberSyncOverlay extends StatelessWidget {
  const _CyberSyncOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner ADN / Bio effect
            Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 2.w),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.psychology_outlined, size: 80.w, color: Theme.of(context).colorScheme.primary)
                      .animate(onPlay: (c) => c.repeat())
                      .custom(
                        duration: 1.seconds,
                        builder: (context, value, child) => Opacity(
                          opacity: (value * 10).toInt() % 2 == 0 ? 1.0 : 0.4,
                          child: child,
                        ),
                      )
                      .shimmer(duration: 2.seconds),
                  CircularProgressIndicator(
                    strokeWidth: 2.w,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary.withOpacity(0.5)),
                  ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Text(
              'SYNCHRONISATION NEURALE...',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ).animate(onPlay: (c) => c.repeat()).fadeOut(delay: 500.ms, duration: 500.ms, curve: Curves.easeInOut).fadeIn(),
            SizedBox(height: 15.h),
            SizedBox(
              width: 250.w,
              child: Column(
                children: [
                  _LogLine(text: '> CALCULATING STREAK...', delay: 200),
                  _LogLine(text: '> UPDATING KPI DATABASE...', delay: 600),
                  _LogLine(text: '> SECURING BACKUP...', delay: 1000),
                  _LogLine(text: '> ACCESS GRANTED: NEXT LEVEL', delay: 1400, color: IronMindColors.neonCyan),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final String text;
  final int delay;
  final Color color;

  const _LogLine({required this.text, required this.delay, this.color = IronMindColors.textDisabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 8.sp,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.1, delay: delay.ms);
  }
}

class _CheckInSheet extends StatelessWidget {
  final int                mood;
  final TextEditingController controller;
  final void Function(int)  onMood;
  final VoidCallback        onConfirm;
  const _CheckInSheet({required this.mood, required this.controller, required this.onMood, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: IronMindColors.neonGreen,
      label: 'MISSION_LOG_INPUT',
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('HUMEUR DU JOUR', style: TextStyle(fontFamily: 'Orbitron', fontSize: 10.sp, color: IronMindColors.textSecondary, letterSpacing: 2)),
          SizedBox(height: 10.h),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            spacing: 6.w,
            runSpacing: 8.h,
            children: [
              'CRIT', 'LOW', 'STABLE', 'HIGH', 'ELITE'
            ].asMap().entries.map((e) {
              final i      = e.key + 1;
              final label  = e.value;
              final active = i == mood;
              return GestureDetector(
                onTap: () => onMood(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color:        active ? IronMindColors.neonGreen.withOpacity(0.15) : IronMindColors.card,
                    borderRadius: BorderRadius.circular(4.r),
                    border:       Border.all(color: active ? IronMindColors.neonGreen : IronMindColors.glassBorder),
                  ),
                  child: Text(
                    '[$label]',
                    style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 10.sp,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      color: active ? IronMindColors.neonGreen : IronMindColors.textDisabled,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: controller,
            maxLines: 3,
            style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Note du jour (optionnel)...',
              border: InputBorder.none,
            ),
          ),
          SizedBox(height: 12.h),
          NeonButton(label: 'CONFIRMER', onPressed: onConfirm), 
        ],
      ),
    );
  }
}

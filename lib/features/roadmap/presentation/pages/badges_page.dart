// lib/features/roadmap/presentation/pages/badges_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/badge_entity.dart';
import 'package:iron_mind/features/roadmap/domain/entities/user_progress_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';

class BadgesPage extends ConsumerWidget {
  const BadgesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text(
          '>_ BADGES & TROPHÉES',
          style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: Theme.of(context).colorScheme.primary, letterSpacing: 2),
        ),
      ),
      body: progressAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)),
        error:   (e, _) => Center(child: Text('Erreur: $e', style: const TextStyle(color: IronMindColors.error))),
        data:    (progress) {
          final catalog   = BadgeEntity.catalog();
          final unlocked  = progress.unlockedBadgeIds.toSet();
          final unlockedList = catalog.where((b) => unlocked.contains(b.id)).toList();
          final lockedList   = catalog.where((b) => !unlocked.contains(b.id)).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Résumé ──────────────────────────────────────
                _SummaryCard(
                  unlocked:  unlockedList.length,
                  total:     catalog.length,
                  progress:  progress,
                ).animate().fadeIn(duration: 600.ms),

                const SizedBox(height: 24),

                // ── Débloqués ────────────────────────────────────
                if (unlockedList.isNotEmpty) ...[
                  _SectionTitle(' BADGES DÉBLOQUÉS (${unlockedList.length})'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics:    const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:   3,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing:  10,
                    ),
                    itemCount: unlockedList.length,
                    itemBuilder: (_, i) => _BadgeCard(badge: unlockedList[i], unlocked: true)
                        .animate(delay: Duration(milliseconds: i * 80)).fadeIn().scale(),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Verrouillés ──────────────────────────────────
                _SectionTitle(' À DÉBLOQUER (${lockedList.length})'),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics:    const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:   3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing:  10,
                  ),
                  itemCount: lockedList.length,
                  itemBuilder: (_, i) => _BadgeCard(badge: lockedList[i], unlocked: false)
                      .animate(delay: Duration(milliseconds: 300 + i * 60)).fadeIn(),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets internes ──────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int                 unlocked;
  final int                 total;
  final UserProgressEntity  progress;
  const _SummaryCard({required this.unlocked, required this.total, required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? unlocked / total : 0.0;
    return HUDCard(
      color: Theme.of(context).colorScheme.primary,
      label: 'TROPHY_SYNC_SUMMARY',
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🏆', style: TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlocked / $total badges',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Niv. ${progress.level} — ${UserProgressEntity.levelTitle(progress.level)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: IronMindColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 1000),
              builder: (_, v, __) => LinearProgressIndicator(
                value:         v,
                minHeight:     6,
                backgroundColor: IronMindColors.surfaceVariant,
                valueColor:    AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(color: IronMindColors.textSecondary, letterSpacing: 2),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final BadgeEntity badge;
  final bool        unlocked;
  const _BadgeCard({required this.badge, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? Theme.of(context).colorScheme.primary : IronMindColors.textDisabled;
    return HUDCard(
      color: color,
      label: unlocked ? 'SECURED' : 'LOCKED',
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge.icon,
            size: unlocked ? 34 : 28,
            color: unlocked ? color : color.withOpacity(0.2),
          ),
          const SizedBox(height: 6),
          Text(
            badge.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily:  'Orbitron',
              fontSize:    8,
              fontWeight:  FontWeight.w700,
              color:       color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            badge.description,
            textAlign: TextAlign.center,
            maxLines:  2,
            overflow:  TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 8,
              color: IronMindColors.textDisabled,
            ),
          ),
          if (unlocked) ...[
            const SizedBox(height: 6),
            Icon(Icons.check_circle_rounded, size: 10, color: Theme.of(context).colorScheme.primary),
          ],
        ],
      ),
    );
  }
}

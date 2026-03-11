// lib/features/roadmap/presentation/pages/journal_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final day = ref.read(todayDayProvider).valueOrNull;
    if (day == null) return;
    await ref.read(todayDayProvider.notifier).saveJournalNote(_ctrl.text.trim());
    _ctrl.clear(); // Vider le champ de texte une fois enregistré
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Note sauvegardée ✓', style: TextStyle(fontFamily: 'JetBrainsMono', color: Theme.of(context).colorScheme.primary)),
          backgroundColor: IronMindColors.card,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayAsync = ref.watch(todayDayProvider);
    final allAsync = ref.watch(allDaysProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ JOURNAL', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Note du jour ────────────────────────────────────
            dayAsync.when(
              loading: () => const SizedBox(),
              error:   (_, __) => const SizedBox(),
              data:    (day) {
                // La zone de texte est toujours vide pour qu'on puisse ajouter une nouvelle note (concaténée dans le backend)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'JOUR ${day.dayNumber} — NOTE DU JOUR',
                      style: TextStyle(fontFamily: 'Orbitron', fontSize: 11, color: Theme.of(context).colorScheme.primary, letterSpacing: 2),
                    ),
                    const SizedBox(height: 12),
                    HUDCard(
                      color: IronMindColors.neonGreen,
                      label: 'MISSION_LOG_ENTRY',
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller:   _ctrl,
                        maxLines:     8,
                        style:        const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: IronMindColors.textPrimary, height: 1.6),
                        decoration:   const InputDecoration(
                          border:   InputBorder.none,
                          hintText: 'Qu\'as-tu accompli aujourd\'hui ?\nQuelles ont été tes difficultés ?\nQu\'as-tu appris ?',
                          hintStyle: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: IronMindColors.textDisabled, height: 1.6),
                          filled: false,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    NeonButton(label: _saving ? 'SAUVEGARDE...' : 'SAUVEGARDER  ✓', onPressed: _saving ? null : _save),
                  ],
                );
              },
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 32),

            // ── Historique ──────────────────────────────────────
            const Text(
              'ENTRÉES PRÉCÉDENTES',
              style: TextStyle(fontFamily: 'Orbitron', fontSize: 11, color: IronMindColors.textSecondary, letterSpacing: 3),
            ),
            const SizedBox(height: 12),

            allAsync.when(
              loading: () => Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)),
              error:   (_, __) => const SizedBox(),
              data:    (days) {
                final withNotes = days.where((d) => d.journalNote != null && d.journalNote!.isNotEmpty).toList()
                  ..sort((a, b) => b.dayNumber.compareTo(a.dayNumber));

                if (withNotes.isEmpty) {
                  return const Center(
                    child: Text('Aucune entrée encore.', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: IronMindColors.textDisabled)),
                  );
                }

                return Column(
                  children: withNotes.take(10).map((d) =>
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: HUDCard(
                        color: IronMindColors.textSecondary,
                        label: 'ARCHIVE_DATA_ID:${d.dayNumber}',
                        padding: const EdgeInsets.all(14),
                        onTap: () => _showArchiveDetail(context, d),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Row(
                                children: [
                                  Text(
                                    'JOUR ${d.dayNumber}',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: IronMindColors.neonGreen,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    [
                                      Icons.sentiment_very_dissatisfied_rounded,
                                      Icons.sentiment_dissatisfied_rounded,
                                      Icons.sentiment_neutral_rounded,
                                      Icons.sentiment_satisfied_rounded,
                                      Icons.sentiment_very_satisfied_rounded,
                                    ][d.moodScore - 1],
                                    size: 18,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  ),
                                  Text(
                                    d.date.toString().substring(0, 10),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: IronMindColors.textDisabled),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.open_in_new_rounded, size: 14, color: IronMindColors.textDisabled),
                                ],
                              ),
                            const SizedBox(height: 8),
                            Text(
                              d.journalNote!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).toList(),
                );
              },
            ).animate(delay: 200.ms).fadeIn(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showArchiveDetail(BuildContext context, dynamic day) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Hero(
            tag: 'archive_${day.dayNumber}',
            child: Material(
              color: Colors.transparent,
              child: HUDCard(
                color: IronMindColors.neonGreen,
                label: 'MISSION_LOG_READOUT:J${day.dayNumber}',
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'JOUR ${day.dayNumber}',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: IronMindColors.textDisabled),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(color: Theme.of(context).colorScheme.primary, thickness: 0.5, height: 24),
                    Text(
                      day.date.toString().substring(0, 10),
                      style: const TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 12,
                        color: IronMindColors.textDisabled,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Text(
                          day.journalNote ?? '',
                          style: const TextStyle(
                            fontFamily: 'JetBrainsMono',
                            fontSize: 14,
                            color: IronMindColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeonButton(
                      label: 'FERMER LE LOG',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

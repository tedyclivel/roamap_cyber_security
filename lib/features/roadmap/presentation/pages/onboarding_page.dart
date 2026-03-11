// lib/features/roadmap/presentation/pages/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  DateTime _startDate = DateTime.now();
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    final repo = ref.read(repositoryProvider);
    await repo.initializeRoadmap(_startDate);
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {},
      child: Scaffold(
        backgroundColor: IronMindColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
  
                // Header
                const Text(
                  '>_ BIENVENUE,',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: IronMindColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(duration: 600.ms),
  
                const SizedBox(height: 8),
  
                Text(
                  'IRON MIND',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 4,
                  ),
                ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.3),
  
                const SizedBox(height: 24),
  
                const Text(
                  'Ton programme de performance élite sur 120 jours commence maintenant.\n\n'
                  'Physique. Algorithmique. Cybersécurité. Mental.',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: IronMindColors.textSecondary,
                    height: 1.8,
                  ),
                ).animate(delay: 400.ms).fadeIn(),
  
                const SizedBox(height: 40),
  
                // Domaines
                ...[
                  (Icons.fitness_center_rounded, 'Physique',      IronMindColors.physique,  '60 pompes • Posture • +4 kg muscle'),
                  (Icons.code_rounded,           'Algorithmique', IronMindColors.algo,      '150+ problèmes Codeforces • 8 contests'),
                  (Icons.security_rounded,       'Cybersécurité', IronMindColors.cyber,     '40 machines CTF • Red Team Junior'),
                  (Icons.psychology_rounded,     'Mental',        IronMindColors.mental,    '4–5h Deep Work • Discipline totale'),
                ].asMap().entries.map((e) {
                  final i = e.key;
                  final d = e.value;
                  return _DomainCard(
                    icon:        d.$1,
                    label:       d.$2,
                    color:       d.$3,
                    description: d.$4,
                  ).animate(delay: Duration(milliseconds: 600 + i * 100)).fadeIn().slideX(begin: 0.2);
                }),
  
                const Spacer(),
  
                // Date de démarrage
                HUDCard(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'INIT_SEQUENCE_START_DATE',
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context:     context,
                      initialDate: _startDate,
                      firstDate:   DateTime(2024),
                      lastDate:    DateTime(2027),
                      builder: (context, child) => Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(primary: Theme.of(context).colorScheme.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setState(() => _startDate = picked);
                  },
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary, size: 18),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date de démarrage', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: IronMindColors.textSecondary)),
                          Text(
                            '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                            style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: IronMindColors.textSecondary, size: 18),
                    ],
                  ),
                ).animate(delay: 1100.ms).fadeIn(),
  
                const SizedBox(height: 16),
  
                NeonButton(
                  label: _loading ? 'INITIALISATION...' : 'DÉMARRER LA ROADMAP  >_',
                  onPressed: _loading ? null : _start,
                ).animate(delay: 1300.ms).fadeIn().slideY(begin: 0.3),
  
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String description;

  const _DomainCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return HUDCard(
      color: color,
      label: 'SIG_SCAN_${label.substring(0, 3).toUpperCase()}',
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: TextStyle(fontFamily: 'Orbitron', fontSize: 12, color: color, fontWeight: FontWeight.w700, letterSpacing: 1)),
              Text(description, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: IronMindColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

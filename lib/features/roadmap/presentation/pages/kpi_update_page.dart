// lib/features/roadmap/presentation/pages/kpi_update_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/constants/app_constants.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';

class KpiUpdatePage extends ConsumerStatefulWidget {
  const KpiUpdatePage({super.key});

  @override
  ConsumerState<KpiUpdatePage> createState() => _KpiUpdatePageState();
}

class _KpiUpdatePageState extends ConsumerState<KpiUpdatePage> {
  final _codeforces = TextEditingController();
  final _ctf        = TextEditingController();
  final _labs       = TextEditingController();
  final _contests   = TextEditingController();
  final _pompes     = TextEditingController();
  final _gainage    = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentValues();
  }

  void _loadCurrentValues() {
    final p = ref.read(userProgressProvider).valueOrNull;
    if (p == null) return;
    _codeforces.text = p.completedCodeforcesProblems.toString();
    _ctf.text        = p.completedCtfMachines.toString();
    _labs.text       = p.completedCyberLabs.toString();
    _contests.text   = p.completedContests.toString();
    _pompes.text     = p.pompesPR.toString();
    _gainage.text    = p.gainagePR.toString();
  }

  @override
  void dispose() {
    _codeforces.dispose(); _ctf.dispose(); _labs.dispose();
    _contests.dispose();   _pompes.dispose(); _gainage.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(userProgressProvider.notifier).updateKpi(
      codeforcesProblems: int.tryParse(_codeforces.text),
      ctfMachines:        int.tryParse(_ctf.text),
      cyberLabs:          int.tryParse(_labs.text),
      contests:           int.tryParse(_contests.text),
      pompesPR:           int.tryParse(_pompes.text),
      gainagePR:          int.tryParse(_gainage.text),
    );
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('KPIs mis à jour ✓', style: TextStyle(fontFamily: 'JetBrainsMono', color: Theme.of(context).colorScheme.primary)),
          backgroundColor: IronMindColors.card,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        title: Text('>_ MISE À JOUR KPIs', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14, color: Theme.of(context).colorScheme.primary, letterSpacing: 2)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mets à jour tes progrès réels pour chaque domaine.',
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: IronMindColors.textSecondary, height: 1.6),
            ).animate().fadeIn(duration: 600.ms),

            const SizedBox(height: 24),

            _kpiSection('PHYSIQUE', Icons.fitness_center_rounded, IronMindColors.physique, [
              _KpiField('Pompes (record personnel)',  _pompes,     AppConstants.targetPompes),
              _KpiField('Gainage (secondes)',          _gainage,    AppConstants.targetGainage),
            ]).animate(delay: 100.ms).fadeIn(),

            _kpiSection('ALGORITHMIQUE', Icons.code_rounded, IronMindColors.algo, [
              _KpiField('Problèmes Codeforces',       _codeforces, AppConstants.targetCodeforces),
              _KpiField('Contests participés',         _contests,   AppConstants.targetContests),
            ]).animate(delay: 200.ms).fadeIn(),

            _kpiSection('CYBERSÉCURITÉ', Icons.security_rounded, IronMindColors.cyber, [
              _KpiField('Machines CTF résolues',      _ctf,        AppConstants.targetCtfMachines),
              _KpiField('Labs Cyber (TryHackMe...)',   _labs,       40),
            ]).animate(delay: 300.ms).fadeIn(),

            const SizedBox(height: 8),

            NeonButton(
              label:     _saving ? 'SAUVEGARDE EN COURS...' : 'METTRE À JOUR  ✓',
              onPressed: _saving ? null : _save,
            ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _kpiSection(String title, IconData icon, Color color, List<_KpiField> fields) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: HUDCard(
        color: color,
        label: 'SUB-SYS_INPUT_${title.substring(0, 3)}',
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontFamily: 'Orbitron', fontSize: 11, color: color, fontWeight: FontWeight.w700, letterSpacing: 2)),
              ],
            ),
            const SizedBox(height: 12),
            ...fields.map((f) => _buildField(f, color)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(_KpiField field, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field.label, style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 11, color: IronMindColors.textSecondary)),
              const Spacer(),
              Text('/ ${field.target}', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10, color: color.withOpacity(0.6))),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller:  field.controller,
            keyboardType: TextInputType.number,
            style: TextStyle(fontFamily: 'Orbitron', fontSize: 16, fontWeight: FontWeight.w700, color: color),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              suffixIcon: Icon(Icons.edit, color: color.withOpacity(0.5), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiField {
  final String                label;
  final TextEditingController controller;
  final int                   target;
  const _KpiField(this.label, this.controller, this.target);
}

// lib/features/roadmap/presentation/pages/deep_work_page.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/shared/widgets/neon_button.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/core/services/sound_service.dart';

class DeepWorkPage extends ConsumerStatefulWidget {
  const DeepWorkPage({super.key});

  @override
  ConsumerState<DeepWorkPage> createState() => _DeepWorkPageState();
}

class _DeepWorkPageState extends ConsumerState<DeepWorkPage> {
  final int _targetSeconds = 4 * 3600;

  String _formatTime(int totalSeconds) {
    final h = (totalSeconds / 3600).floor().toString().padLeft(2, '0');
    final m = ((totalSeconds % 3600) / 60).floor().toString().padLeft(2, '0');
    final s = (totalSeconds % 60).floor().toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _toggleTimer() {
    SoundService.playBeep();
    ref.read(deepWorkProvider.notifier).toggle();
  }

  void _resetTimer() {
    SoundService.playBeep();
    _saveProgress();
    ref.read(deepWorkProvider.notifier).reset(0);
  }

  void _saveProgress() {
    final state = ref.read(deepWorkProvider);
    if (state.seconds >= 60) {
      final mins = (state.seconds / 60).floor();
      _showReportSheet(mins);
      ref.read(deepWorkProvider.notifier).consumeSeconds(mins * 60);
    }
  }

  void _showReportSheet(int minutes) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SessionReportSheet(
        minutes: minutes,
        onConfirm: (notes) {
          ref.read(userProgressProvider.notifier).addDeepWorkMinutes(minutes);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dwState = ref.watch(deepWorkProvider);
    final progress = (dwState.seconds / _targetSeconds).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('>_ DEEP_WORK_CORE', style: TextStyle(fontFamily: 'Orbitron', fontSize: 14.sp, color: IronMindColors.neonPurple, letterSpacing: 2)),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ScanlinePainter(IronMindColors.neonPurple.withOpacity(0.05)))),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Column(
                children: [
                  // 1. HEADER HUD
                  HUDCard(
                    color: IronMindColors.neonPurple,
                    label: 'FOCUS_SESSION_STATUS',
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('CIBLE_QUOTIDIENNE: 04H', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 10.sp, color: IronMindColors.neonPurple, fontWeight: FontWeight.bold)),
                        Icon(Icons.wifi_tethering, color: IronMindColors.neonPurple, size: 16.w),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 2. MAIN TIMER
                  HUDCard(
                    color: IronMindColors.neonPurple,
                    label: 'NEURAL_LINK_ELAPSED',
                    padding: EdgeInsets.symmetric(vertical: 60.h),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250.w,
                            height: 250.w,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4.w,
                              color: IronMindColors.neonPurple,
                              backgroundColor: IronMindColors.neonPurple.withOpacity(0.05),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatTime(dwState.seconds),
                                style: TextStyle(fontFamily: 'Orbitron', fontSize: 44.sp, fontWeight: FontWeight.w900, color: IronMindColors.textPrimary, letterSpacing: 2),
                              ),
                              if (dwState.isActive)
                                Icon(Icons.flash_on, color: IronMindColors.neonPurple, size: 30.w).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds)
                              else
                                Text('IDLE', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 3. CONTROLS
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          label: dwState.isActive ? '  PAUSE' : '  DÉMARRER',
                          onPressed: _toggleTimer,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        height: 56.h, width: 56.h,
                        decoration: BoxDecoration(
                          color: IronMindColors.card,
                          border: Border.all(color: IronMindColors.neonPurple.withOpacity(0.3), width: 1.w),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.stop_rounded, color: IronMindColors.neonPurple),
                          onPressed: _resetTimer,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 4. STATS / LOGS (THE MISSING CARDS)
                  _RecentLogsSection(),
                  
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentLogsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HUDCard(
          color: IronMindColors.textDisabled,
          label: 'MISSION_DATA_LOG',
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
               _logItem(context, '09:00', 'INITIALISATION MODULE', 'STATUS: OK'),
               const Divider(color: IronMindColors.glassBorder, height: 20),
               _logItem(context, '10:30', 'SESSION DEEP_WORK', 'GAINS: +60 MIN'),
               const Divider(color: IronMindColors.glassBorder, height: 20),
               _logItem(context, '14:15', 'ALGO_SYNC_COMPLETE', 'LEVELED_UP: NO'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _logItem(BuildContext context, String time, String action, String meta) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(time, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.textDisabled)),
        Text(action, style: TextStyle(fontFamily: 'Orbitron', fontSize: 9.sp, color: IronMindColors.textPrimary, fontWeight: FontWeight.bold)),
        Text(meta, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 9.sp, color: IronMindColors.neonGreen)),
      ],
    );
  }
}

class _SessionReportSheet extends StatefulWidget {
  final int minutes;
  final Function(String) onConfirm;
  const _SessionReportSheet({required this.minutes, required this.onConfirm});
  @override
  State<_SessionReportSheet> createState() => _SessionReportSheetState();
}

class _SessionReportSheetState extends State<_SessionReportSheet> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: IronMindColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RAPPORT_DE_SESSION: ${widget.minutes} MIN', style: TextStyle(fontFamily: 'Orbitron', fontSize: 16.sp, color: IronMindColors.neonPurple, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            TextField(
              controller: _ctrl, maxLines: 2, autofocus: true,
              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 14.sp, color: IronMindColors.textPrimary),
              decoration: InputDecoration(hintText: 'Qu\'as-tu accompli ?', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
            ),
            SizedBox(height: 24.h),
            NeonButton(label: 'ENREGISTRER', onPressed: () => widget.onConfirm(_ctrl.text)),
          ],
        ),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  final Color color;
  _ScanlinePainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 0.5.h;
    for (double i = 0; i < size.height; i += 2.h) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) => color != oldDelegate.color;
}

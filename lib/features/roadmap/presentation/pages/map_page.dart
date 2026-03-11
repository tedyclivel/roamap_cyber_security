// lib/features/roadmap/presentation/pages/map_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iron_mind/core/theme/app_theme.dart';
import 'package:iron_mind/features/roadmap/domain/entities/roadmap_day_entity.dart';
import 'package:iron_mind/features/roadmap/presentation/providers/roadmap_providers.dart';
import 'package:iron_mind/core/services/sound_service.dart';
import 'package:iron_mind/shared/widgets/hud_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Final confirmation: Day 1 at the bottom of the scroll view.
  // We scroll to the bottom so the user starts at Day 1.
  void _scrollToBottom() {
    if (_hasScrolledToBottom) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        _hasScrolledToBottom = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final allDaysAsync = ref.watch(allDaysProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: IronMindColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '>_ TACTICAL_PROGRESS_MAP',
          style: TextStyle(fontFamily: 'Orbitron', fontSize: 13.sp, color: primaryColor, letterSpacing: 2),
        ),
      ),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Erreur: $e')),
        data: (progress) => allDaysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Erreur: $e')),
          data: (allDays) {
            _scrollToBottom();
            return _MapCanvas(
              days:          allDays,
              currentDay:    progress.currentDay,
              primaryColor:  primaryColor,
              scrollController: _scrollController,
              onDayTap: (day) => _showDayDetail(context, day),
            );
          },
        ),
      ),
    );
  }

  void _showDayDetail(BuildContext context, RoadmapDayEntity day) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DayDetailSheet(day: day),
    );
  }
}

// ── Map Canvas ─────────────────────────────────────────────────────────────

class _MapCanvas extends StatelessWidget {
  final List<RoadmapDayEntity> days;
  final int currentDay;
  final Color primaryColor;
  final ScrollController scrollController;
  final void Function(RoadmapDayEntity) onDayTap;

  const _MapCanvas({required this.days, required this.currentDay, required this.primaryColor, required this.scrollController, required this.onDayTap});

  static final double _cardWidth   = 180.w;
  static final double _cardHeight  = 72.h;
  static final double _verticalGap = 90.h;
  static final double _leftX       = 20.w;
  static final double _rightX      = 180.w;

  // Position calculation:
  // Day 1 (index 0) is at the BOTTOM.
  // Day N is at the TOP.
  double _yForIndex(int i, double totalHeight) {
    // Distance from top. 
    // index 0 -> totalHeight - cardHeight - offset
    return totalHeight - (i * (_cardHeight + _verticalGap)) - _cardHeight - 60;
  }

  double _xForIndex(int i) => i.isEven ? _leftX : _rightX;

  @override
  Widget build(BuildContext context) {
    final totalHeight = days.length * (_cardHeight + _verticalGap) + 120;

    return SingleChildScrollView(
      controller: scrollController,
      child: SizedBox(
        width: double.infinity,
        height: totalHeight,
        child: Stack(
          children: [
            // ── Dashed connector lines ─────────────────────────────
            CustomPaint(
              size: Size(double.infinity, totalHeight),
              painter: _DashedConnectorPainter(
                count:       days.length,
                cardWidth:   _cardWidth,
                cardHeight:  _cardHeight,
                verticalGap: _verticalGap,
                totalHeight: totalHeight,
                leftX:       _leftX,
                rightX:      _rightX,
                color:       primaryColor.withOpacity(0.35),
              ),
            ),

            // ── Node cards ─────────────────────────────────────────
            for (int i = 0; i < days.length; i++)
              Positioned(
                left:   _xForIndex(i),
                top:    _yForIndex(i, totalHeight),
                width:  _cardWidth,
                height: _cardHeight,
                child: _MapNodeCard(
                  day:          days[i],
                  isPassed:     days[i].dayNumber < currentDay,
                  isCurrent:    days[i].dayNumber == currentDay,
                  isLocked:     days[i].dayNumber > currentDay,
                  primaryColor: primaryColor,
                  onTap: days[i].dayNumber > currentDay
                      ? null
                      : () => onDayTap(days[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed Connector Painter ────────────────────────────────────────────────

class _DashedConnectorPainter extends CustomPainter {
  final int count;
  final double cardWidth, cardHeight, verticalGap, totalHeight, leftX, rightX;
  final Color color;

  const _DashedConnectorPainter({
    required this.count,
    required this.cardWidth,
    required this.cardHeight,
    required this.verticalGap,
    required this.totalHeight,
    required this.leftX,
    required this.rightX,
    required this.color,
  });

  double _yForIndex(int i) => totalHeight - (i * (cardHeight + verticalGap)) - cardHeight - 60;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = color
      ..strokeWidth = 1.5.w
      ..style       = PaintingStyle.stroke;

    for (int i = 0; i < count - 1; i++) {
      // Current node i
      final double x1 = (i.isEven ? leftX : rightX) + cardWidth / 2;
      final double y1 = _yForIndex(i);

      // Next node i+1
      final double x2 = ((i + 1).isEven ? leftX : rightX) + cardWidth / 2;
      final double y2 = _yForIndex(i + 1) + cardHeight;

      _drawDashed(canvas, Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawDashed(Canvas canvas, Offset a, Offset b, Paint p) {
    final dashLen = 6.0.w;
    final gapLen  = 5.0.w;
    final dir   = (b - a);
    final dist  = dir.distance;
    final unit  = dir / dist;
    double covered = 0;
    bool drawing = true;

    while (covered < dist) {
      final segLen = drawing ? dashLen : gapLen;
      final end = (covered + segLen).clamp(0.0, dist);
      if (drawing) {
        canvas.drawLine(a + unit * covered, a + unit * end, p);
      }
      covered += segLen;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedConnectorPainter old) => false;
}

// ── Node Card ───────────────────────────────────────────────────────────────

class _MapNodeCard extends StatelessWidget {
  final RoadmapDayEntity day;
  final bool isPassed, isCurrent, isLocked;
  final Color primaryColor;
  final VoidCallback? onTap;

  const _MapNodeCard({required this.day, required this.isPassed, required this.isCurrent, required this.isLocked, required this.primaryColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color nodeColor = isLocked
        ? IronMindColors.textDisabled.withOpacity(0.25)
        : primaryColor;

    final pct = (day.completionRate * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: nodeColor.withOpacity(0.4), width: 1),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -1, right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: nodeColor.withOpacity(0.15),
                  border: Border.all(color: nodeColor.withOpacity(0.5)),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
                ),
                child: Text('DAY_${day.dayNumber.toString().padLeft(3, '0')}',
                    style: TextStyle(fontFamily: 'Orbitron', fontSize: 8.sp, color: nodeColor, fontWeight: FontWeight.bold)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: nodeColor, width: 1.5.w),
                      color: nodeColor.withOpacity(0.08),
                    ),
                    child: Center(
                      child: isCurrent
                          ? Icon(Icons.location_searching, size: 18, color: nodeColor)
                              .animate(onPlay: (c) => c.repeat())
                              .scale(duration: 900.ms, curve: Curves.easeInOut)
                          : isPassed
                              ? Icon(Icons.check, size: 18, color: nodeColor)
                              : const SizedBox(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('MISSION', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 8.sp, color: IronMindColors.textDisabled)),
                      Text('$pct%',
                          style: TextStyle(fontFamily: 'Orbitron', fontSize: 16.sp, fontWeight: FontWeight.w900, color: nodeColor, height: 1.1)),
                      Text(
                        isPassed ? 'READY' : (isCurrent ? 'EN COURS' : 'LOCKED'),
                        style: TextStyle(fontFamily: 'Orbitron', fontSize: 8.sp, color: nodeColor, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Day Detail Bottom Sheet ─────────────────────────────────────────────────

class _DayDetailSheet extends StatelessWidget {
  final RoadmapDayEntity day;
  const _DayDetailSheet({required this.day});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
      decoration: const BoxDecoration(
        color: IronMindColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: IronMindColors.glassBorder, borderRadius: BorderRadius.circular(2.r)))),
          SizedBox(height: 16.h),
          Text('DAY ${day.dayNumber} — MISSION LOG',
              style: TextStyle(fontFamily: 'Orbitron', fontSize: 16.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(day.phaseLabel, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: IronMindColors.textDisabled)),
          const Divider(height: 24, color: IronMindColors.glassBorder),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (day.tasks.isNotEmpty) ...[
                    Text('OBJECTIFS', style: TextStyle(fontFamily: 'Orbitron', fontSize: 10.sp, color: IronMindColors.textDisabled)),
                    SizedBox(height: 10.h),
                    ...day.tasks.map((task) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: task.isCompleted ? Theme.of(context).colorScheme.primary : IronMindColors.textDisabled, size: 18.w),
                          SizedBox(width: 10.w),
                          Expanded(child: Text(task.title,
                              style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12.sp, color: task.isCompleted ? IronMindColors.textDisabled : IronMindColors.textPrimary,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null))),
                        ],
                      ),
                    )),
                    SizedBox(height: 20.h),
                  ],
                  if (day.journalNote != null && day.journalNote!.isNotEmpty) ...[
                    const Text('JOURNAL', style: TextStyle(fontFamily: 'Orbitron', fontSize: 10, color: IronMindColors.textDisabled)),
                    const SizedBox(height: 10),
                    Text(day.journalNote!,
                        style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, color: IronMindColors.textSecondary, height: 1.6)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/core/theme/app_theme.dart';

/// Un conteneur style HUD avec des coins renforcés et un effet de lueur.
class HUDCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final String? label;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const HUDCard({
    super.key,
    required this.child,
    this.color,
    this.label,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    
    Widget content = Container(
      padding: padding ?? EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: IronMindColors.card.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: IronMindColors.glassBorder, width: 0.5),
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap!();
        },
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: content,
      );
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 1. Effet de lueur (Décoratif -> IgnorePointer)
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              margin: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: activeColor.withOpacity(0.02),
                    blurRadius: 15.r,
                  ),
                ],
              ),
            ),
          ),
        ),

        // 2. Coins HUD (Brackets) (Décoratif -> IgnorePointer)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _HUDCornersPainter(color: activeColor.withOpacity(0.4)),
            ),
          ),
        ),

        // 3. Label HUD (Décoratif -> IgnorePointer)
        if (label != null)
          Positioned(
            top: 0,
            right: 20.w,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.8),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(4.r),
                    bottomRight: Radius.circular(4.r),
                  ),
                ),
                child: Text(
                  label!.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 7.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),

        // 4. CONTENU PRINCIPAL
        content,
      ],
    );
  }
}

class _HUDCornersPainter extends CustomPainter {
  final Color color;
  const _HUDCornersPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const cornerLength = 12.0;
    const radius = 16.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength + radius)
        ..lineTo(0, radius)
        ..arcToPoint(const Offset(radius, 0), radius: const Radius.circular(radius))
        ..lineTo(cornerLength + radius, 0),
      paint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLength - radius)
        ..lineTo(size.width, size.height - radius)
        ..arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius))
        ..lineTo(size.width - cornerLength - radius, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

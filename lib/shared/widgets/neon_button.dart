import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iron_mind/core/theme/app_theme.dart';

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isSecondary;

  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onPressed != null) {
            HapticFeedback.lightImpact();
            onPressed!();
          }
        },
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: isSecondary ? Colors.transparent : activeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: onPressed == null ? IronMindColors.textDisabled : activeColor,
              width: 1.5.w,
            ),
            boxShadow: onPressed == null
                ? []
                : [
                    BoxShadow(
                      color: activeColor.withOpacity(0.2),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                    ),
                  ],
          ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: onPressed == null ? IronMindColors.textDisabled : activeColor,
            letterSpacing: 2.w,
          ),
        ),
      ),
    ),
  );
}
}

class NeonIconButton extends StatelessWidget {
final IconData icon;
final VoidCallback? onPressed;
final Color? color;
final String? tooltip;

const NeonIconButton({
  super.key,
  required this.icon,
  required this.onPressed,
  this.color,
  this.tooltip,
});

@override
Widget build(BuildContext context) {
  final activeColor = color ?? Theme.of(context).colorScheme.primary;
  return Tooltip(
    message: tooltip ?? '',
    child: InkWell(
      onTap: () {
        if (onPressed != null) {
          HapticFeedback.lightImpact();
          onPressed!();
        }
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color:        activeColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border:       Border.all(color: activeColor.withOpacity(0.3)),
        ),
        child: Icon(icon, color: activeColor, size: 20.r),
      ),
    ),
  );
}
}

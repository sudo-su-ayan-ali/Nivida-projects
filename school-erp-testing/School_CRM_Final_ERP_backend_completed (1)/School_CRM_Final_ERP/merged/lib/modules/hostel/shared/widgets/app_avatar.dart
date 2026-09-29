import "package:flutter/material.dart";
import "../../core/theme/app_colors.dart";

class AppAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color? color;

  const AppAvatar({super.key, required this.initials, this.size = 36, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(color: bg.withOpacity(0.14), shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initials, style: TextStyle(color: bg, fontWeight: FontWeight.w700, fontSize: size * 0.36)),
    );
  }
}

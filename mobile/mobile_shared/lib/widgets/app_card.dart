import 'package:flutter/material.dart';
import '../theme/cineplex_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CineplexColors>()!;
    
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.surface,
        borderRadius: BorderRadius.circular(colors.radiusMd),
        boxShadow: Theme.of(context).brightness == Brightness.light 
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: colors.elevationSm,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(colors.radiusMd),
          child: Padding(
            padding: padding ?? EdgeInsets.all(colors.spacingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}

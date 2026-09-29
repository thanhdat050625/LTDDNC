import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = widget.isLoading || widget.onPressed == null;

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 20),
        if (widget.isLoading || widget.icon != null) const SizedBox(width: 8),
        Text(widget.text),
      ],
    );

    final isPrimary = !widget.isOutlined && (widget.backgroundColor == null || widget.backgroundColor == theme.primaryColor);

    final button = Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: isPrimary && !disabled ? BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGlow,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ) : null,
      child: widget.isOutlined
          ? OutlinedButton(
              onPressed: disabled ? null : widget.onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.textColor ?? theme.primaryColor,
                side: BorderSide(color: widget.textColor ?? theme.primaryColor),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: disabled ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ?? theme.primaryColor,
                foregroundColor: widget.textColor ?? Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              child: child,
            ),
    );

    return Listener(
      onPointerDown: disabled ? null : (_) => _controller.forward(),
      onPointerUp: disabled ? null : (_) => _controller.reverse(),
      onPointerCancel: disabled ? null : (_) => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: button,
      ),
    );
  }
}

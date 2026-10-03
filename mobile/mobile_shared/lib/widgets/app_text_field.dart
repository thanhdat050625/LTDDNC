import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_colors.dart';
import '../theme/cineplex_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    super.key,
    String? label,
    String? hintText,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
  }) : label = label ?? hintText ?? '';

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CineplexColors>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = colors?.textPrimary ?? (isDark ? Colors.white : const Color(0xFF111827));
    final labelColor = colors?.textSecondary ?? (isDark ? Colors.white70 : const Color(0xFF4B5563));
    final hintColor = colors?.textSecondary.withValues(alpha: 0.6) ?? (isDark ? Colors.white54 : const Color(0xFF9CA3AF));
    final borderColor = colors?.textSecondary.withValues(alpha: 0.2) ?? (isDark ? Colors.white24 : const Color(0xFFE5E7EB));
    final enabledBorderColor = colors?.textSecondary.withValues(alpha: 0.12) ?? (isDark ? Colors.white12 : const Color(0xFFE5E7EB));
    final primaryColor = colors?.primary ?? AppColors.primary;
    final bgColor = isDark ? AppColors.glassmorphismColor : (colors?.surface.withValues(alpha: 0.9) ?? Colors.white);

    return Stack(
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(color: bgColor),
            ),
          ),
        ),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          obscureText: _obscureText,
          maxLines: _obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: widget.label.isNotEmpty ? widget.label : null,
            labelStyle: TextStyle(color: labelColor),
            floatingLabelStyle: TextStyle(color: primaryColor),
            hintText: widget.hint,
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: Colors.transparent, // Let the Stack background show through
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: enabledBorderColor, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, color: labelColor) : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: labelColor),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

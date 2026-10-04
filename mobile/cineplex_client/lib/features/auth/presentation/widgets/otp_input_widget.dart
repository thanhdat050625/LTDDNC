import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_shared/mobile_shared.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  
  const OtpInputWidget({super.key, this.length = 6, required this.onCompleted});

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(widget.length, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var node in _focusNodes) { node.dispose(); }
    for (var ctrl in _controllers) { ctrl.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    String currentOtp = _controllers.map((e) => e.text).join();
    if (currentOtp.length == widget.length) {
      widget.onCompleted(currentOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = CineplexColors.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final double gap = availableWidth < 280 ? 6.0 : (availableWidth < 340 ? 8.0 : 10.0);
        final totalGaps = (widget.length - 1) * gap;
        final boxWidth = ((availableWidth - totalGaps) / widget.length).clamp(32.0, 46.0);
        final boxHeight = (boxWidth * 1.18).clamp(46.0, 54.0);

        final borderColor = colors.isDark
            ? Colors.white.withValues(alpha: 0.16)
            : colors.border;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < widget.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              SizedBox(
                width: boxWidth,
                height: boxHeight,
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(1),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: colors.surfaceVariant,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor, width: 1.2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor, width: 1.2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: colors.primary, width: 2),
                    ),
                  ),
                  onChanged: (val) => _onChanged(val, i),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

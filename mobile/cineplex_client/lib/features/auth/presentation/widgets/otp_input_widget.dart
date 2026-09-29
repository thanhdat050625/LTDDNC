import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cineplex_client/core/theme/app_colors.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 45,
          height: 55,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            onChanged: (val) => _onChanged(val, index),
          ),
        );
      }),
    );
  }
}

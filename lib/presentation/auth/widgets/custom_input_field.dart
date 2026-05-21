import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool isValid;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
    this.isValid = false,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: AppMotion.quick,
          curve: AppMotion.entranceCurve,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.error
                  : _isFocused
                  ? AppColors.accent
                  : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isFocused = hasFocus;
                    });
                  },
                  child: TextField(
                    obscureText: widget.isPassword,
                    keyboardType: widget.keyboardType,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: const TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
              ),
              if (widget.isValid && widget.suffixIcon == null)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.check, color: AppColors.accent, size: 20),
                ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.helper.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}

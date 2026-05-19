import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'custom_input_field.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final String placeholder;
  final String? errorText;
  final Function(String)? onChanged;
  final bool isValid;

  const CustomPasswordField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.errorText,
    this.onChanged,
    this.isValid = false,
  }) : super(key: key);

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: widget.label,
      placeholder: widget.placeholder,
      isPassword: _obscureText,
      errorText: widget.errorText,
      onChanged: widget.onChanged,
      isValid: widget.isValid,
      suffixIcon: GestureDetector(
        onTap: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: AppColors.secondaryText,
            size: 20,
          ),
        ),
      ),
    );
  }
}

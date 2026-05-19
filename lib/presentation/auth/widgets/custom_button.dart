import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color btnBgColor = backgroundColor ?? AppColors.accent;
    Color btnTextColor = textColor ?? Colors.black;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: isOutlined
          ? OutlinedButton(
              onPressed: (isDisabled || isLoading) ? null : onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryText, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Fully rounded
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppColors.primaryText,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.button.copyWith(
                        color: isDisabled ? AppColors.primaryText.withOpacity(0.5) : AppColors.primaryText,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: (isDisabled || isLoading) ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: btnBgColor,
                disabledBackgroundColor: btnBgColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50), // Fully rounded
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: AppTextStyles.button.copyWith(
                        color: isDisabled ? btnTextColor.withOpacity(0.5) : btnTextColor,
                      ),
                    ),
            ),
    );
  }
}

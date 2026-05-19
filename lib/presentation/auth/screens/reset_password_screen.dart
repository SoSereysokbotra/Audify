import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String newPassword = "";
  String confirmPassword = "";
  
  bool _hasLength() => newPassword.length >= 8;
  bool _hasUpper() => newPassword.contains(RegExp(r'[A-Z]'));
  bool _hasLower() => newPassword.contains(RegExp(r'[a-z]'));
  bool _hasNumber() => newPassword.contains(RegExp(r'[0-9]'));
  bool _hasSpecial() => newPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  
  bool _isValid() => _hasLength() && _hasUpper() && _hasLower() && _hasNumber() && _hasSpecial();

  int _getPasswordStrength() {
    if (newPassword.isEmpty) return 0;
    int strength = 0;
    if (_hasLength()) strength++;
    if (_hasUpper() || _hasLower()) strength++;
    if (_hasNumber()) strength++;
    if (_hasSpecial()) strength++;
    
    if (strength <= 1) return 1; // Weak
    if (strength <= 3) return 2; // Medium
    return 3; // Strong
  }

  void _resetPassword() async {
    if (!_isValid() || newPassword != confirmPassword) return;

    DialogUtils.showLoadingDialog(context);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    DialogUtils.hideDialog(context);
    
    DialogUtils.showSuccessDialog(
      context,
      title: "Password Reset Successful!",
      message: "Your password has been reset. Please sign in with your new password.",
      onContinue: () {
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      },
    );
  }

  Widget _buildStrengthIndicator() {
    int level = _getPasswordStrength();
    Color color = AppColors.disabled;
    String text = "";
    if (level == 1) { color = AppColors.error; text = "Weak"; }
    else if (level == 2) { color = AppColors.warning; text = "Medium"; }
    else if (level == 3) { color = AppColors.success; text = "Strong"; }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: level >= 1 ? AppColors.error : AppColors.disabled, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: level >= 2 ? AppColors.warning : AppColors.disabled, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(width: 4),
            Expanded(child: Container(height: 4, decoration: BoxDecoration(color: level >= 3 ? AppColors.success : AppColors.disabled, borderRadius: BorderRadius.circular(2)))),
          ],
        ),
        const SizedBox(height: 8),
        if (level > 0)
          Text("Password strength: $text", style: AppTextStyles.helper.copyWith(color: color)),
      ],
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: isMet ? AppColors.accent : AppColors.secondaryText, size: 16),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.helper.copyWith(color: isMet ? AppColors.accent : AppColors.secondaryText)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool passwordsMatch = newPassword.isNotEmpty && confirmPassword == newPassword;
    bool canSubmit = _isValid() && passwordsMatch;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Skip back to login directly
            Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(Icons.check_circle, color: AppColors.accent, size: 60),
              ),
              const SizedBox(height: 20),
              const Text("Create New Password", style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              const Text(
                "Your new password must be at least 8 characters long and include uppercase letters, numbers, and special characters",
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              CustomPasswordField(
                label: "New Password",
                placeholder: "••••••••",
                onChanged: (val) => setState(() => newPassword = val),
              ),
              const SizedBox(height: 8),
              _buildStrengthIndicator(),
              const SizedBox(height: 16),
              
              CustomPasswordField(
                label: "Confirm New Password",
                placeholder: "••••••••",
                isValid: passwordsMatch,
                onChanged: (val) => setState(() => confirmPassword = val),
              ),
              if (passwordsMatch)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Passwords match", style: AppTextStyles.helper.copyWith(color: AppColors.success)),
                ),
              const SizedBox(height: 32),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRequirement("At least 8 characters", _hasLength()),
                  _buildRequirement("Contains uppercase letter (A-Z)", _hasUpper()),
                  _buildRequirement("Contains lowercase letter (a-z)", _hasLower()),
                  _buildRequirement("Contains number (0-9)", _hasNumber()),
                  _buildRequirement("Contains special character (!@#\$%^&*)", _hasSpecial()),
                ],
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: "RESET PASSWORD",
                isDisabled: !canSubmit,
                onPressed: _resetPassword,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

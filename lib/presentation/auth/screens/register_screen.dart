import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_checkbox.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  String username = "";
  String email = "";
  String password = "";
  String confirmPassword = "";
  bool agreeTerms = false;
  
  String? usernameError;
  String? emailError;
  String? passwordError;
  String? confirmError;

  bool _isValidUsername(String name) {
    return name.length >= 3 && name.length <= 20 && RegExp(r'^[a-zA-Z0-9]+$').hasMatch(name);
  }
  
  int _getPasswordStrength(String pass) {
    if (pass.isEmpty) return 0;
    int strength = 0;
    if (pass.length >= 8) strength++;
    if (pass.contains(RegExp(r'[A-Z]'))) strength++;
    if (pass.contains(RegExp(r'[0-9]'))) strength++;
    if (pass.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) strength++;
    
    if (strength <= 1) return 1; // Weak
    if (strength <= 3) return 2; // Medium
    return 3; // Strong
  }

  void _validateAndRegister() async {
    setState(() {
      usernameError = !_isValidUsername(username) ? "3-20 chars, alphanumeric only" : null;
      emailError = (!email.contains("@") || email.isEmpty) ? "Invalid email format" : null;
      
      bool hasMinLen = password.length >= 8;
      bool hasUpper = password.contains(RegExp(r'[A-Z]'));
      bool hasNumber = password.contains(RegExp(r'[0-9]'));
      bool hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
      
      if (!hasMinLen || !hasUpper || !hasNumber || !hasSpecial) {
        passwordError = "Requires 8+ chars, 1 uppercase, 1 number, 1 special";
      } else {
        passwordError = null;
      }
      
      confirmError = password != confirmPassword || confirmPassword.isEmpty ? "Passwords do not match" : null;
    });

    if (usernameError == null && emailError == null && passwordError == null && confirmError == null && agreeTerms) {
      DialogUtils.showLoadingDialog(context);
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      DialogUtils.showSuccessDialog(
        context,
        title: "Account Created!",
        message: "You can now sign in with your credentials.",
        onContinue: () {
          NavigationRouter.goBack(context);
        },
      );
    }
  }

  Widget _buildStrengthIndicator() {
    int level = _getPasswordStrength(password);
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

  @override
  Widget build(BuildContext context) {
    bool isFormValid = agreeTerms && confirmPassword.isNotEmpty && password.isNotEmpty;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationRouter.goBack(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("Create Account", style: AppTextStyles.h1),
              const SizedBox(height: 8),
              const Text("Join millions of music lovers", style: AppTextStyles.bodySmall),
              const SizedBox(height: 32),
              
              CustomInputField(
                label: "Username",
                placeholder: "Choose your username",
                errorText: usernameError,
                isValid: _isValidUsername(username),
                onChanged: (val) => setState(() => username = val),
              ),
              const SizedBox(height: 20),
              
              CustomInputField(
                label: "Email",
                placeholder: "your.email@example.com",
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                isValid: email.contains("@"),
                onChanged: (val) => setState(() => email = val),
              ),
              const SizedBox(height: 20),
              
              CustomPasswordField(
                label: "Password",
                placeholder: "••••••••",
                errorText: passwordError,
                onChanged: (val) => setState(() => password = val),
              ),
              const SizedBox(height: 8),
              _buildStrengthIndicator(),
              const SizedBox(height: 16),
              
              CustomPasswordField(
                label: "Confirm Password",
                placeholder: "••••••••",
                errorText: confirmError,
                isValid: confirmPassword.isNotEmpty && password == confirmPassword,
                onChanged: (val) => setState(() => confirmPassword = val),
              ),
              const SizedBox(height: 24),
              
              CustomCheckbox(
                value: agreeTerms,
                onChanged: (val) => setState(() => agreeTerms = val ?? false),
                label: RichText(
                  text: TextSpan(
                    text: "I agree to ",
                    style: AppTextStyles.helper,
                    children: [
                      TextSpan(
                        text: "Terms & Conditions",
                        style: AppTextStyles.helper.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: "CREATE ACCOUNT",
                isDisabled: !isFormValid,
                onPressed: _validateAndRegister,
              ),
              const SizedBox(height: 24),
              
              GestureDetector(
                onTap: () {
                  NavigationRouter.goBack(context);
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(
                        text: "Sign in",
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

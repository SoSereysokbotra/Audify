import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import 'verify_email_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email = "";
  String? emailError;

  void _sendResetCode() async {
    setState(() {
      emailError = (!email.contains("@") || email.isEmpty) ? "Invalid email format" : null;
    });

    if (emailError == null) {
      DialogUtils.showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      
      DialogUtils.showSuccessDialog(
        context,
        title: "Code Sent!",
        message: "Code sent to your email.",
        onContinue: () {
          NavigationRouter.navigateAndReplace(context, const VerifyEmailScreen());
        },
      );
      
      // Auto navigate after showing dialog momentarily
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
          NavigationRouter.navigateTo(context, const VerifyEmailScreen());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Text("Forgot Your Password?", style: AppTextStyles.h1),
              const SizedBox(height: 16),
              const Text(
                "Enter your email address and we'll send you a code to reset your password",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 32),
              
              CustomInputField(
                label: "Email Address",
                placeholder: "your.email@example.com",
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                onChanged: (val) => setState(() => email = val),
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: "SEND RESET CODE",
                isDisabled: email.isEmpty,
                onPressed: _sendResetCode,
              ),
              const SizedBox(height: 32),
              
              const Text("Can't receive emails?", style: AppTextStyles.helper, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () => NavigationRouter.goBack(context),
                child: Text(
                  "Back to sign in",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

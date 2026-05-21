import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';

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
      emailError = (!email.contains("@") || email.isEmpty)
          ? "Invalid email format"
          : null;
    });

    if (emailError == null) {
      DialogUtils.showLoadingDialog(context);
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        if (!mounted) return;
        DialogUtils.hideDialog(context);

        DialogUtils.showSuccessDialog(
          context,
          title: "Reset Email Sent",
          message:
              "Open the link in your email to reset your password, then sign in with the new password.",
          onContinue: () {
            NavigationRouter.navigateAndReplace(context, const LoginScreen());
          },
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        DialogUtils.hideDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Failed to send reset email.')),
        );
      } catch (e) {
        if (!mounted) return;
        DialogUtils.hideDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
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
                "Enter your email address and we'll send you a reset link",
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
                text: "SEND RESET LINK",
                isDisabled: email.isEmpty,
                onPressed: _sendResetCode,
              ),
              const SizedBox(height: 32),

              const Text(
                "Can't receive emails?",
                style: AppTextStyles.helper,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => NavigationRouter.goBack(context),
                child: Text(
                  "Back to sign in",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent,
                  ),
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_checkbox.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'verify_email_screen.dart';

import '../../main_layout/main_layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email = "";
  String password = "";
  bool rememberMe = false;
  String? emailError;
  String? passwordError;

  void _validateAndLogin() async {
    setState(() {
      emailError = (!email.contains("@") || email.isEmpty)
          ? "Invalid email format"
          : null;
      passwordError = password.length < 6
          ? "Password must be at least 6 characters"
          : null;
    });

    if (emailError == null && passwordError == null) {
      DialogUtils.showLoadingDialog(context);
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        await credential.user?.reload();
        final user = FirebaseAuth.instance.currentUser;
        if (!mounted) return;

        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          if (!mounted) return;
          DialogUtils.hideDialog(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please verify your email before signing in.'),
            ),
          );
          NavigationRouter.navigateAndReplace(
            context,
            VerifyEmailScreen(
              mode: VerifyEmailMode.registration,
              email: user.email,
            ),
          );
          return;
        }

        DialogUtils.hideDialog(context);
        DialogUtils.showSuccessDialog(
          context,
          title: "Login Successful",
          message: "Welcome back!",
          onContinue: () {
            NavigationRouter.navigateAndReplace(
              context,
              const MainLayoutScreen(),
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        DialogUtils.hideDialog(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed.')));
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.music_note, color: AppColors.accent, size: 64),
              const SizedBox(height: 16),
              const Text(
                "Audify",
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              const Text(
                "Welcome Back",
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Sign in to your account",
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              CustomInputField(
                label: "Email",
                placeholder: "your.email@example.com",
                keyboardType: TextInputType.emailAddress,
                errorText: emailError,
                onChanged: (val) => setState(() => email = val),
              ),
              const SizedBox(height: 24),

              CustomPasswordField(
                label: "Password",
                placeholder: "••••••••",
                errorText: passwordError,
                onChanged: (val) => setState(() => password = val),
              ),
              const SizedBox(height: 12),

              CustomCheckbox(
                value: rememberMe,
                onChanged: (val) => setState(() => rememberMe = val ?? false),
                label: const Text(
                  "Remember me",
                  style: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  NavigationRouter.navigateTo(
                    context,
                    const ForgotPasswordScreen(),
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.accent,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 32),

              CustomButton(text: "SIGN IN", onPressed: _validateAndLogin),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: AppColors.border),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("OR", style: AppTextStyles.helper),
                  ),
                  Expanded(
                    child: Container(height: 1, color: AppColors.border),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () {
                  NavigationRouter.navigateTo(context, const RegisterScreen());
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: AppTextStyles.bodySmall,
                    children: [
                      TextSpan(
                        text: "Sign up here",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
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

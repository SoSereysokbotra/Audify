import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../data/audify_store.dart';
import '../../../main.dart';
import '../widgets/custom_input_field.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_checkbox.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

const _kRememberMeKey = 'remember_me_email';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  String email = "";
  String password = "";
  bool rememberMe = false;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_kRememberMeKey);
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        email = savedEmail;
        rememberMe = true;
        _emailController.text = savedEmail;
      });
    }
  }

  Future<void> _saveOrClearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(_kRememberMeKey, email);
    } else {
      await prefs.remove(_kRememberMeKey);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

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
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await _saveOrClearEmail();
        if (!mounted) return;

        DialogUtils.hideDialog(context);
        DialogUtils.showSuccessDialog(
          context,
          title: "Login Successful",
          message: "Welcome back!",
          onContinue: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthGate()),
              (route) => false,
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        AudifyStore.instance.addNotification(
          category: AudifyNotificationCategory.account,
          title: 'Login problem',
          message: e.message ?? 'Audify could not sign you in.',
        );
        if (!mounted) return;
        DialogUtils.hideDialog(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Login failed.')));
      } catch (e) {
        AudifyStore.instance.addNotification(
          category: AudifyNotificationCategory.account,
          title: 'Login problem',
          message: 'An unexpected sign-in error occurred.',
        );
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
                controller: _emailController,
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

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../core/utils/navigation_router.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input_field.dart';
import 'reset_password_screen.dart';

enum VerifyEmailMode { registration, passwordReset }

class VerifyEmailScreen extends StatefulWidget {
  final VerifyEmailMode mode;
  final String? email;

  const VerifyEmailScreen({
    Key? key,
    this.mode = VerifyEmailMode.registration,
    this.email,
  }) : super(key: key);

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _auth = FirebaseAuth.instance;
  int _timerSeconds = 60;
  Timer? _timer;
  String _resetCode = "";
  String? _codeError;

  bool get _isPasswordReset => widget.mode == VerifyEmailMode.passwordReset;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _timerSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_timerSeconds > 0) return;

    DialogUtils.showLoadingDialog(context);
    try {
      if (_isPasswordReset) {
        final email = widget.email;
        if (email == null || email.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-email',
            message: 'Enter your email again to resend the reset code.',
          );
        }
        await _auth.sendPasswordResetEmail(email: email);
      } else {
        final user = _auth.currentUser;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'missing-user',
            message: 'Please register or sign in again to resend verification.',
          );
        }
        await user.sendEmailVerification();
      }

      if (!mounted) return;
      DialogUtils.hideDialog(context);
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isPasswordReset
                ? 'Password reset email sent again.'
                : 'Verification email sent again.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to resend email.')),
      );
    }
  }

  Future<void> _checkEmailVerification() async {
    DialogUtils.showLoadingDialog(context);
    try {
      await _auth.currentUser?.reload();
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      
      if (_auth.currentUser?.emailVerified == false && !_isPasswordReset) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is not verified yet. Please check your inbox.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Unable to check verification.')),
      );
    }
  }

  Future<void> _verifyResetCode() async {
    final code = _extractPasswordResetCode(_resetCode);
    setState(() {
      _codeError = code.isEmpty
          ? 'Enter the reset link or code from your email.'
          : null;
    });
    if (_codeError != null) return;

    DialogUtils.showLoadingDialog(context);
    try {
      await _auth.verifyPasswordResetCode(code);
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      NavigationRouter.navigateAndReplace(
        context,
        ResetPasswordScreen(resetCode: code),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      setState(() {
        _codeError = e.message ?? 'Invalid or expired reset code.';
      });
    }
  }

  String _extractPasswordResetCode(String input) {
    final value = input.trim();
    if (value.isEmpty) return '';

    final uri = Uri.tryParse(value);
    final code = uri?.queryParameters['oobCode'];
    if (code != null && code.isNotEmpty) return code;

    return value;
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = '0:${_timerSeconds.toString().padLeft(2, '0')}';
    final title = _isPasswordReset ? 'Verify Reset Code' : 'Verify Your Email';
    final message = _isPasswordReset
        ? 'Paste the reset link or code from your password reset email.'
        : 'Open the verification link we sent to ${widget.email ?? 'your email'}, then return here.';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (Navigator.canPop(context)) {
              NavigationRouter.goBack(context);
            } else {
              await FirebaseAuth.instance.signOut();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: AppTextStyles.h1),
              const SizedBox(height: 16),
              Text(message, style: AppTextStyles.bodySmall),
              const SizedBox(height: 32),

              if (_isPasswordReset) ...[
                CustomInputField(
                  label: 'Reset Link or Code',
                  placeholder: 'Paste reset link or oobCode',
                  errorText: _codeError,
                  onChanged: (val) => setState(() {
                    _resetCode = val;
                    _codeError = null;
                  }),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: 'CONTINUE',
                  isDisabled: _resetCode.trim().isEmpty,
                  onPressed: _verifyResetCode,
                ),
              ] else ...[
                const Icon(
                  Icons.mark_email_unread,
                  color: AppColors.accent,
                  size: 72,
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: "I'VE VERIFIED",
                  onPressed: _checkEmailVerification,
                ),
              ],

              const SizedBox(height: 32),
              if (_timerSeconds > 0)
                Text(
                  'Resend email in $timeStr',
                  style: AppTextStyles.helper,
                  textAlign: TextAlign.center,
                )
              else
                GestureDetector(
                  onTap: _resend,
                  child: Text(
                    'Resend Email',
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

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/dialog_utils.dart';
import '../widgets/code_input_field.dart';
import '../widgets/custom_button.dart';
import 'reset_password_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _timerSeconds = 60;
  Timer? _timer;
  String _code = "";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _timerSeconds = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verifyCode() async {
    if (_code.length != 5) return;
    
    // Simulate error randomly or just accept
    if (_code == "00000") { // just a mock trigger for error
      setState(() => _hasError = true);
      return;
    }

    setState(() => _hasError = false);
    DialogUtils.showLoadingDialog(context);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    DialogUtils.hideDialog(context);
    NavigationRouter.navigateAndReplace(context, const ResetPasswordScreen());
  }

  @override
  Widget build(BuildContext context) {
    String timeStr = "0:${_timerSeconds.toString().padLeft(2, '0')}";
    
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
              const Text("Verify Your Email", style: AppTextStyles.h1),
              const SizedBox(height: 16),
              const Text(
                "Enter the 5-digit code sent to your email",
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 40),
              
              CodeInputField(
                onCodeChanged: (val) => setState(() {
                  _code = val;
                  _hasError = false;
                }),
              ),
              
              if (_hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    "Invalid code. Please try again.",
                    style: AppTextStyles.helper.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              const SizedBox(height: 40),
              
              if (_timerSeconds > 0)
                Text("Resend code in $timeStr", style: AppTextStyles.helper, textAlign: TextAlign.center)
              else
                GestureDetector(
                  onTap: () {
                    _startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code resent to your email")),
                    );
                  },
                  child: Text(
                    "Resend Code",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              const SizedBox(height: 40),
              
              CustomButton(
                text: "VERIFY",
                isDisabled: _code.length < 5,
                onPressed: _verifyCode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() {
  runApp(const SpotifyCloneAuthApp());
}

// ============================================================================
// THEME & CONSTANTS
// ============================================================================
class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF121212);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFB3B3B3);
  static const Color accent = Colors.white;
  static const Color error = Color(0xFFFF3B30);
  static const Color border = Color(0x33FFFFFF); // rgba(255,255,255,0.2)
  static const Color disabled = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
  static const Color warning = Color(0xFFFFA500); // Orange for password strength
}

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.primaryText);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.4, color: AppColors.primaryText);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.primaryText);
  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.secondaryText);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  static const TextStyle inputLabel = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryText);
  static const TextStyle helper = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.secondaryText);
}

// ============================================================================
// APP WIDGET & ROUTING
// ============================================================================
class SpotifyCloneAuthApp extends StatelessWidget {
  const SpotifyCloneAuthApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audify',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        fontFamily: 'Poppins', 
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NavigationRouter {
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void navigateAndReplace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

// ============================================================================
// REUSABLE COMPONENTS
// ============================================================================
class CustomInputField extends StatefulWidget {
  final String label;
  final String placeholder;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? errorText;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final bool isValid;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.onChanged,
    this.suffixIcon,
    this.isValid = false,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.inputLabel),
        const SizedBox(height: 8),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.accent
                      : AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      _isFocused = hasFocus;
                    });
                  },
                  child: TextField(
                    obscureText: widget.isPassword,
                    keyboardType: widget.keyboardType,
                    style: const TextStyle(color: AppColors.primaryText, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: widget.placeholder,
                      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 16),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    ),
                    onChanged: widget.onChanged,
                  ),
                ),
              ),
              if (widget.isValid && widget.suffixIcon == null)
                const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.check, color: AppColors.accent, size: 20),
                ),
              if (widget.suffixIcon != null) widget.suffixIcon!,
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(widget.errorText!, style: AppTextStyles.helper.copyWith(color: AppColors.error)),
          ),
      ],
    );
  }
}

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

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
                  color: isDisabled ? Colors.black.withOpacity(0.5) : Colors.black,
                ),
              ),
      ),
    );
  }
}

class CodeInputField extends StatefulWidget {
  final Function(String) onCodeChanged;
  
  const CodeInputField({Key? key, required this.onCodeChanged}) : super(key: key);

  @override
  State<CodeInputField> createState() => _CodeInputFieldState();
}

class _CodeInputFieldState extends State<CodeInputField> {
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(5, (_) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {}); // Rebuild for border colors
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) { node.dispose(); }
    for (var controller in _controllers) { controller.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 4) {
      _focusNodes[index + 1].requestFocus();
    }
    _updateCode();
  }
  
  void _updateCode() {
    String code = _controllers.map((c) => c.text).join();
    widget.onCodeChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _focusNodes[index].hasFocus ? AppColors.accent : AppColors.border,
              width: 2,
            ),
            boxShadow: _focusNodes[index].hasFocus
                ? [BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 8, spreadRadius: 1)]
                : [],
          ),
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                if (_controllers[index].text.isEmpty && index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: const InputDecoration(
                counterText: "",
                border: InputBorder.none,
              ),
              onChanged: (value) {
                _onChanged(value, index);
              },
            ),
          ),
        );
      }),
    );
  }
}

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => onChanged(!value),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.accent : Colors.transparent,
              border: Border.all(
                color: value ? AppColors.accent : AppColors.secondaryText,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: value
                ? const Icon(Icons.check, size: 16, color: Colors.black)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: label),
      ],
    );
  }
}

class DialogUtils {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.accent),
                const SizedBox(height: 16),
                const Text('Please wait...', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void showSuccessDialog(BuildContext context, {required String title, required String message, required VoidCallback onContinue}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: AppColors.accent, size: 60),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CustomButton(
                text: "CONTINUE",
                onPressed: () {
                  Navigator.pop(context);
                  onContinue();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================================
// SCREENS
// ============================================================================

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
      emailError = (!email.contains("@") || email.isEmpty) ? "Invalid email format" : null;
      passwordError = password.length < 6 ? "Password must be at least 6 characters" : null;
    });

    if (emailError == null && passwordError == null) {
      DialogUtils.showLoadingDialog(context);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      DialogUtils.hideDialog(context);
      DialogUtils.showSuccessDialog(
        context,
        title: "Login Successful",
        message: "Welcome back!",
        onContinue: () {
          // Typically navigate to home screen here
        },
      );
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
              const Text("Audify", style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              const Text("Welcome Back", style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text("Sign in to your account", style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
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
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomCheckbox(
                    value: rememberMe,
                    onChanged: (val) => setState(() => rememberMe = val ?? false),
                    label: const Text("Remember me", style: AppTextStyles.bodySmall),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              GestureDetector(
                onTap: () {
                  NavigationRouter.navigateTo(context, const ForgotPasswordScreen());
                },
                child: Text(
                  "Forgot your password?",
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.accent),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: "SIGN IN",
                onPressed: _validateAndLogin,
              ),
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppColors.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("OR", style: AppTextStyles.helper),
                  ),
                  Expanded(child: Container(height: 1, color: AppColors.border)),
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
      await Future.delayed(const Duration(seconds: 1.5));
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

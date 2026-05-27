import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/motion/app_motion.dart';
import 'core/theme/app_colors.dart';
import 'presentation/auth/screens/welcome_screen.dart';
import 'presentation/main_layout/main_layout_screen.dart';
import 'presentation/auth/screens/verify_email_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SpotifyCloneAuthApp());
}

class SpotifyCloneAuthApp extends StatelessWidget {
  const SpotifyCloneAuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audify Auth',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        pageTransitionsTheme: AppMotion.pageTransitionsTheme,
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
        splashFactory: InkSparkle.splashFactory,
      ),
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user != null) {
          return VerifiedUserGate(user: user);
        }

        return const WelcomeScreen();
      },
    );
  }
}

class VerifiedUserGate extends StatefulWidget {
  final User user;

  const VerifiedUserGate({super.key, required this.user});

  @override
  State<VerifiedUserGate> createState() => _VerifiedUserGateState();
}

class _VerifiedUserGateState extends State<VerifiedUserGate> {
  late Future<bool> _isActiveUser;

  bool _canEnterApp(User user) {
    if (user.emailVerified) return true;
    return user.providerData.any(
      (info) =>
          info.providerId == GoogleAuthProvider.PROVIDER_ID ||
          info.providerId == FacebookAuthProvider.PROVIDER_ID,
    );
  }

  @override
  void initState() {
    super.initState();
    _isActiveUser = _verifyUserStillExists();
  }

  @override
  void didUpdateWidget(VerifiedUserGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _isActiveUser = _verifyUserStillExists();
    }
  }

  Future<bool> _verifyUserStillExists() async {
    try {
      await widget.user.reload();
      return FirebaseAuth.instance.currentUser != null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'user-disabled' ||
          e.code == 'user-token-expired' ||
          e.code == 'invalid-user-token') {
        await FirebaseAuth.instance.signOut();
        return false;
      }

      return FirebaseAuth.instance.currentUser != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isActiveUser,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == true
            ? (_canEnterApp(widget.user)
                  ? const MainLayoutScreen()
                  : VerifyEmailScreen(
                      email: widget.user.email,
                      mode: VerifyEmailMode.registration,
                    ))
            : const WelcomeScreen();
      },
    );
  }
}

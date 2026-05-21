import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'core/motion/app_motion.dart';
import 'core/theme/app_colors.dart';
import 'presentation/auth/screens/welcome_screen.dart';
import 'presentation/main_layout/main_layout_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SpotifyCloneAuthApp());
}

class SpotifyCloneAuthApp extends StatelessWidget {
  const SpotifyCloneAuthApp({Key? key}) : super(key: key);

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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user != null && user.emailVerified) {
            return const MainLayoutScreen();
          }

          return const WelcomeScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

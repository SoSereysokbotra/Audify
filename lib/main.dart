import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'presentation/auth/screens/welcome_screen.dart';

void main() {
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
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

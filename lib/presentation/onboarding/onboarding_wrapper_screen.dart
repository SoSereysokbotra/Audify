import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../data/audify_store.dart';
import '../main_layout/main_layout_screen.dart';
import 'birthday_screen.dart';
import 'idol_selection_screen.dart';

class OnboardingWrapperScreen extends StatefulWidget {
  const OnboardingWrapperScreen({super.key});

  @override
  State<OnboardingWrapperScreen> createState() => _OnboardingWrapperScreenState();
}

class _OnboardingWrapperScreenState extends State<OnboardingWrapperScreen> {
  final PageController _pageController = PageController();
  DateTime? _selectedBirthday;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding(List<String> selectedIdols) async {
    if (_selectedBirthday == null) return;
    
    // Show a loading overlay or just await
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await AudifyStore.instance.completeOnboarding(
      birthday: _selectedBirthday!,
      idolIds: selectedIdols,
    );

    if (mounted) {
      Navigator.pop(context); // pop loading
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          BirthdayScreen(
            onContinue: (birthday) {
              setState(() {
                _selectedBirthday = birthday;
              });
              _goToNextPage();
            },
          ),
          IdolSelectionScreen(
            onComplete: _completeOnboarding,
            onBack: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }
}

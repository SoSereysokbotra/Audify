import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';

class EditEmailScreen extends StatefulWidget {
  const EditEmailScreen({Key? key}) : super(key: key);

  @override
  State<EditEmailScreen> createState() => _EditEmailScreenState();
}

class _EditEmailScreenState extends State<EditEmailScreen> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.email ?? "",
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
      AudifyStore.instance.addNotification(
        category: AudifyNotificationCategory.account,
        title: 'Verification email sent',
        message: 'Check $email to confirm your new email address.',
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent to your new address.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Failed to update email.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Edit Email", style: AppTextStyles.h2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              "Save",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email Address",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.surface,
                hintText: "Enter your email address",
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.secondaryText,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Firebase will send a verification link before changing your email.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

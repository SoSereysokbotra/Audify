import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../data/audify_store.dart';
import '../../auth/screens/welcome_screen.dart';
import 'edit_username_screen.dart';
import 'edit_email_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  void _confirmDeleteAccount() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Account?', style: AppTextStyles.h2),
          content: const Text(
            'This permanently removes your Firebase account. You may need to sign in again first if Firebase requires recent login.',
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                try {
                  await FirebaseAuth.instance.currentUser?.delete();
                  await FirebaseAuth.instance.signOut();
                  if (!mounted) return;
                  NavigationRouter.navigateAndReplace(
                    context,
                    const WelcomeScreen(),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        e.message ??
                            'Could not delete account. Please sign in again.',
                      ),
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Settings & Privacy", style: AppTextStyles.h2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader("Account"),
          ListenableBuilder(
            listenable: AudifyStore.instance,
            builder: (context, _) {
              final currentUser = FirebaseAuth.instance.currentUser;
              final currentProfile = AudifyStore.instance.profile;
              final name = currentUser?.displayName?.trim().isNotEmpty == true
                  ? currentUser!.displayName!
                  : currentProfile.displayName;
              return _buildSettingsTile(
                icon: Icons.person_outline,
                title: "Username",
                subtitle: name,
                onTap: () {
                  Navigator.push(
                    context,
                    AppMotion.route(const EditUsernameScreen()),
                  );
                },
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: user?.email ?? "No email",
            onTap: () {
              Navigator.push(context, AppMotion.route(const EditEmailScreen()));
            },
          ),
          _buildSettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: "Subscription",
            subtitle: "Audify Free",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.delete_outline,
            title: "Delete account",
            subtitle: "Remove your Audify account",
            onTap: _confirmDeleteAccount,
          ),

          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: AppTextStyles.h2.copyWith(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryText,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }

}

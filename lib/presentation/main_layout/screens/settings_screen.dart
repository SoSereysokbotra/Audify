import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'edit_username_screen.dart';
import 'edit_email_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _offlineMode = false;
  bool _dataSaver = false;
  bool _autoplay = true;

  @override
  Widget build(BuildContext context) {
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
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: "Username",
            subtitle: "User Name",
            onTap: () {
              Navigator.push(
                context,
                AppMotion.route(const EditUsernameScreen()),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.email_outlined,
            title: "Email",
            subtitle: "user@example.com",
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
          const Divider(color: AppColors.surface, height: 32),
          _buildSectionHeader("Playback"),
          _buildSwitchTile(
            icon: Icons.wifi_off_outlined,
            title: "Offline Mode",
            subtitle: "Only play downloaded songs",
            value: _offlineMode,
            onChanged: (val) => setState(() => _offlineMode = val),
          ),
          _buildSwitchTile(
            icon: Icons.speed_outlined,
            title: "Data Saver",
            subtitle: "Reduce audio quality to save data",
            value: _dataSaver,
            onChanged: (val) => setState(() => _dataSaver = val),
          ),
          _buildSwitchTile(
            icon: Icons.replay_outlined,
            title: "Autoplay",
            subtitle: "Keep playing similar songs when music ends",
            value: _autoplay,
            onChanged: (val) => setState(() => _autoplay = val),
          ),
          const Divider(color: AppColors.surface, height: 32),
          _buildSectionHeader("Privacy"),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: "Private Session",
            subtitle: "Temporarily hide listening activity",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.people_outline,
            title: "Social",
            subtitle: "Manage sharing and followers",
            onTap: () {},
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.white, size: 24),
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
      value: value,
      onChanged: onChanged,
      activeColor: Colors.pinkAccent,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

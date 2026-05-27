import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../../../core/utils/profile_image_provider.dart';
import '../../../data/audify_store.dart';
import '../../auth/screens/welcome_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../screens/whats_new_screen.dart';
import '../screens/listening_history_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            InkWell(
              onTap: () {
                // Close the drawer before navigating
                Navigator.pop(context);
                Navigator.push(context, AppMotion.route(const ProfileScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    ListenableBuilder(
                      listenable: AudifyStore.instance,
                      builder: (context, _) {
                        final profile = AudifyStore.instance.profile;
                        final firebaseName =
                            FirebaseAuth.instance.currentUser?.displayName;
                        final name = firebaseName?.trim().isNotEmpty == true
                            ? firebaseName!
                            : profile.displayName;
                        final initial = name.trim().isEmpty
                            ? '?'
                            : name.trim()[0].toUpperCase();
                        final imagePath =
                            profile.imagePath ??
                            FirebaseAuth.instance.currentUser?.photoURL;

                        return CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.pinkAccent,
                          backgroundImage: profileImageProvider(imagePath),
                          child: imagePath == null
                              ? Text(
                                  initial,
                                  style: AppTextStyles.h1.copyWith(
                                    color: Colors.black,
                                    fontSize: 20,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListenableBuilder(
                            listenable: AudifyStore.instance,
                            builder: (context, _) {
                              final profile = AudifyStore.instance.profile;
                              final firebaseName = FirebaseAuth
                                  .instance
                                  .currentUser
                                  ?.displayName;
                              final name =
                                  firebaseName?.trim().isNotEmpty == true
                                  ? firebaseName!
                                  : profile.displayName;
                              return Text(name, style: AppTextStyles.h2);
                            },
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "View Profile",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(color: AppColors.surface, thickness: 1),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildDrawerItem(Icons.bolt, "What's new", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      AppMotion.route(const WhatsNewScreen()),
                    );
                  }),
                  ListenableBuilder(
                    listenable: AudifyStore.instance,
                    builder: (context, _) {
                      final unread =
                          AudifyStore.instance.unreadNotificationCount;
                      return _buildDrawerItem(
                        Icons.notifications_none,
                        "Notifications",
                        () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            AppMotion.route(const NotificationsScreen()),
                          );
                        },
                        trailing: unread == 0
                            ? null
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unread > 99 ? '99+' : unread.toString(),
                                  style: AppTextStyles.helper.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                  _buildDrawerItem(Icons.history, "Listening history", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      AppMotion.route(const ListeningHistoryScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.settings, "Settings and privacy", () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      AppMotion.route(const SettingsScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.logout, "Log out", () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      NavigationRouter.navigateAndReplace(
                        context,
                        const WelcomeScreen(),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 28),
      title: Text(title, style: AppTextStyles.bodyLarge),
      trailing: trailing,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: onTap,
    );
  }
}

import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/profile_image_provider.dart';
import '../../../data/audify_store.dart';
import '../../library/screens/playlist_details_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Share Profile', style: AppTextStyles.h2),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareIcon(Icons.copy, 'Copy Link', Colors.blueGrey),
                    _buildShareIcon(Icons.message, 'Messages', Colors.green),
                    _buildShareIcon(
                      Icons.camera_alt,
                      'Instagram',
                      Colors.pinkAccent,
                    ),
                    _buildShareIcon(
                      Icons.more_horiz,
                      'More',
                      AppColors.secondaryText,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondaryText, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.helper),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  String _signInMethods(User? user) {
    if (user == null || user.providerData.isEmpty) return 'Not available';
    return user.providerData
        .map((info) {
          switch (info.providerId) {
            case 'password':
              return 'Email and password';
            case 'google.com':
              return 'Google';
            case 'facebook.com':
              return 'Facebook';
            case 'phone':
              return 'Phone';
            default:
              return info.providerId;
          }
        })
        .toSet()
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AudifyStore.instance,
      builder: (context, _) {
        final store = AudifyStore.instance;
        final profile = store.profile;
        final user = FirebaseAuth.instance.currentUser;
        final displayName = user?.displayName?.trim().isNotEmpty == true
            ? user!.displayName!
            : profile.displayName;
        final initial = displayName.trim().isEmpty
            ? '?'
            : displayName.trim()[0].toUpperCase();
        final email = user?.email?.trim().isNotEmpty == true
            ? user!.email!
            : 'No email connected';
        final emailStatus = user == null
            ? 'Not signed in'
            : user.emailVerified
            ? 'Verified'
            : 'Not verified';
        final profileImagePath = profile.imagePath ?? user?.photoURL;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 450.0,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.background,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.primaryText,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.primaryText,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        AppMotion.route(const EditProfileScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.primaryText,
                    ),
                    onPressed: () => _showShareModal(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (profileImagePath != null)
                        Image(
                          image: profileImageProvider(profileImagePath)!,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        )
                      else
                        Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.pinkAccent,
                                    Color(0xFF282828),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 78,
                                backgroundColor: Colors.black,
                                child: Text(
                                  initial,
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 64,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.38, 0.78, 1.0],
                            colors: [
                              Colors.transparent,
                              AppColors.background.withValues(alpha: 0.62),
                              AppColors.background,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: AppTextStyles.h1,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check,
                              size: 16,
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(profile.bio, style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const Icon(
                            Icons.person_outline,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            store.favoriteSongIds.length.toString(),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.my_library_books_outlined,
                            size: 20,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            store.playlists.length.toString(),
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                AppMotion.route(const EditProfileScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: AppTextStyles.button,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Account information',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.badge_outlined, 'Name', displayName),
                      _buildInfoRow(Icons.email_outlined, 'Email', email),
                      _buildInfoRow(
                        Icons.verified_user_outlined,
                        'Email status',
                        emailStatus,
                      ),
                      _buildInfoRow(
                        Icons.lock_outline,
                        'Sign-in method',
                        _signInMethods(user),
                      ),
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Joined',
                        _formatDate(user?.metadata.creationTime),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.border, height: 1),
                      const SizedBox(height: 32),
                      const Text('Playlists', style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      if (store.playlists.isEmpty)
                        const Text(
                          'Create playlists to show them on your profile.',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 40.0),
                sliver: SliverList.builder(
                  itemCount: store.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = store.playlists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          playlist.coverUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        playlist.title,
                        style: AppTextStyles.bodyLarge,
                      ),
                      subtitle: Text(
                        playlist.description.isEmpty
                            ? 'Playlist ${playlist.songIds.length} songs'
                            : playlist.description,
                        style: AppTextStyles.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.more_vert,
                        color: AppColors.secondaryText,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          AppMotion.route(
                            PlaylistDetailsScreen(playlistId: playlist.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
            ],
          ),
        );
      },
    );
  }
}

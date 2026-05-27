import 'package:flutter/material.dart';

import '../../data/collaborative_store.dart';
import '../../presentation/library/screens/blend_generate_screen.dart';
import '../../presentation/library/screens/create_collaborative_screen.dart';
import '../../presentation/library/screens/create_playlist_screen.dart';
import '../motion/app_motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CreateOptionsSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.music_note,
                  color: AppColors.primaryText,
                  size: 28,
                ),
                title: const Text('Playlist', style: AppTextStyles.bodyLarge),
                subtitle: Text(
                  'Build a playlist with songs or episodes',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    AppMotion.route(
                      const CreatePlaylistScreen(),
                      duration: AppMotion.relaxed,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.group,
                  color: AppColors.primaryText,
                  size: 28,
                ),
                title: const Text(
                  'Collaborative Playlist',
                  style: AppTextStyles.bodyLarge,
                ),
                subtitle: Text(
                  'Make a playlist with friends',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    AppMotion.route(
                      const CreateCollaborativeScreen(),
                      duration: AppMotion.relaxed,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.people,
                  color: AppColors.primaryText,
                  size: 28,
                ),
                title: const Text('Blend', style: AppTextStyles.bodyLarge),
                subtitle: Text(
                  'Combine tastes in a shared playlist with friends',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryText,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    final blendId = await CollaborativeStore.instance
                        .createBlendInvite();
                    if (!context.mounted) return;
                    Navigator.push(
                      context,
                      AppMotion.route(BlendGenerateScreen(blendId: blendId)),
                    );
                  } catch (e) {
                    debugPrint('Error creating blend: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

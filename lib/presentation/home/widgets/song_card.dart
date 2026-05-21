import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

class SongCard extends StatelessWidget {
  final SongModel song;

  const SongCard({Key? key, required this.song}) : super(key: key);

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.favorite_border,
                  color: AppColors.primaryText,
                ),
                title: const Text(
                  "Add to Favorites",
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.playlist_add,
                  color: AppColors.primaryText,
                ),
                title: const Text(
                  "Add to Playlist",
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share, color: AppColors.primaryText),
                title: const Text("Share", style: AppTextStyles.bodyLarge),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppPressScale(
      onTap: () {
        Navigator.push(
          context,
          AppMotion.route(
            NowPlayingScreen(
              title: song.title,
              artist: song.artist,
              imagePath: song.coverUrl,
            ),
          ),
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              song.coverUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.secondaryText),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }
}

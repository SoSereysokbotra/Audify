import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

class SongCard extends StatelessWidget {
  final SongModel song;

  const SongCard({Key? key, required this.song}) : super(key: key);

  void _showPlaylistPicker(BuildContext context) {
    final store = AudifyStore.instance;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final playlists = store.playlists;
            return SafeArea(
              child: playlists.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Create a playlist first, then add songs to it.',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final alreadyAdded = playlist.songIds.contains(song.id);
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              playlist.coverUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            playlist.title,
                            style: AppTextStyles.bodyLarge,
                          ),
                          subtitle: Text(
                            '${playlist.songIds.length} songs',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: Icon(
                            alreadyAdded
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: alreadyAdded
                                ? AppColors.accent
                                : AppColors.secondaryText,
                          ),
                          onTap: alreadyAdded
                              ? null
                              : () {
                                  store.addSongToPlaylist(playlist.id, song.id);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${song.title} to ${playlist.title}',
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  void _showOptions(BuildContext context) {
    final store = AudifyStore.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final isFavorite = store.isFavorite(song.id);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? AppColors.accent
                          : AppColors.primaryText,
                    ),
                    title: Text(
                      isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      style: AppTextStyles.bodyLarge,
                    ),
                    onTap: () {
                      store.toggleFavorite(song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removed ${song.title} from favorites'
                                : 'Added ${song.title} to favorites',
                          ),
                        ),
                      );
                    },
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
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaylistPicker(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.share,
                      color: AppColors.primaryText,
                    ),
                    title: const Text("Share", style: AppTextStyles.bodyLarge),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openPlayer(BuildContext context) async {
    try {
      await LocalAudioPlayer.instance.playSong(song);
      if (!context.mounted) return;
      Navigator.push(context, AppMotion.route(NowPlayingScreen(song: song)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add the file ${song.localAudioPath ?? 'for this song'} first.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPressScale(
      onTap: () => _openPlayer(context),
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
          ListenableBuilder(
            listenable: AudifyStore.instance,
            builder: (context, _) {
              final isFavorite = AudifyStore.instance.isFavorite(song.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.more_vert,
                  color: isFavorite
                      ? AppColors.accent
                      : AppColors.secondaryText,
                ),
                onPressed: () => _showOptions(context),
              );
            },
          ),
        ],
      ),
    );
  }
}

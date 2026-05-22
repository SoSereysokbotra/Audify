import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

class ListeningHistoryScreen extends StatelessWidget {
  const ListeningHistoryScreen({super.key});

  String _sectionTitle(DateTime playedAt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final playedDay = DateTime(playedAt.year, playedAt.month, playedAt.day);
    final difference = today.difference(playedDay).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return 'Earlier';
  }

  String _relativeTime(DateTime playedAt) {
    final difference = DateTime.now().difference(playedAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    }
    if (difference.inDays == 1) return '1 day ago';
    return '${difference.inDays} days ago';
  }

  Future<void> _openPlayer(BuildContext context, SongModel song) async {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Listening History', style: AppTextStyles.h2),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListenableBuilder(
        listenable: AudifyStore.instance,
        builder: (context, _) {
          final entries = AudifyStore.instance.listeningHistory;

          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Play a song and it will appear here instantly.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            );
          }

          final children = <Widget>[];
          String? currentSection;

          for (final entry in entries) {
            final section = _sectionTitle(entry.playedAt);
            if (section != currentSection) {
              children.add(_buildSectionHeader(section));
              currentSection = section;
            }

            children.add(
              _buildHistoryItem(
                song: entry.song,
                time: _relativeTime(entry.playedAt),
                onTap: () => _openPlayer(context, entry.song),
              ),
            );
          }

          children.add(const SizedBox(height: 48));

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            children: children,
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0, top: 8.0),
      child: Text(title, style: AppTextStyles.h2.copyWith(fontSize: 18)),
    );
  }

  Widget _buildHistoryItem({
    required SongModel song,
    required String time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.coverUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 56,
            height: 56,
            color: AppColors.surface,
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
        ),
      ),
      title: Text(
        song.title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist} - $time',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.play_arrow_rounded, color: Colors.white),
      onTap: onTap,
    );
  }
}

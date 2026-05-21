import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../domain/models/song_model.dart';

class FavoriteSongsScreen extends StatelessWidget {
  const FavoriteSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AudifyStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final songs = store.favoriteSongs;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('Liked Songs')),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              Container(
                height: 150,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4B14C5), Color(0xFFC7E2F1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text('Liked Songs', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('${songs.length} songs', style: AppTextStyles.bodySmall),
              const SizedBox(height: 24),
              if (songs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Text(
                    'Songs you favorite will appear here.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                )
              else
                ...songs.map(
                  (song) => _FavoriteSongTile(
                    song: song,
                    onRemove: () {
                      store.removeFavorite(song.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed ${song.title}')),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _FavoriteSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onRemove;

  const _FavoriteSongTile({required this.song, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          song.coverUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(song.title, style: AppTextStyles.bodyLarge),
      subtitle: Text(song.artist, style: AppTextStyles.bodySmall),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: AppColors.accent),
        onPressed: onRemove,
      ),
    );
  }
}

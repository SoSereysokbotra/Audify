import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/song_model.dart';
import '../screens/song_collection_screen.dart';
import 'album_card.dart';

class PopularAlbumsSection extends StatelessWidget {
  const PopularAlbumsSection({super.key});

  List<SongModel> _songsForAlbum(int index) {
    final songs = MockData.localSongs;
    if (songs.isEmpty) {
      return const [];
    }

    final start = (index * 4) % songs.length;
    return List.generate(5, (offset) => songs[(start + offset) % songs.length]);
  }

  void _openAlbum(BuildContext context, int index) {
    final album = MockData.popularAlbums[index];
    Navigator.push(
      context,
      AppMotion.route(
        SongCollectionScreen(
          title: album.title,
          subtitle: album.artist,
          coverUrl: album.coverUrl,
          songs: _songsForAlbum(index),
        ),
      ),
    );
  }

  void _openAll(BuildContext context) {
    Navigator.push(
      context,
      AppMotion.route(
        const SongCollectionScreen(
          title: 'Popular albums and singles',
          subtitle: 'All local songs ready to play',
          coverUrl: 'https://picsum.photos/id/1082/400/400',
          songs: MockData.localSongs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  "Popular albums and singles",
                  style: AppTextStyles.h1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _openAll(context),
                child: Text(
                  "See all",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75, // Adjust for image + text below
          ),
          itemCount: MockData.popularAlbums.length,
          itemBuilder: (context, index) {
            return AlbumCard(
              album: MockData.popularAlbums[index],
              onTap: () => _openAlbum(context, index),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../screens/song_collection_screen.dart';

class TrendingArtistsSection extends StatelessWidget {
  const TrendingArtistsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Trending artists", style: AppTextStyles.h1),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: MockData.trendingArtists.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final artist = MockData.trendingArtists[index];
              final artistSongs = AudifyStore.instance.songs
                  .where((song) => song.artist.contains(artist.name))
                  .toList();
              final songs = artistSongs.isEmpty
                  ? AudifyStore.instance.songs.skip(index).take(3).toList()
                  : artistSongs;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    AppMotion.route(
                      SongCollectionScreen(
                        title: artist.name,
                        subtitle: 'Trending artist',
                        coverUrl: artist.imageUrl,
                        songs: songs,
                      ),
                    ),
                  );
                },
                child: SizedBox(
                  width: 100,
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(artist.imageUrl),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artist.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

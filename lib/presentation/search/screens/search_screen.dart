import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/album_model.dart';
import '../../../domain/models/mix_model.dart';
import '../../../domain/models/radio_station_model.dart';
import '../../../domain/models/song_model.dart';
import '../../home/widgets/song_card.dart';
import '../widgets/genre_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SongModel> _filteredSongs(List<SongModel> songs) {
    final query = _searchController.text.trim().toLowerCase();
    final category = _selectedCategory;
    final categorySongs = category == null ? songs : _songsForCategory(songs);
    if (query.isEmpty) return categorySongs;

    return categorySongs
        .where((song) {
          return song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  List<SongModel> _songsForCategory(List<SongModel> songs) {
    switch (_selectedCategory) {
      case 'Podcasts':
        return songs.take(4).toList(growable: false);
      case 'Live Events':
        return songs
            .where(
              (song) =>
                  song.artist.contains('Lana') ||
                  song.artist.contains('Arctic') ||
                  song.artist.contains('Bruno'),
            )
            .toList(growable: false);
      case 'Made For You':
        return [
          songs[0],
          songs[2],
          songs[4],
          songs[8],
          songs[15],
        ].whereType<SongModel>().toList(growable: false);
      case 'New Releases':
        return songs.take(6).toList(growable: false);
      case 'Khmer Music':
        return songs
            .where(
              (song) =>
                  song.artist.toLowerCase().contains('khmer') ||
                  song.artist.toLowerCase().contains('tena') ||
                  song.artist.toLowerCase().contains('chhorn'),
            )
            .toList(growable: false);
      case 'Pop':
        return songs
            .where(
              (song) =>
                  song.artist.contains('Katy') ||
                  song.artist.contains('Justin') ||
                  song.artist.contains('Charlie') ||
                  song.artist.contains('Taylor'),
            )
            .toList(growable: false);
      case 'Hip-Hop':
        return songs
            .where(
              (song) =>
                  song.artist.toLowerCase().contains('tena') ||
                  song.artist.toLowerCase().contains('khmer'),
            )
            .toList(growable: false);
      case 'Charts':
        return songs.take(10).toList(growable: false);
      default:
        return songs;
    }
  }

  void _selectCategory(String category) {
    _searchController.clear();
    setState(() => _selectedCategory = category);
  }

  Widget _buildAlbumTile(AlbumModel album) {
    return _buildMediaTile(
      title: album.title,
      subtitle: album.artist,
      imageUrl: album.coverUrl,
      icon: Icons.album,
    );
  }

  Widget _buildMixTile(MixModel mix) {
    return _buildMediaTile(
      title: mix.title,
      subtitle: mix.subtitle,
      imageUrl: mix.coverUrl,
      icon: Icons.auto_awesome,
    );
  }

  Widget _buildRadioTile(RadioStationModel station) {
    return _buildMediaTile(
      title: station.name,
      subtitle: station.featuredArtists,
      imageUrl: station.coverUrls.first,
      icon: Icons.podcasts,
    );
  }

  Widget _buildMediaTile({
    required String title,
    required String subtitle,
    required String imageUrl,
    required IconData icon,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              width: 180,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 180,
                  height: 110,
                  color: const Color(0xFF2A2A2A),
                  child: Icon(icon, color: Colors.white, size: 32),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFeatureSection() {
    final category = _selectedCategory;
    if (category == null) return const SizedBox.shrink();

    final children = switch (category) {
      'Podcasts' => MockData.popularRadio.map(_buildRadioTile).toList(),
      'Live Events' =>
        MockData.trendingArtists
            .map(
              (artist) => _buildMediaTile(
                title: '${artist.name} Live',
                subtitle: 'Concert sessions and artist events',
                imageUrl: artist.imageUrl,
                icon: Icons.event,
              ),
            )
            .toList(),
      'Made For You' => MockData.madeForYou.map(_buildMixTile).toList(),
      'New Releases' => MockData.newReleases.map(_buildAlbumTile).toList(),
      'Charts' => MockData.popularAlbums.map(_buildAlbumTile).toList(),
      _ => <Widget>[],
    };

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(category, style: AppTextStyles.h2),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(children: children),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final hasSelectedCategory = _selectedCategory != null;

    return Scaffold(
      // Using a modern background color if applicable, otherwise relies on Theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Modern Collapsing App Bar
            SliverAppBar(
              expandedHeight: 80.0,
              floating: true,
              pinned: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                title: const Text("Search", style: AppTextStyles.h1),
              ),
            ),

            SliverToBoxAdapter(
              child: AppMotionEntry(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          cursorColor: Colors.black,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: "What do you want to listen to?",
                            hintStyle: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey[800],
                              size: 24,
                            ),
                            suffixIcon: query.isEmpty
                                ? Icon(
                                    Icons.mic_none_rounded,
                                    color: Colors.grey[600],
                                    size: 24,
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey[700],
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (query.isEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip("Podcasts"),
                              _buildFilterChip("Live Events"),
                              _buildFilterChip("Made For You"),
                              _buildFilterChip("New Releases"),
                            ],
                          ),
                        ),
                      if (query.isEmpty) ...[
                        const SizedBox(height: 32),
                        if (hasSelectedCategory) _buildCategoryFeatureSection(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hasSelectedCategory
                                  ? "More to explore"
                                  : "Browse all",
                              style: AppTextStyles.h2,
                            ),
                            if (hasSelectedCategory)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _selectedCategory = null);
                                },
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('Clear'),
                              )
                            else
                              Icon(Icons.more_horiz, color: Colors.grey[500]),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // 5. Refined Grid Layout
            if (query.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio:
                        1.5, // Slightly adjusted for modern wide cards
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final genre = MockData.browseGenres[index];
                    return AppMotionEntry(
                      delay: Duration(milliseconds: 40 * index),
                      child: GenreCard(
                        genre: genre,
                        onTap: () => _selectCategory(genre.title),
                      ),
                    );
                  }, childCount: MockData.browseGenres.length),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      query.isEmpty
                          ? _selectedCategory == null
                                ? "Available songs"
                                : 'Songs for $_selectedCategory'
                          : 'Songs matching "$query"',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: AudifyStore.instance,
                      builder: (context, _) {
                        final songs = _filteredSongs(
                          AudifyStore.instance.songs,
                        );
                        if (songs.isEmpty) {
                          final emptyMessage = query.isEmpty
                              ? 'No songs available for $_selectedCategory yet.'
                              : 'No songs found for "$query".';
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                emptyMessage,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: songs
                              .map(
                                (song) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SongCard(song: song),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
              ), // Generous bottom padding for nav bars or mini players
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for modern filter chips
  Widget _buildFilterChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          setState(() {
            _selectedCategory = isSelected ? null : label;
            _searchController.clear();
          });
        },
        child: AnimatedContainer(
          duration: AppMotion.quick,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

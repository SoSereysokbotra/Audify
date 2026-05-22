import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/profile_image_provider.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../../home/widgets/song_card.dart';
import '../../main_layout/widgets/profile_drawer.dart';
import '../widgets/library_filter_pills.dart';
import '../widgets/library_list_item.dart';
import 'create_playlist_screen.dart';
import 'favorite_songs_screen.dart';
import 'playlist_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddOptions(BuildContext context) {
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
    return Scaffold(
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: AppColors.background,
              pinned: true,
              elevation: 0,
              expandedHeight: 60,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (_isSearching)
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              onChanged: (_) => setState(() {}),
                              style: AppTextStyles.bodyLarge,
                              decoration: InputDecoration(
                                hintText: 'Search Your Library',
                                hintStyle: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.primaryText,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.primaryText,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: AppColors.primaryText,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = false;
                                      _searchController.clear();
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                        )
                      else ...[
                        Builder(
                          builder: (context) {
                            return GestureDetector(
                              onTap: () => Scaffold.of(context).openDrawer(),
                              child: ListenableBuilder(
                                listenable: AudifyStore.instance,
                                builder: (context, _) {
                                  final name =
                                      AudifyStore.instance.profile.displayName;
                                  final initial = name.trim().isEmpty
                                      ? '?'
                                      : name.trim()[0].toUpperCase();
                                  final imagePath =
                                      AudifyStore.instance.profile.imagePath ??
                                      FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.photoURL;

                                  return CircleAvatar(
                                    radius: 18,
                                    backgroundColor: Colors.pinkAccent,
                                    backgroundImage: profileImageProvider(
                                      imagePath,
                                    ),
                                    child: imagePath == null
                                        ? Text(
                                            initial,
                                            style: AppTextStyles.h2.copyWith(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text('Your Library', style: AppTextStyles.h1),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () => _showAddOptions(context),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _LibraryHeaderDelegate(
                child: Container(
                  color: AppColors.background,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: LibraryFilterPills(),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.swap_vert,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recently played',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.grid_view,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ListenableBuilder(
                listenable: AudifyStore.instance,
                builder: (context, _) {
                  final store = AudifyStore.instance;
                  final query = _searchController.text.trim().toLowerCase();
                  final playlists = store.playlists.where((playlist) {
                    if (query.isEmpty) return true;
                    return playlist.title.toLowerCase().contains(query) ||
                        playlist.description.toLowerCase().contains(query);
                  }).toList();
                  final songs = store.songs.where((song) {
                    if (query.isEmpty) return false;
                    return song.title.toLowerCase().contains(query) ||
                        song.artist.toLowerCase().contains(query);
                  }).toList();
                  final hasSearchResults =
                      query.isEmpty || playlists.isNotEmpty || songs.isNotEmpty;

                  return Column(
                    children: [
                      if (query.isEmpty)
                        AppMotionEntry(
                          child: LibraryListItem(
                            title: 'Liked Songs',
                            subtitle:
                                'Playlist - ${store.favoriteSongs.length} songs',
                            imageUrl: '',
                            isPinned: true,
                            customLeading: Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4B14C5),
                                    Color(0xFFC7E2F1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                AppMotion.route(const FavoriteSongsScreen()),
                              );
                            },
                          ),
                        ),
                      if (songs.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Songs',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        ...songs.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: SongCard(song: entry.value),
                            ),
                          ),
                        ),
                      ],
                      if (query.isNotEmpty && playlists.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Playlists',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ...playlists.asMap().entries.map(
                        (entry) => AppMotionEntry(
                          delay: Duration(milliseconds: 40 * entry.key),
                          child: LibraryListItem(
                            title: entry.value.title,
                            subtitle:
                                'Playlist - ${entry.value.creator} - ${entry.value.songIds.length} songs',
                            imageUrl: entry.value.coverUrl,
                            onTap: () {
                              Navigator.push(
                                context,
                                AppMotion.route(
                                  PlaylistDetailsScreen(
                                    playlistId: entry.value.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      if (!hasSearchResults)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                          child: Text(
                            'No local songs or playlists found.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      if (query.isEmpty) ...[
                        ...MockData.trendingArtists.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: LibraryListItem(
                              title: entry.value.name,
                              subtitle: 'Artist',
                              imageUrl: entry.value.imageUrl,
                              isArtist: true,
                            ),
                          ),
                        ),
                        ...MockData.popularAlbums.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: LibraryListItem(
                              title: entry.value.title,
                              subtitle: 'Album - ${entry.value.artist}',
                              imageUrl: entry.value.coverUrl,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _LibraryHeaderDelegate({required this.child});

  @override
  double get minExtent => 110.0;

  @override
  double get maxExtent => 110.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

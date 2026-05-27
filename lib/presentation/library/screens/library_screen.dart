import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/create_options_sheet.dart';
import '../../../core/utils/profile_image_provider.dart';
import '../../../data/audify_store.dart';
import '../../../data/collaborative_store.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/artist_model.dart';
import '../../home/widgets/song_card.dart';
import '../../main_layout/widgets/profile_drawer.dart';
import 'album_details_screen.dart';
import 'choose_artists_screen.dart';
import 'choose_podcasts_screen.dart';
import 'collaborative_playlist_screen.dart';
import '../widgets/library_filter_pills.dart';
import '../widgets/library_list_item.dart';
import '../widgets/playlist_cover_art.dart';
import 'favorite_songs_screen.dart';
import 'playlist_details_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isSearching = false;
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> _pickAudioFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );
    if (result == null) return [];
    return result.files.map((file) => file.path).whereType<String>().toList();
  }

  Future<void> _handleImportMusic() async {
    final paths = await _pickAudioFiles();
    if (!mounted || paths.isEmpty) return;

    final count = AudifyStore.instance.importLocalAudioFiles(paths);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count == 0
              ? 'Those songs are already in your library.'
              : count == 1
              ? 'Imported 1 song.'
              : 'Imported $count songs.',
        ),
      ),
    );
  }

  void _openPodcastPicker() {
    Navigator.push(
      context,
      AppMotion.route(
        const ChoosePodcastsScreen(),
        duration: AppMotion.relaxed,
      ),
    );
  }

  void _openArtistsPicker() {
    Navigator.push(
      context,
      AppMotion.route(const ChooseArtistsScreen(), duration: AppMotion.relaxed),
    );
  }

  List<ArtistModel> _selectedIdolsFor(AudifyStore store, String query) {
    final selectedIds = store.profile.favoriteIdols.toSet();
    return MockData.mockIdols
        .where((idol) {
          if (!selectedIds.contains(idol.id)) return false;
          if (query.isEmpty) return true;
          return idol.name.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Widget _buildActionLeading(IconData icon) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primaryText),
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
                          onPressed: () => CreateOptionsSheet.show(context),
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
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isGridView = !_isGridView;
                                });
                              },
                              child: Icon(
                                _isGridView ? Icons.list : Icons.grid_view,
                                color: Colors.white,
                                size: 20,
                              ),
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
                listenable: Listenable.merge([
                  AudifyStore.instance,
                  CollaborativeStore.instance,
                ]),
                builder: (context, _) {
                  final store = AudifyStore.instance;
                  final query = _searchController.text.trim().toLowerCase();
                  final playlists = store.playlists.where((playlist) {
                    if (query.isEmpty) return true;
                    return playlist.title.toLowerCase().contains(query) ||
                        playlist.description.toLowerCase().contains(query);
                  }).toList();
                  final collaborativePlaylists = CollaborativeStore
                      .instance
                      .collaborativePlaylists
                      .where((playlist) {
                        if (query.isEmpty) return true;
                        return playlist.name.toLowerCase().contains(query) ||
                            playlist.description.toLowerCase().contains(query);
                      })
                      .toList();
                  final selectedIdols = _selectedIdolsFor(store, query);
                  final podcasts = store.podcasts.where((podcast) {
                    if (query.isEmpty) return true;
                    return podcast.title.toLowerCase().contains(query);
                  }).toList();
                  final songs = store.songs.where((song) {
                    if (query.isEmpty) {
                      return song.id.startsWith('local_');
                    }
                    return song.title.toLowerCase().contains(query) ||
                        song.artist.toLowerCase().contains(query);
                  }).toList();
                  final hasSearchResults =
                      query.isEmpty ||
                      playlists.isNotEmpty ||
                      collaborativePlaylists.isNotEmpty ||
                      selectedIdols.isNotEmpty ||
                      podcasts.isNotEmpty ||
                      songs.isNotEmpty;

                  return Column(
                    children: [
                      if (_isGridView)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              if (query.isEmpty)
                                AppMotionEntry(
                                  child: _buildGridItem(
                                    title: 'Liked Songs',
                                    subtitle:
                                        'Playlist - ${store.favoriteSongs.length} songs',
                                    imageUrl: '',
                                    customLeading: Container(
                                      width:
                                          (MediaQuery.of(context).size.width -
                                              32 -
                                              16) /
                                          2,
                                      height:
                                          (MediaQuery.of(context).size.width -
                                              32 -
                                              16) /
                                          2,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        gradient: const LinearGradient(
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
                                        size: 48,
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        AppMotion.route(
                                          const FavoriteSongsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ...playlists.asMap().entries.map(
                                (entry) => AppMotionEntry(
                                  delay: Duration(milliseconds: 40 * entry.key),
                                  child: _buildGridItem(
                                    title: entry.value.title,
                                    subtitle:
                                        'Playlist - ${entry.value.creator} - ${entry.value.songIds.length} songs',
                                    imageUrl: entry.value.coverUrl,
                                    customLeading: PlaylistCoverArt(
                                      coverUrl: entry.value.coverUrl,
                                      songs: store.songsForPlaylist(
                                        entry.value.id,
                                      ),
                                      size:
                                          (MediaQuery.of(context).size.width -
                                              32 -
                                              16) /
                                          2,
                                      borderRadius: 8,
                                    ),
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
                              ...collaborativePlaylists.asMap().entries.map(
                                (entry) => AppMotionEntry(
                                  delay: Duration(milliseconds: 40 * entry.key),
                                  child: _buildGridItem(
                                    title: entry.value.name,
                                    subtitle:
                                        'Collaborative playlist - ${entry.value.songs.length} songs',
                                    imageUrl: entry.value.coverUrl,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        AppMotion.route(
                                          CollaborativePlaylistScreen(
                                            playlistId: entry.value.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              ...selectedIdols.asMap().entries.map(
                                (entry) => AppMotionEntry(
                                  delay: Duration(milliseconds: 40 * entry.key),
                                  child: _buildGridItem(
                                    title: entry.value.name,
                                    subtitle: 'Artist',
                                    imageUrl: entry.value.imageUrl,
                                    isArtist: true,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        AppMotion.route(
                                          AlbumDetailsScreen(
                                            title: entry.value.name,
                                            artist: entry.value.name,
                                            imageUrl: entry.value.imageUrl,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        if (query.isEmpty) ...[
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
                          AppMotionEntry(
                            delay: const Duration(milliseconds: 40),
                            child: LibraryListItem(
                              title: 'Add podcasts',
                              subtitle: 'Choose shows for your library',
                              imageUrl: '',
                              customLeading: _buildActionLeading(
                                Icons.podcasts,
                              ),
                              trailing: const Icon(
                                Icons.add,
                                color: AppColors.secondaryText,
                              ),
                              onTap: _openPodcastPicker,
                            ),
                          ),
                          AppMotionEntry(
                            delay: const Duration(milliseconds: 80),
                            child: LibraryListItem(
                              title: 'Add artists',
                              subtitle: 'Follow more artists in your library',
                              imageUrl: '',
                              customLeading: _buildActionLeading(
                                Icons.person_add_alt_1,
                              ),
                              trailing: const Icon(
                                Icons.add,
                                color: AppColors.secondaryText,
                              ),
                              onTap: _openArtistsPicker,
                            ),
                          ),
                          AppMotionEntry(
                            delay: const Duration(milliseconds: 120),
                            child: LibraryListItem(
                              title: 'Import your music',
                              subtitle: 'Add audio files from this device',
                              imageUrl: '',
                              customLeading: _buildActionLeading(
                                Icons.upload_file,
                              ),
                              trailing: const Icon(
                                Icons.add,
                                color: AppColors.secondaryText,
                              ),
                              onTap: _handleImportMusic,
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
                              customLeading: PlaylistCoverArt(
                                coverUrl: entry.value.coverUrl,
                                songs: store.songsForPlaylist(entry.value.id),
                              ),
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
                        ...collaborativePlaylists.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: LibraryListItem(
                              title: entry.value.name,
                              subtitle:
                                  'Collaborative playlist - ${entry.value.songs.length} songs',
                              imageUrl: entry.value.coverUrl,
                              trailing: const Icon(
                                Icons.groups_2_outlined,
                                color: AppColors.secondaryText,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AppMotion.route(
                                    CollaborativePlaylistScreen(
                                      playlistId: entry.value.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        ...selectedIdols.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: LibraryListItem(
                              title: entry.value.name,
                              subtitle: 'Artist',
                              imageUrl: entry.value.imageUrl,
                              isArtist: true,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  AppMotion.route(
                                    AlbumDetailsScreen(
                                      title: entry.value.name,
                                      artist: entry.value.name,
                                      imageUrl: entry.value.imageUrl,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        ...podcasts.asMap().entries.map(
                          (entry) => AppMotionEntry(
                            delay: Duration(milliseconds: 40 * entry.key),
                            child: LibraryListItem(
                              title: entry.value.title,
                              subtitle: entry.value.description,
                              imageUrl: entry.value.coverUrl,
                              customLeading: entry.value.coverUrl.isEmpty
                                  ? _buildActionLeading(Icons.podcasts)
                                  : null,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildGridItem({
    required String title,
    required String subtitle,
    required String imageUrl,
    Widget? customLeading,
    bool isArtist = false,
    required VoidCallback onTap,
  }) {
    return AppPressScale(
      onTap: onTap,
      child: SizedBox(
        width:
            (MediaQuery.of(context).size.width - 32 - 16) /
            2, // 2 items per row
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            customLeading ??
                Container(
                  width: double.infinity,
                  height: (MediaQuery.of(context).size.width - 32 - 16) / 2,
                  decoration: BoxDecoration(
                    shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
                    borderRadius: isArtist ? null : BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
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
  double get minExtent => 120.0;

  @override
  double get maxExtent => 120.0;

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
    return true;
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _browseLocalMusic() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: true,
      );
      final paths = result?.files
          .map((file) => file.path)
          .whereType<String>()
          .toList(growable: false);

      if (paths == null || paths.isEmpty) return;

      final addedCount = AudifyStore.instance.importLocalAudioFiles(paths);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addedCount == 0
                ? 'Those songs are already in your local music.'
                : 'Added $addedCount local song${addedCount == 1 ? '' : 's'}.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not browse local music: $e')),
      );
    }
  }

  List<SongModel> _filteredSongs(List<SongModel> songs) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return songs;

    return songs
        .where((song) {
          return song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();

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
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _browseLocalMusic,
                          icon: const Icon(Icons.folder_open_rounded),
                          label: const Text('Browse local music'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                        // 4. Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Browse all", style: AppTextStyles.h2),
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
                    return AppMotionEntry(
                      delay: Duration(milliseconds: 40 * index),
                      child: GenreCard(genre: MockData.browseGenres[index]),
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
                          ? "Available songs"
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No local songs found for "$query".',
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
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(
            0xFF2A2A2A,
          ), // Adjust to match your AppColors theme
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

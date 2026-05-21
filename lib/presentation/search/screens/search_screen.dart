import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../../home/widgets/song_card.dart';
import '../widgets/genre_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                      // 2. Elevated & Interactive Search Bar
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // TODO: Navigate to active search input screen
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey[800],
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "What do you want to listen to?",
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.mic_none_rounded,
                                  color: Colors.grey[600],
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 3. Quick Action Filters (Modern Addition)
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
                  ),
                ),
              ),
            ),

            // 5. Refined Grid Layout
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
                    const Text("Available songs", style: AppTextStyles.h2),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: AudifyStore.instance,
                      builder: (context, _) {
                        return Column(
                          children: AudifyStore.instance.songs
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

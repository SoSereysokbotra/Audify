import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';
import '../widgets/library_filter_pills.dart';
import '../widgets/library_list_item.dart';
import '../../main_layout/widgets/profile_drawer.dart';
import 'create_playlist_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              automaticallyImplyLeading:
                  false, // Prevents the back arrow from appearing
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
                              style: AppTextStyles.bodyLarge,
                              decoration: InputDecoration(
                                hintText: "Search Your Library",
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
                        GestureDetector(
                          onTap: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "N",
                              style: AppTextStyles.h2.copyWith(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text("Your Library", style: AppTextStyles.h1),
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
                              "Recently played",
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
            SliverList(
              delegate: SliverChildListDelegate([
                AppMotionEntry(
                  child: LibraryListItem(
                    title: "Liked Songs",
                    subtitle: "Playlist • 120 songs",
                    imageUrl: "",
                    isPinned: true,
                    customLeading: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4B14C5), Color(0xFFC7E2F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white),
                    ),
                  ),
                ),
                ...MockData.yourPlaylists.asMap().entries.map(
                  (entry) => AppMotionEntry(
                    delay: Duration(milliseconds: 40 * entry.key),
                    child: LibraryListItem(
                      title: entry.value.title,
                      subtitle: "Playlist • ${entry.value.creator}",
                      imageUrl: entry.value.coverUrl,
                    ),
                  ),
                ),
                ...MockData.trendingArtists.asMap().entries.map(
                  (entry) => AppMotionEntry(
                    delay: Duration(milliseconds: 40 * entry.key),
                    child: LibraryListItem(
                      title: entry.value.name,
                      subtitle: "Artist",
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
                      subtitle: "Album • ${entry.value.artist}",
                      imageUrl: entry.value.coverUrl,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
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
  double get minExtent => 110.0; // Increased to fix overflow

  @override
  double get maxExtent => 110.0; // Increased to fix overflow

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

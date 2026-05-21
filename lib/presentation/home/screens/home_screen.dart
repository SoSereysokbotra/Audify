import 'package:flutter/material.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/category_tabs.dart';
import '../widgets/recently_played_section.dart';
import '../widgets/popular_radio_section.dart';
import '../widgets/popular_albums_section.dart';
import '../widgets/user_greeting_section.dart';
import '../widgets/trending_artists_section.dart';
import '../widgets/new_releases_section.dart';
import '../widgets/your_playlists_section.dart';
import '../widgets/made_for_you_section.dart';
import '../../main_layout/widgets/profile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  List<Widget> _buildCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 1: // Music
        return [
          const NewReleasesSection(),
          const SizedBox(height: 32),
          const PopularAlbumsSection(),
          const SizedBox(height: 32),
          const RecentlyPlayedSection(),
          const SizedBox(height: 32),
          const MadeForYouSection(),
          const SizedBox(height: 100),
        ];
      case 2: // Podcasts
        return [
          const PopularRadioSection(),
          const SizedBox(height: 32),
          const MadeForYouSection(),
          const SizedBox(height: 100),
        ];
      case 3: // Artists
        return [const TrendingArtistsSection(), const SizedBox(height: 100)];
      case 4: // Playlists
        return [
          const YourPlaylistsSection(),
          const SizedBox(height: 32),
          const MadeForYouSection(),
          const SizedBox(height: 100),
        ];
      case 0: // All
      default:
        return [
          const RecentlyPlayedSection(),
          const SizedBox(height: 32),
          const TrendingArtistsSection(),
          const SizedBox(height: 32),
          const YourPlaylistsSection(),
          const SizedBox(height: 32),
          const PopularRadioSection(),
          const SizedBox(height: 32),
          const NewReleasesSection(),
          const SizedBox(height: 32),
          const PopularAlbumsSection(),
          const SizedBox(height: 32),
          const MadeForYouSection(),
          const SizedBox(height: 100),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          color: Colors.white,
          backgroundColor: AppColors.surface,
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: const AppMotionEntry(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [UserGreetingSection(), SizedBox(height: 16)],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyCategoryTabsDelegate(
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppMotionEntry(
                      delay: const Duration(milliseconds: 80),
                      child: CategoryTabsWidget(
                        selectedIndex: _selectedCategoryIndex,
                        onTabSelected: (index) {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedSwitcher(
                  duration: AppMotion.standard,
                  switchInCurve: AppMotion.entranceCurve,
                  switchOutCurve: AppMotion.exitCurve,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.03),
                      end: Offset.zero,
                    ).animate(animation);

                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(_selectedCategoryIndex),
                    child: Column(children: _buildCategoryContent()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StickyCategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyCategoryTabsDelegate({required this.child});

  @override
  double get minExtent => 56.0;

  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyCategoryTabsDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

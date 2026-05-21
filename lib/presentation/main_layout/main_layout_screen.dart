import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/screens/home_screen.dart';
import '../search/screens/search_screen.dart';
import '../library/screens/library_screen.dart';
import '../library/screens/create_playlist_screen.dart';
import '../premium/screens/premium_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  bool _isCreateMenuOpen = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const PremiumScreen(),
  ];

  Widget _buildFloatingCreateMenu() {
    return Material(
      color: Colors.transparent,
      child: AnimatedSlide(
        offset: _isCreateMenuOpen ? Offset.zero : const Offset(0, 0.08),
        duration: AppMotion.standard,
        curve: AppMotion.entranceCurve,
        child: AnimatedOpacity(
          opacity: _isCreateMenuOpen ? 1 : 0,
          duration: AppMotion.standard,
          curve: AppMotion.entranceCurve,
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: const Color(0xFF282828),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingOption(
                  icon: Icons.music_note,
                  title: "Playlist",
                  subtitle: "Create a playlist with songs or episodes",
                  onTap: () {
                    Navigator.push(
                      context,
                      AppMotion.route(const CreatePlaylistScreen()),
                    );
                  },
                ),
                _buildFloatingOption(
                  icon: Icons.people,
                  title: "Collaborative playlist",
                  subtitle: "Create a playlist together with friends",
                ),
                _buildFloatingOption(
                  icon: Icons.link,
                  title: "Blend",
                  subtitle: "Combine your friends' tastes into a playlist",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingOption({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _isCreateMenuOpen = false);
        if (onTap != null) onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF3E3E3E),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFFA7A7A7),
                      fontSize: 13,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          ...List.generate(_screens.length, (index) {
            final isActive = index == _currentIndex;
            return IgnorePointer(
              ignoring: !isActive,
              child: AnimatedOpacity(
                opacity: isActive ? 1 : 0,
                duration: AppMotion.standard,
                curve: AppMotion.entranceCurve,
                child: AnimatedSlide(
                  offset: isActive ? Offset.zero : const Offset(0, 0.02),
                  duration: AppMotion.standard,
                  curve: AppMotion.entranceCurve,
                  child: TickerMode(
                    enabled: isActive,
                    child: RepaintBoundary(child: _screens[index]),
                  ),
                ),
              ),
            );
          }),
          IgnorePointer(
            ignoring: !_isCreateMenuOpen,
            child: AnimatedOpacity(
              opacity: _isCreateMenuOpen ? 1 : 0,
              duration: AppMotion.standard,
              curve: AppMotion.entranceCurve,
              child: GestureDetector(
                onTap: () => setState(() => _isCreateMenuOpen = false),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
          ),
          Positioned(bottom: 90, right: 16, child: _buildFloatingCreateMenu()),
        ],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          color: Colors.transparent, // No solid color, pure blur
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 15.0,
                sigmaY: 15.0,
              ), // Increased blur
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: AppColors.secondaryText,
                selectedLabelStyle: AppTextStyles.helper.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTextStyles.helper.copyWith(
                  fontSize: 10,
                ),
                onTap: (index) {
                  if (index == 4) {
                    setState(() => _isCreateMenuOpen = !_isCreateMenuOpen);
                  } else {
                    setState(() {
                      _currentIndex = index;
                      _isCreateMenuOpen = false;
                    });
                  }
                },
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled),
                    label: "Home",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.search),
                    label: "Search",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.library_music),
                    label: "Your Library",
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.star),
                    label: "Premium",
                  ),
                  BottomNavigationBarItem(
                    icon: _isCreateMenuOpen
                        ? Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.black,
                              size: 20,
                            ),
                          )
                        : const Icon(Icons.add_box_outlined),
                    label: _isCreateMenuOpen ? "" : "Create",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

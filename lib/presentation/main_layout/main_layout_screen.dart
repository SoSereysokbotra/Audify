import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/motion/app_motion.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/create_options_sheet.dart';
import '../home/screens/home_screen.dart';
import '../search/screens/search_screen.dart';
import '../library/screens/library_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../player/widgets/mini_player.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(showBackButton: false),
  ];

  int get _selectedTabIndex =>
      _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;

  void _onTabSelected(int index) {
    if (index == 2) {
      CreateOptionsSheet.show(context);
      return;
    }

    setState(() {
      _currentIndex = index > 2 ? index - 1 : index;
    });
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
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Theme(
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
                    currentIndex: _selectedTabIndex,
                    selectedItemColor: Colors.white,
                    unselectedItemColor: AppColors.secondaryText,
                    selectedLabelStyle: AppTextStyles.helper.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: AppTextStyles.helper.copyWith(
                      fontSize: 10,
                    ),
                    onTap: _onTabSelected,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home_filled),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.search),
                        label: "Search",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.add_circle),
                        label: "Create",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.library_music),
                        label: "Your Library",
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person),
                        label: "Profile",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

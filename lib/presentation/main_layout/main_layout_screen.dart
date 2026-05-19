import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../home/screens/home_screen.dart';
import '../search/screens/search_screen.dart';
import '../library/screens/library_screen.dart';

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
    const Center(child: Text("Premium", style: AppTextStyles.h2)),
  ];

  void _onCreatePlaylist() {
    // Show modal to create playlist
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Create new playlist", style: AppTextStyles.h2.copyWith(color: AppColors.primaryText), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                decoration: InputDecoration(
                  hintText: "Playlist name",
                  hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.secondaryText),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
                style: AppTextStyles.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text("CREATE", style: AppTextStyles.button.copyWith(color: Colors.black)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
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
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0), // Increased blur
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: AppColors.secondaryText,
                selectedLabelStyle: AppTextStyles.helper.copyWith(fontSize: 10, fontWeight: FontWeight.w600),
                unselectedLabelStyle: AppTextStyles.helper.copyWith(fontSize: 10),
                onTap: (index) {
                  if (index == 4) {
                    _onCreatePlaylist();
                  } else {
                    setState(() => _currentIndex = index);
                  }
                },
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
                  BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
                  BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Your Library"),
                  BottomNavigationBarItem(icon: Icon(Icons.star), label: "Premium"),
                  BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: "Create"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("Share Profile", style: AppTextStyles.h2),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildShareIcon(Icons.copy, "Copy Link", Colors.blueGrey),
                    _buildShareIcon(Icons.message, "Messages", Colors.green),
                    _buildShareIcon(
                      Icons.camera_alt,
                      "Instagram",
                      Colors.pinkAccent,
                    ),
                    _buildShareIcon(
                      Icons.more_horiz,
                      "More",
                      AppColors.secondaryText,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy playlist data
    final List<Map<String, String>> playlists = [
      {
        "title": "Deep Focus",
        "subtitle": "Instrumental beats for designing.",
        "image":
            "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=200&q=80",
      },
      {
        "title": "Late Night Vibes",
        "subtitle": "Chill synthwave and lofi.",
        "image":
            "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=200&q=80",
      },
      {
        "title": "Morning Coffee",
        "subtitle": "Acoustic and indie hits.",
        "image":
            "https://images.unsplash.com/photo-1497935586351-b67a49e012bf?w=200&q=80",
      },
      {
        "title": "Workout Hype",
        "subtitle": "High energy EDM drops.",
        "image":
            "https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200&q=80",
      },
      {
        "title": "Roadtrip Classics",
        "subtitle": "Sing-along favorites.",
        "image":
            "https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=200&q=80",
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Full-screen fading image header
          SliverAppBar(
            expandedHeight: 450.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: AppColors.primaryText),
                onPressed: () => _showShareModal(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                  ),
                  // Gradient to fade the image seamlessly into the black background
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 0.8, 1.0],
                        colors: [
                          Colors.transparent,
                          AppColors.background.withOpacity(0.6),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Profile Information Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & Verified Badge
                  Row(
                    children: [
                      const Text("Sophie Bennett", style: AppTextStyles.h1),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  const Text(
                    "Product Designer who focuses\non simplicity & usability.",
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // Stats & Follow Button
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "312",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),

                      const Icon(
                        Icons.my_library_books_outlined,
                        size: 20,
                        color: AppColors.secondaryText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "48",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      // Follow Button using AppTextStyles.button and AppColors.accent
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          "Follow +",
                          style: AppTextStyles.button,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 32),

                  // Section Title
                  const Text("Playlists", style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Playlists List
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 40.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final playlist = playlists[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      playlist["image"]!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    playlist["title"]!,
                    style: AppTextStyles.bodyLarge,
                  ),
                  subtitle: Text(
                    playlist["subtitle"]!,
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: const Icon(
                    Icons.more_vert,
                    color: AppColors.secondaryText,
                  ),
                  onTap: () {
                    // Handle playlist tap
                  },
                );
              }, childCount: playlists.length),
            ),
          ),
        ],
      ),
    );
  }
}

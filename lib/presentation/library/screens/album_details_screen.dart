import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String imageUrl;

  const AlbumDetailsScreen({
    Key? key,
    this.title = "Fragments",
    this.artist = "Mr. Kitty",
    this.imageUrl = "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80",
  }) : super(key: key);

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  final int _playingIndex = 2; // "Unstable" is index 2

  final List<Map<String, String>> _tracks = [
    {"title": "Insects", "time": "3:56"},
    {"title": "Heaven", "time": "4:43"},
    {"title": "Unstable", "time": "2:52"},
    {"title": "Sacrifice", "time": "6:54"},
    {"title": "Holy Death", "time": "2:58"},
    {"title": "Entwine", "time": "4:12"},
    {"title": "Lamentation", "time": "3:45"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Matches other screens
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),
              SliverToBoxAdapter(
                child: _buildActionButtons(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _tracks.length) {
                      return const SizedBox(height: 120); // space for mini player
                    }
                    return _buildTrackItem(index);
                  },
                  childCount: _tracks.length + 1,
                ),
              ),
            ],
          ),
          
          // Mini Player placed at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildMiniPlayer(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glowing Album Art
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Album Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  "Album • 17 songs • 2013",
                  style: AppTextStyles.helper.copyWith(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.artist,
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white54),
                ),
                const SizedBox(height: 16),
                // Icons Row
                Row(
                  children: [
                    _buildOutlinedIcon(Icons.library_add_outlined),
                    const SizedBox(width: 16),
                    _buildOutlinedIcon(Icons.arrow_downward),
                    const SizedBox(width: 16),
                    _buildOutlinedIcon(Icons.more_horiz),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white54, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white54, size: 18),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_circle_outline, color: Colors.black),
              label: Text("Play", style: AppTextStyles.button.copyWith(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.shuffle, color: Colors.white),
              label: Text("Shuffle", style: AppTextStyles.button.copyWith(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF232532), // Dark grey-blue
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackItem(int index) {
    final track = _tracks[index];
    final isPlaying = index == _playingIndex;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFF232532) : Colors.transparent, // Highlight background
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: isPlaying
            ? const Icon(Icons.bar_chart, color: Colors.white)
            : Text(
                (index + 1).toString().padLeft(2, '0'),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
              ),
        title: Text(
          track["title"]!,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          "${widget.artist} • ${track["time"]}",
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
        ),
        trailing: const Icon(Icons.more_horiz, color: Colors.white54),
        onTap: () {
          // Play track
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Mini Art
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                widget.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Mini Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Unstable",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            // Like
            IconButton(
              icon: const Icon(Icons.favorite_border, color: Colors.black54),
              onPressed: () {},
            ),
            // Pause
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pause, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

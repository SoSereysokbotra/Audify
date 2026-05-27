import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/blend_model.dart';
import '../../../data/audify_store.dart';

class BlendPlaylistScreen extends StatelessWidget {
  final BlendModel blend;

  const BlendPlaylistScreen({super.key, required this.blend});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Compatibility Score Circle
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                          border: Border.all(color: AppColors.accent, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '${(blend.compatibilityScore * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      const SizedBox(height: 16),
                      const Text(
                        'Taste Match',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fade(delay: 300.ms),
                    ],
                  ),
                ],
              ),
            ),
            title: const Text('Your Blend'),
          ),
          
          // Floating Gradient Cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Why you matched',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildGradientCard(
                          'Shared Artists',
                          blend.sharedArtists.take(2).join(', '),
                          [const Color(0xFFff6a00), const Color(0xFFee0979)],
                        ),
                        _buildGradientCard(
                          'Shared Genres',
                          blend.sharedGenres.join(', '),
                          [const Color(0xFF11998e), const Color(0xFF38ef7d)],
                        ),
                        _buildGradientCard(
                          'Mood Match',
                          blend.moodMatch,
                          [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)],
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 500.ms).slideX(),
                  const SizedBox(height: 32),
                  const Text(
                    'Blended Playlist',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          
          // Song List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final collabSong = blend.blendedSongs[index];
                final song = AudifyStore.instance.songById(collabSong.songId);
                if (song == null) return const SizedBox.shrink();

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.coverUrl, width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  title: Text(song.title, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(song.artist, style: const TextStyle(color: Colors.white54)),
                  trailing: CircleAvatar(
                    radius: 12,
                    backgroundImage: NetworkImage('https://picsum.photos/seed/${collabSong.addedBy}/50/50'),
                  ),
                ).animate().fade(delay: (600 + index * 50).ms).slideY(begin: 0.2);
              },
              childCount: blend.blendedSongs.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildGradientCard(String title, String subtitle, List<Color> colors) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/song_model.dart';

class AlbumDetailsScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String imageUrl;

  const AlbumDetailsScreen({
    super.key,
    this.title = "Artist",
    this.artist = "Artist",
    this.imageUrl =
        "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80",
  });

  @override
  State<AlbumDetailsScreen> createState() => _AlbumDetailsScreenState();
}

class _AlbumDetailsScreenState extends State<AlbumDetailsScreen> {
  List<SongModel> _artistSongs(AudifyStore store) {
    final artistName = widget.artist.trim().toLowerCase();
    return store.songs
        .where((song) => song.artist.trim().toLowerCase() == artistName)
        .toList(growable: false);
  }

  String _songCountText(int count) => count == 1 ? '1 song' : '$count songs';

  Future<void> _playSongs(List<SongModel> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    try {
      await LocalAudioPlayer.instance.playQueue(songs, startIndex: startIndex);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This song cannot be played right now.')),
      );
    }
  }

  Future<void> _shuffleSongs(List<SongModel> songs) async {
    if (songs.isEmpty) return;
    if (!LocalAudioPlayer.instance.shuffleEnabled) {
      LocalAudioPlayer.instance.toggleShuffle();
    }

    if (songs.length == 1 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only one song is available for this artist.'),
        ),
      );
    }

    final shuffled = List<SongModel>.from(songs)..shuffle(Random());
    final startIndex = shuffled.length > 1
        ? Random().nextInt(shuffled.length)
        : 0;
    await _playSongs(shuffled, startIndex: startIndex);
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListTile(
            leading: const Icon(Icons.person_outline, color: Colors.white),
            title: Text(widget.artist, style: AppTextStyles.bodyLarge),
            subtitle: const Text('Artist options', style: AppTextStyles.helper),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        AudifyStore.instance,
        LocalAudioPlayer.instance,
      ]),
      builder: (context, _) {
        final store = AudifyStore.instance;
        final songs = _artistSongs(store);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(songs.length)),
                  SliverToBoxAdapter(child: _buildActionButtons(songs)),
                  if (songs.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == songs.length) {
                          return const SizedBox(height: 120);
                        }
                        return _buildTrackItem(songs, index);
                      }, childCount: songs.length + 1),
                    ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildMiniPlayer(store),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(int songCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surface,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    color: AppColors.secondaryText,
                    size: 56,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Artist • ${_songCountText(songCount)}',
                  style: AppTextStyles.helper.copyWith(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.artist,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.title == widget.artist ? 'Saved artist' : widget.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [_buildOutlinedIcon(Icons.more_horiz)]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedIcon(IconData icon) {
    return InkWell(
      onTap: _showMoreOptions,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white54, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white54, size: 18),
      ),
    );
  }

  Widget _buildActionButtons(List<SongModel> songs) {
    final canPlay = songs.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: canPlay ? () => _playSongs(songs) : null,
              icon: const Icon(Icons.play_circle_outline, color: Colors.black),
              label: Text(
                'Play',
                style: AppTextStyles.button.copyWith(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white24,
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
              onPressed: canPlay ? () => _shuffleSongs(songs) : null,
              icon: const Icon(Icons.shuffle, color: Colors.white),
              label: Text(
                'Shuffle',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF232532),
                disabledBackgroundColor: const Color(
                  0xFF232532,
                ).withValues(alpha: 0.42),
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

  Widget _buildTrackItem(List<SongModel> songs, int index) {
    final song = songs[index];
    final currentSong = LocalAudioPlayer.instance.currentSong;
    final isPlaying = currentSong?.id == song.id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isPlaying ? const Color(0xFF232532) : Colors.transparent,
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
          song.title,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(
          song.artist,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white54),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz, color: Colors.white54),
          onPressed: _showMoreOptions,
        ),
        onTap: () => _playSongs(songs, startIndex: index),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 140),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.music_off_outlined,
            color: AppColors.secondaryText,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'No songs from ${widget.artist} yet.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Songs you add for this artist will appear here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer(AudifyStore store) {
    final song = LocalAudioPlayer.instance.currentSong;
    if (song == null) return const SizedBox.shrink();

    final isFavorite = store.isFavorite(song.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                song.coverUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 48,
                    height: 48,
                    color: AppColors.surface,
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.black54,
              ),
              onPressed: () => store.toggleFavorite(song.id),
            ),
            IconButton(
              onPressed: LocalAudioPlayer.instance.togglePlayPause,
              icon: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LocalAudioPlayer.instance.player.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

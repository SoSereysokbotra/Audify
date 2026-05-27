import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/models/song_model.dart';

class PlaylistCoverArt extends StatelessWidget {
  final String coverUrl;
  final List<SongModel> songs;
  final double size;
  final double borderRadius;

  const PlaylistCoverArt({
    super.key,
    required this.coverUrl,
    required this.songs,
    this.size = 64,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedCover = coverUrl.trim();
    final hasCustomCover = trimmedCover.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: hasCustomCover
            ? _CoverImage(source: trimmedCover)
            : _SongGrid(songs: songs),
      ),
    );
  }
}

class _SongGrid extends StatelessWidget {
  final List<SongModel> songs;

  const _SongGrid({required this.songs});

  @override
  Widget build(BuildContext context) {
    final visibleSongs = songs.take(4).toList(growable: false);
    if (visibleSongs.isEmpty) {
      return Container(
        color: AppColors.surface,
        alignment: Alignment.center,
        child: const Icon(Icons.music_note, color: AppColors.secondaryText),
      );
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final song = visibleSongs[index % visibleSongs.length];
        return _CoverImage(source: song.coverUrl);
      },
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String source;

  const _CoverImage({required this.source});

  @override
  Widget build(BuildContext context) {
    final trimmed = source.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    if (trimmed.isNotEmpty) {
      final file = File(trimmed);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(Icons.music_note, color: AppColors.secondaryText),
    );
  }
}

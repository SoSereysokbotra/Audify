import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/models/song_model.dart';
import '../widgets/song_card.dart';

class SongCollectionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String coverUrl;
  final List<SongModel> songs;

  const SongCollectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title, style: AppTextStyles.h2)),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coverUrl,
                  width: 116,
                  height: 116,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h1),
                    const SizedBox(height: 8),
                    Text(subtitle, style: AppTextStyles.bodySmall),
                    const SizedBox(height: 12),
                    Text('${songs.length} songs', style: AppTextStyles.helper),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          if (songs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  'No songs available here yet.',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...songs.map(
              (song) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SongCard(song: song),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';
import 'song_card.dart';

class RecentlyPlayedSection extends StatelessWidget {
  const RecentlyPlayedSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Jump into a session based on your tastes",
            style: AppTextStyles.helper,
          ),
        ),
        const SizedBox(height: 4),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Start listening",
            style: AppTextStyles.h1,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: MockData.recentlyPlayed.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final song = MockData.recentlyPlayed[index];
            return SongCard(song: song);
          },
        ),
      ],
    );
  }
}

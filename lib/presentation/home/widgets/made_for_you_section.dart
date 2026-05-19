import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';
import 'dart:ui';

class MadeForYouSection extends StatelessWidget {
  const MadeForYouSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text("Made for you", style: AppTextStyles.h1),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: MockData.madeForYou.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final mix = MockData.madeForYou[index];
              final colorStart = Color(int.parse(mix.gradientStartHex));
              final colorEnd = Color(int.parse(mix.gradientEndHex));

              return Container(
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(mix.coverUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  children: [
                    // Glassmorphism effect overlay
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorStart.withOpacity(0.6),
                                colorEnd.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text("MIX", style: AppTextStyles.helper.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            mix.title,
                            style: AppTextStyles.h1.copyWith(fontSize: 24),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mix.subtitle,
                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

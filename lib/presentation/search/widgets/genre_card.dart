import 'package:flutter/material.dart';
import '../../../domain/models/genre_model.dart';
import '../../../core/theme/app_text_styles.dart';

class GenreCard extends StatelessWidget {
  final GenreModel genre;

  const GenreCard({Key? key, required this.genre}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fallback color in case the image fails to load
    final Color fallbackColor = Color(
      int.tryParse(genre.colorHex) ?? 0xFF424242,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // More rounded, modern look
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to Genre details
          },
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand, // Forces the stack to fill the whole card
              children: [
                // 1. Full-cover Background Image
                Image.network(
                  genre.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Uses your hex color if the image link is broken
                    return Container(color: fallbackColor);
                  },
                ),

                // 2. Smooth Gradient Overlay (makes text readable)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8), // Darkens at the bottom
                      ],
                      stops: const [0.4, 1.0], // Starts fading halfway down
                    ),
                  ),
                ),

                // 3. Genre Title positioned at the bottom left
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Text(
                    genre.title,
                    style: AppTextStyles.h2.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

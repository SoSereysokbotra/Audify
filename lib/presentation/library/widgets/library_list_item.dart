import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../screens/album_details_screen.dart';

class LibraryListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final bool isArtist;
  final bool isPinned;
  final Widget? customLeading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const LibraryListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.isArtist = false,
    this.isPinned = false,
    this.customLeading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget leading =
        customLeading ??
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: isArtist ? BoxShape.circle : BoxShape.rectangle,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        );

    return AppPressScale(
      onTap:
          onTap ??
          () {
            Navigator.push(
              context,
              AppMotion.route(
                AlbumDetailsScreen(
                  title: title,
                  imageUrl: imageUrl.isEmpty
                      ? 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80'
                      : imageUrl,
                ),
              ),
            );
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isPinned) ...[
                        const Icon(
                          Icons.push_pin,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

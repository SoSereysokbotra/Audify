import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class LibraryFilterPills extends StatefulWidget {
  const LibraryFilterPills({Key? key}) : super(key: key);

  @override
  State<LibraryFilterPills> createState() => _LibraryFilterPillsState();
}

class _LibraryFilterPillsState extends State<LibraryFilterPills> {
  int _selectedIndex = -1; // -1 means none selected
  final List<String> _filters = ["Playlists", "Podcasts", "Albums", "Artists", "Downloaded"];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = isSelected ? -1 : index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.white : AppColors.secondaryText.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _filters[index],
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

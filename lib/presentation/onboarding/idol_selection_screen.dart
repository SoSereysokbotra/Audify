import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock_data.dart';
import '../../domain/models/artist_model.dart';

class IdolSelectionScreen extends StatefulWidget {
  final Function(List<String>) onComplete;
  final VoidCallback onBack;

  const IdolSelectionScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<IdolSelectionScreen> createState() => _IdolSelectionScreenState();
}

class _IdolSelectionScreenState extends State<IdolSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedIdolIds = [];
  List<ArtistModel> _filteredIdols = [];
  bool _isLoading = false;

  final int _minSelection = 3;

  @override
  void initState() {
    super.initState();
    _filteredIdols = MockData.mockIdols;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isLoading = true;
    });

    // Simulate slight network delay for realism
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _filteredIdols = MockData.mockIdols
            .where((idol) => idol.name.toLowerCase().contains(query))
            .toList();
        _isLoading = false;
      });
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIdolIds.contains(id)) {
        _selectedIdolIds.remove(id);
      } else {
        _selectedIdolIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(CupertinoIcons.back, color: Colors.white),
                  onPressed: widget.onBack,
                ),
                const Expanded(
                  child: Text(
                    'Choose your favorites',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // balance the back button
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: CupertinoSearchTextField(
              controller: _searchController,
              backgroundColor: AppColors.surface,
              itemColor: Colors.white54,
              style: const TextStyle(color: Colors.white),
              placeholder: 'Search artists...',
              placeholderStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white54),
              suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.white54),
            ),
          ),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select at least $_minSelection artists',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  '${_selectedIdolIds.length} Selected',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _selectedIdolIds.length >= _minSelection
                        ? AppColors.accent
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.accent),
                  )
                : _filteredIdols.isEmpty
                    ? Center(
                        child: Text(
                          'No artists found.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16,
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: _filteredIdols.length,
                        itemBuilder: (context, index) {
                          final idol = _filteredIdols[index];
                          final isSelected = _selectedIdolIds.contains(idol.id);

                          return GestureDetector(
                            onTap: () => _toggleSelection(idol.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.accent
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.accent.withOpacity(0.4),
                                                      blurRadius: 12,
                                                      spreadRadius: 2,
                                                    )
                                                  ]
                                                : [],
                                          ),
                                          child: CircleAvatar(
                                            radius: 50,
                                            backgroundColor: AppColors.surface,
                                            backgroundImage: NetworkImage(idol.imageUrl),
                                          ),
                                        ),
                                        if (isSelected)
                                          Positioned(
                                            top: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: AppColors.background,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.checkmark_alt_circle_fill,
                                                color: AppColors.accent,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    idol.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          
          // Bottom action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.0),
                  AppColors.background,
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedIdolIds.length >= _minSelection
                    ? () => widget.onComplete(_selectedIdolIds)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Finish setup',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

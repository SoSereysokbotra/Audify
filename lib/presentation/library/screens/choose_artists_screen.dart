import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/artist_model.dart';

class ChooseArtistsScreen extends StatefulWidget {
  const ChooseArtistsScreen({super.key});

  @override
  State<ChooseArtistsScreen> createState() => _ChooseArtistsScreenState();
}

class _ChooseArtistsScreenState extends State<ChooseArtistsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = AudifyStore.instance.profile.favoriteIdols.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ArtistModel> get _filteredArtists {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return MockData.mockIdols;
    return MockData.mockIdols
        .where((artist) => artist.name.toLowerCase().contains(query))
        .toList(growable: false);
  }

  Future<void> _finish() async {
    if (_selectedIds.isEmpty) return;
    await AudifyStore.instance.setFavoriteIdolIds(_selectedIds.toList());
    if (!mounted) return;

    final selectedArtists = MockData.mockIdols
        .where((artist) => _selectedIds.contains(artist.id))
        .toList(growable: false);

    Navigator.pushReplacement(
      context,
      AppMotion.route(
        ArtistPicksSuccessScreen(artists: selectedArtists),
        duration: AppMotion.relaxed,
      ),
    );
  }

  void _toggle(ArtistModel artist) {
    setState(() {
      if (_selectedIds.contains(artist.id)) {
        _selectedIds.remove(artist.id);
      } else {
        _selectedIds.add(artist.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final artists = _filteredArtists;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 72, 32, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'Choose artists',
                      style: AppTextStyles.h1.copyWith(fontSize: 34),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 96, 32, 28),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 30,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 140),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 22,
                          mainAxisSpacing: 28,
                          childAspectRatio: 0.68,
                        ),
                    itemCount: artists.length,
                    itemBuilder: (context, index) {
                      final artist = artists[index];
                      final isSelected = _selectedIds.contains(artist.id);
                      return AppMotionEntry(
                        delay: Duration(milliseconds: 24 * index),
                        child: _ArtistTile(
                          artist: artist,
                          isSelected: isSelected,
                          onTap: () => _toggle(artist),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                ignoring: true,
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.background],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Center(
                child: SizedBox(
                  width: 178,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _selectedIds.isEmpty ? null : _finish,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor: Colors.white.withValues(
                        alpha: 0.5,
                      ),
                      disabledForegroundColor: Colors.black54,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistTile extends StatelessWidget {
  final ArtistModel artist;
  final bool isSelected;
  final VoidCallback onTap;

  const _ArtistTile({
    required this.artist,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressScale(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.quick,
              curve: AppMotion.entranceCurve,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.18),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipOval(
                    child: Image.network(
                      artist.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surface,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person,
                          color: AppColors.secondaryText,
                          size: 38,
                        ),
                      ),
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ArtistPicksSuccessScreen extends StatefulWidget {
  final List<ArtistModel> artists;

  const ArtistPicksSuccessScreen({super.key, required this.artists});

  @override
  State<ArtistPicksSuccessScreen> createState() =>
      _ArtistPicksSuccessScreenState();
}

class _ArtistPicksSuccessScreenState extends State<ArtistPicksSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.relaxed)
      ..forward();
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _scale = Tween<double>(begin: 0.75, end: 1).animate(curved);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleArtists = widget.artists.take(3).toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 220,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: List.generate(visibleArtists.length, (index) {
                      final artist = visibleArtists[index];
                      final offsets = [
                        const Offset(-56, 0),
                        Offset.zero,
                        const Offset(56, 0),
                      ];
                      final rotations = [-0.18, 0.04, 0.12];
                      return Transform.translate(
                        offset: offsets[index],
                        child: Transform.rotate(
                          angle: rotations[index],
                          child: _SuccessArtistCover(artist: artist),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 54),
                Text(
                  'Great picks!',
                  style: AppTextStyles.h1.copyWith(fontSize: 30),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SuccessArtistCover extends StatelessWidget {
  final ArtistModel artist;

  const _SuccessArtistCover({required this.artist});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        artist.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, color: Colors.white, size: 34),
      ),
    );
  }
}

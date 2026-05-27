import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/podcast_model.dart';

class ChoosePodcastsScreen extends StatefulWidget {
  const ChoosePodcastsScreen({super.key});

  @override
  State<ChoosePodcastsScreen> createState() => _ChoosePodcastsScreenState();
}

class _ChoosePodcastsScreenState extends State<ChoosePodcastsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PodcastModel> get _filteredPodcasts {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return MockData.podcasts;

    return MockData.podcasts
        .where((podcast) {
          return podcast.title.toLowerCase().contains(query) ||
              podcast.category.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  Future<void> _finish() async {
    final selected = MockData.podcasts
        .where((podcast) => _selectedIds.contains(podcast.id))
        .toList(growable: false);
    if (selected.isEmpty) return;

    await AudifyStore.instance.addPodcastSelections(selected);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      AppMotion.route(
        PodcastPicksSuccessScreen(podcasts: selected),
        duration: AppMotion.relaxed,
      ),
    );
  }

  void _toggle(PodcastModel podcast) {
    if (podcast.isCategoryTile) return;

    setState(() {
      if (_selectedIds.contains(podcast.id)) {
        _selectedIds.remove(podcast.id);
      } else {
        _selectedIds.add(podcast.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final podcasts = _filteredPodcasts;

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
                      'Choose podcasts',
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
                          childAspectRatio: 0.63,
                        ),
                    itemCount: podcasts.length,
                    itemBuilder: (context, index) {
                      final podcast = podcasts[index];
                      final isSelected = _selectedIds.contains(podcast.id);
                      return AppMotionEntry(
                        delay: Duration(milliseconds: 24 * index),
                        child: _PodcastTile(
                          podcast: podcast,
                          isSelected: isSelected,
                          onTap: () => _toggle(podcast),
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

class _PodcastTile extends StatelessWidget {
  final PodcastModel podcast;
  final bool isSelected;
  final VoidCallback onTap;

  const _PodcastTile({
    required this.podcast,
    required this.isSelected,
    required this.onTap,
  });

  Color get _categoryColor {
    switch (podcast.category) {
      case 'Comedy':
        return const Color(0xFF46505A);
      case 'Books':
        return const Color(0xFF9D123A);
      case 'Business':
        return const Color(0xFF8F0000);
      default:
        return const Color(0xFF005C2A);
    }
  }

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
                color: podcast.isCategoryTile
                    ? _categoryColor
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
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
                  if (podcast.isCategoryTile)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          podcast.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.h2.copyWith(fontSize: 18),
                        ),
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        podcast.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surface,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.podcasts,
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
            podcast.title,
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

class PodcastPicksSuccessScreen extends StatefulWidget {
  final List<PodcastModel> podcasts;

  const PodcastPicksSuccessScreen({super.key, required this.podcasts});

  @override
  State<PodcastPicksSuccessScreen> createState() =>
      _PodcastPicksSuccessScreenState();
}

class _PodcastPicksSuccessScreenState extends State<PodcastPicksSuccessScreen>
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
    final visiblePodcasts = widget.podcasts.take(3).toList(growable: false);

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
                    children: List.generate(visiblePodcasts.length, (index) {
                      final podcast = visiblePodcasts[index];
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
                          child: _SuccessCover(podcast: podcast),
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

class _SuccessCover extends StatelessWidget {
  final PodcastModel podcast;

  const _SuccessCover({required this.podcast});

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
      child: podcast.isCategoryTile || podcast.coverUrl.isEmpty
          ? const Icon(Icons.podcasts, color: Colors.white, size: 34)
          : Image.network(
              podcast.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.podcasts, color: Colors.white, size: 34),
            ),
    );
  }
}

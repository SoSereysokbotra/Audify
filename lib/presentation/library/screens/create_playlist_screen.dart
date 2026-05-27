import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../domain/models/song_model.dart';
import 'immersive_playlist_screen.dart';

class CreatePlaylistScreen extends StatefulWidget {
  const CreatePlaylistScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  bool _isPrivate = false;
  String _searchQuery = '';
  final List<int> _selectedTrackIndices = [];

  late AnimationController _coverPulseController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  List<SongModel> get _allTracks => AudifyStore.instance.songs;

  List<SongModel> get _filteredTracks {
    if (_searchQuery.isEmpty) return _allTracks;
    return _allTracks.where((t) {
      final q = _searchQuery.toLowerCase();
      return t.title.toLowerCase().contains(q) ||
          t.artist.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _coverPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    _coverPulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onCreatePressed() {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please give your playlist a name to continue');
      _nameFocus.requestFocus();
      return;
    }
    final selectedSongIds = _selectedTrackIndices
        .map((index) => _allTracks[index].id)
        .toList();

    AudifyStore.instance.createPlaylist(
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      songIds: selectedSongIds,
      isPrivate: _isPrivate,
      coverUrl:
          'https://picsum.photos/id/${111 + AudifyStore.instance.playlists.length}/200/200',
    );

    _showSnackBar('Playlist "${_nameController.text.trim()}" created');
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF1E1E2C).withValues(alpha: 0.95),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBodyBehindAppBar: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Subtle ambient background glow (black and white theme)
              Positioned(
                top: -150,
                left: -100,
                right: -100,
                child: AnimatedBuilder(
                  animation: _coverPulseController,
                  builder: (context, _) {
                    return Container(
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(
                              alpha:
                                  0.05 + (0.02 * _coverPulseController.value),
                            ),
                            AppColors.background.withValues(alpha: 0),
                          ],
                          radius: 0.7,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildGlassAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: _buildCoverArtSection(),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildFormSection()),
                  SliverToBoxAdapter(child: _buildPrivacyToggle()),
                  SliverToBoxAdapter(child: _buildDivider('Add Songs')),
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  _buildTrackList(),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),

              // Floating Bottom Create Button
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildFloatingBottomButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildGlassAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.background.withValues(alpha: 0.6),
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      expandedHeight: kToolbarHeight,
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(color: Colors.transparent),
        ),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'New Playlist',
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              letterSpacing: -0.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.slideshow, color: Colors.white),
          tooltip: 'Preview Immersive',
          onPressed: () {
            Navigator.push(
              context,
              AppMotion.route(const ImmersivePlaylistScreen()),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildCoverArtSection() {
    return Center(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _pickImage();
        },
        child: AnimatedBuilder(
          animation: _coverPulseController,
          builder: (context, child) {
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Colors.white.withValues(alpha: 0.05),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    blurRadius: 30 + (10 * _coverPulseController.value),
                    offset: const Offset(0, 15),
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  if (_coverImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: Image.file(_coverImage!, fit: BoxFit.cover),
                    ),
                  // Inner shadow/border for a glass feel
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Abstract decorative pattern if no image
                  if (_coverImage == null)
                    Opacity(
                      opacity: 0.1,
                      child: CustomPaint(
                        size: const Size(220, 220),
                        painter: _NotePatternPainter(),
                      ),
                    ),
                  // Modern Camera Overlay
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputLabel('PLAYLIST NAME'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _nameController,
            focusNode: _nameFocus,
            hint: 'Name your masterpiece...',
            maxLength: 50,
          ),
          const SizedBox(height: 28),
          _buildInputLabel('DESCRIPTION (OPTIONAL)'),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _descriptionController,
            focusNode: _descFocus,
            hint: 'What\'s the vibe?',
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.inputLabel.copyWith(
        color: Colors.white54,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
    int? maxLength,
  }) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, child) {
        final isFocused = focusNode.hasFocus;
        const primaryColor = Colors.white;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isFocused
                  ? primaryColor.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.08),
              width: isFocused ? 1.5 : 1,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            maxLength: maxLength,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: primaryColor,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white24,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(20),
              counterStyle: AppTextStyles.helper.copyWith(
                color: Colors.white38,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _isPrivate = !_isPrivate);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPrivate
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isPrivate
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isPrivate ? Icons.lock_rounded : Icons.public_rounded,
                  color: _isPrivate ? Colors.white54 : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isPrivate ? 'Private Playlist' : 'Public Playlist',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isPrivate
                          ? 'Only you can view and edit'
                          : 'Visible to everyone on your profile',
                      style: AppTextStyles.helper.copyWith(
                        fontSize: 13,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom minimal switch
              Container(
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _isPrivate
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white,
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: _isPrivate
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _isPrivate ? Colors.white : Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 20),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.h2.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: TextField(
          controller: _searchController,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          onChanged: (val) => setState(() => _searchQuery = val),
          decoration: InputDecoration(
            hintText: 'Search songs, artists...',
            hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white38),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white54,
              size: 22,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                      size: 18,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  SliverList _buildTrackList() {
    final tracks = _filteredTracks;
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final track = tracks[index];
        final isSelected = _selectedTrackIndices.contains(
          _allTracks.indexOf(track),
        );
        final trackIndex = _allTracks.indexOf(track);

        return _TrackListItem(
          track: track,
          isSelected: isSelected,
          accentColor: Colors.white,
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              if (isSelected) {
                _selectedTrackIndices.remove(trackIndex);
              } else {
                _selectedTrackIndices.add(trackIndex);
              }
            });
          },
        );
      }, childCount: tracks.length),
    );
  }

  Widget _buildFloatingBottomButton() {
    final count = _selectedTrackIndices.length;
    const primaryColor = Colors.white;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.1),
                AppColors.background.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: GestureDetector(
            onTap: _onCreatePressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    count > 0 ? 'Create Playlist • $count' : 'Create Playlist',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Track List Item
// ─────────────────────────────────────────────────────────────────────────────

class _TrackListItem extends StatelessWidget {
  final SongModel track;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _TrackListItem({
    required this.track,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Abstract Album Art placeholder
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.05),
              ),
              child: Icon(
                isSelected
                    ? Icons.music_note_rounded
                    : Icons.audiotrack_rounded,
                color: isSelected ? Colors.black : Colors.white38,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: isSelected ? Colors.white70 : Colors.white54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Minimal Selector
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? accentColor
                    : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isSelected
                      ? accentColor
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                color: isSelected ? Colors.white : Colors.transparent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Abstract Background Pattern
// ─────────────────────────────────────────────────────────────────────────────

class _NotePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final radius = 20.0 + random.nextDouble() * 40;
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

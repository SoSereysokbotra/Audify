import 'dart:io';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/collaborative_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/collaborative_playlist_model.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

enum _SharePlatform {
  facebook('facebook', 'Facebook'),
  instagram('instagram', 'Instagram'),
  tiktok('tiktok', 'TikTok'),
  telegram('telegram', 'Telegram'),
  x('x', 'X');

  final String key;
  final String label;

  const _SharePlatform(this.key, this.label);
}

enum _ShareLayout {
  playlist('playlist', 'Playlist'),
  artwork('artwork', 'Playlist artwork');

  final String key;
  final String label;

  const _ShareLayout(this.key, this.label);
}

const _sharePlatformImages = {
  _SharePlatform.facebook:
      'https://res.cloudinary.com/dg5grwcd5/image/upload/v1779925884/5bb0f73a7b3e0f976acad614a42e5040_szbs1y.jpg',
  _SharePlatform.instagram:
      'https://res.cloudinary.com/dg5grwcd5/image/upload/v1779926159/5685d988cc0e1406f84d61936f96a71a_gtepwb.jpg',
  _SharePlatform.tiktok:
      'https://res.cloudinary.com/dg5grwcd5/image/upload/v1779925888/0bdbbef30f3d9833eb35f3befadd4b27_cnlgwk.jpg',
  _SharePlatform.telegram:
      'https://res.cloudinary.com/dg5grwcd5/image/upload/v1779925898/91aaf51ae3b6b52f73b2407383620bff_ghyvr2.jpg',
  _SharePlatform.x:
      'https://res.cloudinary.com/dg5grwcd5/image/upload/v1779925907/8e72f7331b652b842b0c271ab144d332_kjibba.jpg',
};

const _sharePosterColors = [
  Color(0xFF721300),
  Color(0xFF3B0B04),
  Color(0xFF050505),
];

class CollaborativePlaylistScreen extends StatefulWidget {
  final String playlistId;
  final bool autoShare;

  const CollaborativePlaylistScreen({
    super.key,
    required this.playlistId,
    this.autoShare = false,
  });

  @override
  State<CollaborativePlaylistScreen> createState() =>
      _CollaborativePlaylistScreenState();
}

class _CollaborativePlaylistScreenState
    extends State<CollaborativePlaylistScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  static const MethodChannel _storyShareChannel = MethodChannel(
    'audify/share_story',
  );

  @override
  void initState() {
    super.initState();
    if (widget.autoShare) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showShareModal(context);
      });
    }
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildShareSheet(),
    );
  }

  String _inviteLink({bool inviteAsCollaborator = false}) {
    final uri = Uri(
      scheme: 'https',
      host: 'audify-f9365.web.app',
      pathSegments: ['collab', widget.playlistId],
      queryParameters: inviteAsCollaborator
          ? const {'invite': 'collaborator'}
          : null,
    );
    return uri.toString();
  }

  Future<void> _copyInviteLink({bool inviteAsCollaborator = false}) async {
    await Clipboard.setData(
      ClipboardData(
        text: _inviteLink(inviteAsCollaborator: inviteAsCollaborator),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied')));
  }

  Future<void> _shareInviteLink({
    String? target,
    bool inviteAsCollaborator = false,
  }) async {
    final targetText = target == null ? '' : ' on $target';
    final actionText = inviteAsCollaborator
        ? 'Join my collaborative playlist'
        : 'Listen to my collaborative playlist';
    await SharePlus.instance.share(
      ShareParams(
        text:
            '$actionText$targetText: ${_inviteLink(inviteAsCollaborator: inviteAsCollaborator)}',
      ),
    );
  }

  Future<void> _shareInviteToPlatform(
    _SharePlatform platform, {
    _ShareLayout layout = _ShareLayout.playlist,
    bool inviteAsCollaborator = false,
    Uint8List? storyImageBytes,
  }) async {
    final link = _inviteLink(inviteAsCollaborator: inviteAsCollaborator);
    final message = inviteAsCollaborator
        ? 'Join my collaborative playlist as a collaborator on Audify: $link'
        : 'Listen to my collaborative playlist on Audify: $link';
    final openedStoryComposer = await _shareStoryWithNativeComposer(
      platform,
      message,
      link,
      layout,
      inviteAsCollaborator,
      storyImageBytes,
    );
    if (openedStoryComposer) {
      return;
    }

    final launchTargets = _platformLaunchTargets(platform, message, link);
    for (final target in launchTargets) {
      try {
        final opened = await launchUrl(
          target,
          mode: LaunchMode.externalApplication,
        );
        if (opened) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Opening ${platform.label}. Use the share composer to post it.',
              ),
            ),
          );
          return;
        }
      } catch (_) {
        // Try the next app/web route, then fall back to SharePlus.
      }
    }

    await _shareInviteLink(
      target: platform.label,
      inviteAsCollaborator: inviteAsCollaborator,
    );
  }

  Future<bool> _shareStoryWithNativeComposer(
    _SharePlatform platform,
    String message,
    String link,
    _ShareLayout layout,
    bool inviteAsCollaborator,
    Uint8List? storyImageBytes,
  ) async {
    try {
      final playlist = _playlistById();
      final opened = await _storyShareChannel.invokeMethod<bool>('shareStory', {
        'platform': platform.key,
        'playlistName': playlist?.name ?? 'Collaborative Playlist',
        'inviteLink': link,
        'message': message,
        'shareLayout': layout.key,
        'inviteAsCollaborator': inviteAsCollaborator,
        'storyImageBytes': storyImageBytes,
      });
      return opened == true;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }

  Future<Uint8List?> _captureSharePreview(GlobalKey previewKey) async {
    final renderObject = previewKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) return null;

    final image = await renderObject.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData?.buffer.asUint8List();
  }

  List<Uri> _platformLaunchTargets(
    _SharePlatform platform,
    String message,
    String link,
  ) {
    final encodedMessage = Uri.encodeComponent(message);
    final encodedLink = Uri.encodeComponent(link);

    switch (platform) {
      case _SharePlatform.facebook:
        return [
          Uri.parse(
            'fb://facewebmodal/f?href=https://www.facebook.com/sharer/sharer.php?u=$encodedLink',
          ),
          Uri.parse(
            'https://www.facebook.com/sharer/sharer.php?u=$encodedLink',
          ),
        ];
      case _SharePlatform.instagram:
        return [
          Uri.parse('instagram-stories://share'),
          Uri.parse('instagram://story-camera'),
        ];
      case _SharePlatform.tiktok:
        return [
          Uri.parse('snssdk1233://share?text=$encodedMessage'),
          Uri.parse('tiktok://share?text=$encodedMessage'),
        ];
      case _SharePlatform.telegram:
        return [
          Uri.parse('tg://msg?text=$encodedMessage'),
          Uri.parse(
            'https://t.me/share/url?url=$encodedLink&text=$encodedMessage',
          ),
        ];
      case _SharePlatform.x:
        return [
          Uri.parse('twitter://post?message=$encodedMessage'),
          Uri.parse('https://twitter.com/intent/tweet?text=$encodedMessage'),
        ];
    }
  }

  Widget _buildShareSheet() {
    final playlist = _playlistById();
    final playlistName = playlist?.name ?? 'Collaborative Playlist';
    final creatorName = playlist == null
        ? _creatorNameFallback()
        : _creatorName(playlist);
    final playlistPreviewKey = GlobalKey();
    final artworkPreviewKey = GlobalKey();
    final pageController = PageController(viewportFraction: 0.78);
    var selectedLayout = _ShareLayout.playlist;
    var inviteAsCollaborator = false;
    var selectedPosterColor = _sharePosterColors.first;

    void selectLayout(
      _ShareLayout layout,
      StateSetter setSheetState, {
      bool animatePage = true,
    }) {
      final page = layout == _ShareLayout.playlist ? 0 : 1;
      setSheetState(() => selectedLayout = layout);
      if (!animatePage) return;
      pageController.animateToPage(
        page,
        duration: AppMotion.standard,
        curve: Curves.easeOutCubic,
      );
    }

    Future<void> shareToPlatform(_SharePlatform platform) async {
      final previewKey = selectedLayout == _ShareLayout.playlist
          ? playlistPreviewKey
          : artworkPreviewKey;
      final storyImageBytes = await _captureSharePreview(previewKey);
      await _shareInviteToPlatform(
        platform,
        layout: selectedLayout,
        inviteAsCollaborator: inviteAsCollaborator,
        storyImageBytes: storyImageBytes,
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: AppMotion.standard,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 200),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF202020),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 14),
                      Container(
                        width: 52,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 430,
                        child: PageView(
                          controller: pageController,
                          onPageChanged: (index) {
                            selectLayout(
                              index == 0
                                  ? _ShareLayout.playlist
                                  : _ShareLayout.artwork,
                              setSheetState,
                              animatePage: false,
                            );
                          },
                          children: [
                            _ShareStoryPreview(
                              repaintKey: playlistPreviewKey,
                              layout: _ShareLayout.playlist,
                              isSelected:
                                  selectedLayout == _ShareLayout.playlist,
                              playlistName: playlistName,
                              creatorName: creatorName,
                              coverUrl: playlist?.coverUrl ?? '',
                              posterColor: selectedPosterColor,
                            ),
                            _ShareStoryPreview(
                              repaintKey: artworkPreviewKey,
                              layout: _ShareLayout.artwork,
                              isSelected:
                                  selectedLayout == _ShareLayout.artwork,
                              playlistName: playlistName,
                              creatorName: creatorName,
                              coverUrl: playlist?.coverUrl ?? '',
                              posterColor: selectedPosterColor,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: _ShareLayoutToggle(
                          selectedLayout: selectedLayout,
                          onChanged: (layout) {
                            selectLayout(layout, setSheetState);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: _SharePosterColorPicker(
                          selectedColor: selectedPosterColor,
                          onChanged: (color) {
                            setSheetState(() => selectedPosterColor = color);
                          },
                        ),
                      ),
                      AnimatedContainer(
                        duration: AppMotion.quick,
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: GestureDetector(
                          onTap: () {
                            setSheetState(
                              () =>
                                  inviteAsCollaborator = !inviteAsCollaborator,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: AppMotion.quick,
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: inviteAsCollaborator
                                        ? Colors.white
                                        : Colors.white54,
                                    width: 3,
                                  ),
                                  color: inviteAsCollaborator
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                child: inviteAsCollaborator
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.black,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Invite as collaborator',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 1),
                      SizedBox(
                        height: 132,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
                          children: [
                            _SocialButton(
                              color: Colors.white,
                              label: 'Copy\nlink',
                              onTap: () => _copyInviteLink(
                                inviteAsCollaborator: inviteAsCollaborator,
                              ),
                            ),
                            const SizedBox(width: 22),
                            _SocialButton(
                              imageUrl:
                                  _sharePlatformImages[_SharePlatform
                                      .instagram],
                              color: const Color(0xFFE4405F),
                              label: 'Stories',
                              onTap: () =>
                                  shareToPlatform(_SharePlatform.instagram),
                            ),
                            const SizedBox(width: 22),
                            _SocialButton(
                              imageUrl:
                                  _sharePlatformImages[_SharePlatform.facebook],
                              color: const Color(0xFF1877F2),
                              label: 'Stories',
                              onTap: () =>
                                  shareToPlatform(_SharePlatform.facebook),
                            ),
                            const SizedBox(width: 22),
                            _SocialButton(
                              imageUrl:
                                  _sharePlatformImages[_SharePlatform.tiktok],
                              color: Colors.white,
                              label: 'TikTok',
                              onTap: () =>
                                  shareToPlatform(_SharePlatform.tiktok),
                            ),
                            const SizedBox(width: 22),
                            _SocialButton(
                              imageUrl:
                                  _sharePlatformImages[_SharePlatform.telegram],
                              color: const Color(0xFF2AABEE),
                              label: 'Telegram',
                              onTap: () =>
                                  shareToPlatform(_SharePlatform.telegram),
                            ),
                            const SizedBox(width: 22),
                            _SocialButton(
                              imageUrl: _sharePlatformImages[_SharePlatform.x],
                              color: Colors.white,
                              label: 'X',
                              onTap: () => shareToPlatform(_SharePlatform.x),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _creatorNameFallback() {
    final displayName = FirebaseAuth.instance.currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;
    final profileName = AudifyStore.instance.profile.displayName.trim();
    return profileName.isEmpty ? 'You' : profileName;
  }

  CollaborativePlaylistModel? _playlistById() {
    return CollaborativeStore.instance.collaborativePlaylists
        .cast<CollaborativePlaylistModel?>()
        .firstWhere(
          (playlist) => playlist?.id == widget.playlistId,
          orElse: () => null,
        );
  }

  List<SongModel> _songsInPlaylist(CollaborativePlaylistModel playlist) {
    return playlist.songs
        .map((collabSong) => AudifyStore.instance.songById(collabSong.songId))
        .whereType<SongModel>()
        .toList(growable: false);
  }

  List<SongModel> _recommendedSongs(CollaborativePlaylistModel playlist) {
    final addedIds = playlist.songs.map((song) => song.songId).toSet();
    return AudifyStore.instance.songs
        .where((song) => !addedIds.contains(song.id))
        .take(12)
        .toList(growable: false);
  }

  String _creatorName(CollaborativePlaylistModel playlist) {
    final user = FirebaseAuth.instance.currentUser;
    if (playlist.creatorId == user?.uid) {
      final displayName = user?.displayName?.trim();
      if (displayName != null && displayName.isNotEmpty) return displayName;
      final profileName = AudifyStore.instance.profile.displayName.trim();
      if (profileName.isNotEmpty) return profileName;
      return 'You';
    }
    return 'Collaborator';
  }

  String _initialFor(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  Future<void> _addSong(CollaborativePlaylistModel playlist, SongModel song) {
    return CollaborativeStore.instance.addSongToCollab(playlist.id, song);
  }

  Future<void> _playSong(List<SongModel> songs, int index) async {
    final song = songs[index];
    try {
      await LocalAudioPlayer.instance.playQueue(songs, startIndex: index);
      if (!mounted) return;
      Navigator.push(context, AppMotion.route(NowPlayingScreen(song: song)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add the file ${song.localAudioPath ?? 'for this song'} first.',
          ),
        ),
      );
    }
  }

  Future<void> _pickCover(CollaborativePlaylistModel playlist) async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      await CollaborativeStore.instance.updateCollaborativePlaylist(
        playlistId: playlist.id,
        coverUrl: image.path,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cover updated')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update cover: $error')));
    }
  }

  void _showEditDetailsSheet(CollaborativePlaylistModel playlist) {
    final nameController = TextEditingController(text: playlist.name);
    final descriptionController = TextEditingController(
      text: playlist.description,
    );
    final coverController = TextEditingController(text: playlist.coverUrl);
    var selectedCoverPath = playlist.coverUrl;
    final screenContext = context;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> pickImage() async {
              final image = await _imagePicker.pickImage(
                source: ImageSource.gallery,
              );
              if (image == null) return;
              selectedCoverPath = image.path;
              coverController.text = image.path;
              setSheetState(() {});
            }

            Future<void> save() async {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playlist name is required')),
                );
                return;
              }

              await CollaborativeStore.instance.updateCollaborativePlaylist(
                playlistId: playlist.id,
                name: name,
                description: descriptionController.text,
                coverUrl: coverController.text,
              );
              if (!context.mounted || !mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(
                screenContext,
              ).showSnackBar(const SnackBar(content: Text('Playlist updated')));
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text('Edit playlist', style: AppTextStyles.h2),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: _EditableCover(
                          coverUrl: selectedCoverPath,
                          onTap: pickImage,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: coverController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'Cover image URL or picked file path',
                      ),
                      onChanged: (value) {
                        selectedCoverPath = value;
                        setSheetState(() {});
                      },
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: save,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPlaylistMenu(CollaborativePlaylistModel playlist) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isCreator = playlist.creatorId == userId;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.white),
                title: const Text(
                  'Edit details',
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEditDetailsSheet(playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.add, color: Colors.white),
                title: const Text('Add songs', style: AppTextStyles.bodyLarge),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSongsSheet(playlist);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text(
                  'Copy invite link',
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _copyInviteLink();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text(
                  'Share invite',
                  style: AppTextStyles.bodyLarge,
                ),
                onTap: () {
                  Navigator.pop(context);
                  _shareInviteLink();
                },
              ),
              if (isCreator)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Delete playlist',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeletePlaylist(playlist);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Leave playlist',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLeavePlaylist(playlist);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeletePlaylist(CollaborativePlaylistModel playlist) {
    final screenContext = context;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete playlist?', style: AppTextStyles.h2),
          content: Text(
            'This will permanently delete "${playlist.name}" for every collaborator.',
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                await CollaborativeStore.instance.deleteCollaborativePlaylist(
                  playlist.id,
                );
                if (!context.mounted || !mounted) return;
                Navigator.pop(context);
                Navigator.pop(screenContext);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _confirmLeavePlaylist(CollaborativePlaylistModel playlist) {
    final screenContext = context;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Leave playlist?', style: AppTextStyles.h2),
          content: Text(
            'You will no longer see "${playlist.name}" in your library.',
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await CollaborativeStore.instance.leaveCollaborativePlaylist(
                    playlist.id,
                  );
                  if (!context.mounted || !mounted) return;
                  Navigator.pop(context);
                  Navigator.pop(screenContext);
                } catch (error) {
                  if (!context.mounted || !mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    screenContext,
                  ).showSnackBar(SnackBar(content: Text(error.toString())));
                }
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSongsSheet(CollaborativePlaylistModel playlist) {
    final recommended = _recommendedSongs(playlist);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 8, 12),
                child: Text('Add to this playlist', style: AppTextStyles.h2),
              ),
              if (recommended.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Every available song is already in this playlist.',
                    style: AppTextStyles.bodySmall,
                  ),
                )
              else
                ...recommended.map(
                  (song) => _SongSuggestionTile(
                    song: song,
                    onAdd: () async {
                      await _addSong(playlist, song);
                      if (context.mounted) Navigator.pop(context);
                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(content: Text('Added ${song.title}')),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListenableBuilder(
        listenable: Listenable.merge([
          CollaborativeStore.instance,
          AudifyStore.instance,
        ]),
        builder: (context, child) {
          final playlist = _playlistById();
          if (playlist == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final creatorName = _creatorName(playlist);
          final playlistSongs = _songsInPlaylist(playlist);
          final recommendedSongs = _recommendedSongs(playlist);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _HeroHeader(
                  playlist: playlist,
                  creatorName: creatorName,
                  onBack: () => Navigator.pop(context),
                  onShare: () => _showShareModal(context),
                  onAddSongs: () => _showAddSongsSheet(playlist),
                  onCopyInvite: _copyInviteLink,
                  onEditDetails: () => _showEditDetailsSheet(playlist),
                  onPickCover: () => _pickCover(playlist),
                  onShowMenu: () => _showPlaylistMenu(playlist),
                  collaboratorInitial: _initialFor(creatorName),
                ),
              ),
              if (playlistSongs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 10),
                    child: Text(
                      'In this playlist',
                      style: AppTextStyles.h1.copyWith(fontSize: 24),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: playlistSongs.length,
                  itemBuilder: (context, index) {
                    final song = playlistSongs[index];
                    return _PlaylistSongTile(
                      song: song,
                      onTap: () => _playSong(playlistSongs, index),
                      onRemove: () =>
                          CollaborativeStore.instance.removeSongFromCollab(
                            playlist.id,
                            song.id,
                            song.title,
                          ),
                    );
                  },
                ),
              ],
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 10),
                  child: Text(
                    'Recommended Songs',
                    style: AppTextStyles.h1.copyWith(fontSize: 24),
                  ),
                ),
              ),
              if (recommendedSongs.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 18, 28, 120),
                    child: Text(
                      'No more recommended songs right now.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: recommendedSongs.length,
                  itemBuilder: (context, index) {
                    final song = recommendedSongs[index];
                    return AppMotionEntry(
                      delay: Duration(milliseconds: 28 * index),
                      child: _RecommendedSongTile(
                        song: song,
                        onTap: () => _playSong(recommendedSongs, index),
                        onAdd: () async {
                          await _addSong(playlist, song);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added ${song.title}')),
                          );
                        },
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 130)),
            ],
          );
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final CollaborativePlaylistModel playlist;
  final String creatorName;
  final String collaboratorInitial;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onAddSongs;
  final VoidCallback onCopyInvite;
  final VoidCallback onEditDetails;
  final VoidCallback onPickCover;
  final VoidCallback onShowMenu;

  const _HeroHeader({
    required this.playlist,
    required this.creatorName,
    required this.collaboratorInitial,
    required this.onBack,
    required this.onShare,
    required this.onAddSongs,
    required this.onCopyInvite,
    required this.onEditDetails,
    required this.onPickCover,
    required this.onShowMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        28,
        MediaQuery.paddingOf(context).top + 24,
        28,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4C4C4C), AppColors.background],
          stops: [0, 0.92],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 36),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _EditableCover(coverUrl: playlist.coverUrl, onTap: onPickCover),
              const SizedBox(width: 22),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            playlist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h1.copyWith(fontSize: 26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: onEditDetails,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.12,
                            ),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Change',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: onShare,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFF333333),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(-6, 0),
                          child: CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.blueAccent,
                            child: Text(
                              collaboratorInitial,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            creatorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h2.copyWith(fontSize: 19),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onCopyInvite,
            child: const Icon(
              Icons.public,
              color: AppColors.secondaryText,
              size: 24,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              IconButton(
                onPressed: onShare,
                icon: const Icon(
                  Icons.share_outlined,
                  color: AppColors.secondaryText,
                  size: 28,
                ),
              ),
              const SizedBox(width: 30),
              IconButton(
                onPressed: onShowMenu,
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.secondaryText,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Center(
            child: FilledButton.icon(
              onPressed: onAddSongs,
              icon: const Icon(Icons.add, size: 24),
              label: const Text('Add to this playlist'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableCover extends StatelessWidget {
  final String coverUrl;
  final VoidCallback? onTap;

  const _EditableCover({required this.coverUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 128,
        height: 128,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _ArtworkImage(
              source: coverUrl,
              width: 128,
              height: 128,
              fit: BoxFit.cover,
              placeholderIcon: Icons.edit_outlined,
              placeholderIconSize: 48,
            ),
            Container(color: Colors.black.withValues(alpha: 0.24)),
            const Center(
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.secondaryText,
                size: 48,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkImage extends StatelessWidget {
  final String source;
  final double width;
  final double height;
  final BoxFit fit;
  final IconData placeholderIcon;
  final double placeholderIconSize;

  const _ArtworkImage({
    required this.source,
    required this.width,
    required this.height,
    required this.fit,
    this.placeholderIcon = Icons.music_note,
    this.placeholderIconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = source.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }

    if (trimmed.isNotEmpty) {
      final file = File(trimmed);
      if (file.existsSync()) {
        return Image.file(file, width: width, height: height, fit: fit);
      }
    }

    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(
        placeholderIcon,
        color: AppColors.secondaryText,
        size: placeholderIconSize,
      ),
    );
  }
}

class _PlaylistSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistSongTile({
    required this.song,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return _SongRow(
      song: song,
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(
          CupertinoIcons.minus_circle,
          color: AppColors.secondaryText,
          size: 25,
        ),
        onPressed: onRemove,
      ),
    );
  }
}

class _RecommendedSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _RecommendedSongTile({
    required this.song,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return _SongRow(
      song: song,
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(
          CupertinoIcons.plus_circle,
          color: AppColors.secondaryText,
          size: 25,
        ),
        onPressed: onAdd,
      ),
    );
  }
}

class _SongSuggestionTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onAdd;

  const _SongSuggestionTile({required this.song, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return _SongRow(
      song: song,
      horizontalPadding: 8,
      trailing: IconButton(
        icon: const Icon(CupertinoIcons.plus_circle, color: Colors.white),
        onPressed: onAdd,
      ),
    );
  }
}

class _SongRow extends StatelessWidget {
  final SongModel song;
  final Widget trailing;
  final VoidCallback? onTap;
  final double horizontalPadding;

  const _SongRow({
    required this.song,
    required this.trailing,
    this.onTap,
    this.horizontalPadding = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: _ArtworkImage(
                source: song.coverUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(fontSize: 21),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ShareStoryPreview extends StatelessWidget {
  final GlobalKey repaintKey;
  final _ShareLayout layout;
  final bool isSelected;
  final String playlistName;
  final String creatorName;
  final String coverUrl;
  final Color posterColor;

  const _ShareStoryPreview({
    required this.repaintKey,
    required this.layout,
    required this.isSelected,
    required this.playlistName,
    required this.creatorName,
    required this.coverUrl,
    required this.posterColor,
  });

  @override
  Widget build(BuildContext context) {
    final isArtwork = layout == _ShareLayout.artwork;

    return RepaintBoundary(
      key: repaintKey,
      child: AnimatedScale(
        scale: isSelected ? 1 : 0.94,
        duration: AppMotion.quick,
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: AppMotion.quick,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isSelected ? 0.34 : 0.18),
                blurRadius: isSelected ? 22 : 12,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _StoryArtworkBackdrop(
                    coverUrl: coverUrl,
                    posterColor: posterColor,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.28)),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isArtwork ? 38 : 30,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: isArtwork ? 310 : 320,
                          child: isArtwork
                              ? _ArtworkPreviewBody(
                                  playlistName: playlistName,
                                  creatorName: creatorName,
                                  coverUrl: coverUrl,
                                )
                              : _PlaylistPreviewBody(
                                  playlistName: playlistName,
                                  creatorName: creatorName,
                                  coverUrl: coverUrl,
                                ),
                        ),
                      ),
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

class _StoryArtworkBackdrop extends StatelessWidget {
  final String coverUrl;
  final Color posterColor;

  const _StoryArtworkBackdrop({
    required this.coverUrl,
    required this.posterColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(color: posterColor)),
        Transform.scale(
          scale: 1.12,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: _ArtworkImage(
              source: coverUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              placeholderIconSize: 88,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(color: posterColor.withValues(alpha: 0.32)),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.22),
                Colors.black.withValues(alpha: 0.06),
                Colors.black.withValues(alpha: 0.48),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlaylistPreviewBody extends StatelessWidget {
  final String playlistName;
  final String creatorName;
  final String coverUrl;

  const _PlaylistPreviewBody({
    required this.playlistName,
    required this.creatorName,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _StoryPostCard(
      maxWidth: 320,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ArtworkImage(
                    source: coverUrl,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholderIconSize: 42,
                  ),
                  const Positioned(
                    right: 6,
                    bottom: 6,
                    child: _AudifyLogoBadge(size: 24),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlistName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  creatorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFCFCFCF),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 18),
                const _AudifyMark(fontSize: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkPreviewBody extends StatelessWidget {
  final String playlistName;
  final String creatorName;
  final String coverUrl;

  const _ArtworkPreviewBody({
    required this.playlistName,
    required this.creatorName,
    required this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _StoryPostCard(
      maxWidth: 310,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ArtworkImage(
                    source: coverUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholderIconSize: 84,
                  ),
                  const Positioned(
                    right: 12,
                    bottom: 12,
                    child: _AudifyLogoBadge(size: 38),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            playlistName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            creatorName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFCFCFCF),
              fontSize: 17,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 28),
          const _AudifyMark(fontSize: 16),
        ],
      ),
    );
  }
}

class _StoryPostCard extends StatelessWidget {
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _StoryPostCard({
    required this.maxWidth,
    required this.padding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.42),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class _ShareLayoutToggle extends StatelessWidget {
  final _ShareLayout selectedLayout;
  final ValueChanged<_ShareLayout> onChanged;

  const _ShareLayoutToggle({
    required this.selectedLayout,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: _ShareLayout.values.map((layout) {
          final selected = layout == selectedLayout;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(layout),
              child: AnimatedScale(
                scale: selected ? 1 : 0.97,
                duration: AppMotion.quick,
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: AppMotion.quick,
                  curve: Curves.easeOutCubic,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    layout.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: selected
                          ? Colors.black
                          : Colors.white.withValues(alpha: 0.82),
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SharePosterColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onChanged;

  const _SharePosterColorPicker({
    required this.selectedColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _sharePosterColors.map((color) {
        final selected = color == selectedColor;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () => onChanged(color),
            child: AnimatedContainer(
              duration: AppMotion.quick,
              curve: Curves.easeOutCubic,
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.white24,
                  width: selected ? 2 : 1,
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AudifyMark extends StatelessWidget {
  final double fontSize;

  const _AudifyMark({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AudifyLogoBadge(size: fontSize + 10, hasShadow: false),
        const SizedBox(width: 8),
        Text(
          'Audify',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _AudifyLogoBadge extends StatelessWidget {
  final double size;
  final bool hasShadow;

  const _AudifyLogoBadge({required this.size, this.hasShadow = true});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: hasShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.36),
                  blurRadius: size * 0.45,
                  offset: Offset(0, size * 0.14),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.18),
        child: Image.asset(
          'assets/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String? imageUrl;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    this.imageUrl,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: imageUrl == null
                ? Icon(Icons.link, color: color, size: 28)
                : ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: 28,
                      height: 28,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.share, color: color, size: 28),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

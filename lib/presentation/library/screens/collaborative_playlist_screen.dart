import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/collaborative_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/collaborative_playlist_model.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

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

  String _inviteLink() => 'audify://collab/${widget.playlistId}';

  Future<void> _copyInviteLink() async {
    await Clipboard.setData(ClipboardData(text: _inviteLink()));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Invite link copied')));
  }

  Future<void> _shareInviteLink([String? target]) async {
    final targetText = target == null ? '' : ' on $target';
    await SharePlus.instance.share(
      ShareParams(
        text: 'Join my collaborative playlist$targetText: ${_inviteLink()}',
      ),
    );
  }

  Widget _buildShareSheet() {
    final link = _inviteLink();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: AppMotion.standard,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * 200),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Invite collaborators', style: AppTextStyles.h2),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: QrImageView(
                    data: link,
                    version: QrVersions.auto,
                    size: 150,
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(CupertinoIcons.link, color: Colors.white),
                  title: const Text(
                    'Copy Link',
                    style: AppTextStyles.bodyLarge,
                  ),
                  trailing: const Icon(
                    CupertinoIcons.doc_on_clipboard,
                    color: AppColors.accent,
                  ),
                  onTap: _copyInviteLink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  tileColor: Colors.white.withValues(alpha: 0.05),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialButton(
                      icon: Icons.facebook,
                      color: Colors.blue,
                      label: 'Messenger',
                      onTap: () => _shareInviteLink('Messenger'),
                    ),
                    _SocialButton(
                      icon: Icons.camera_alt,
                      color: Colors.purple,
                      label: 'Instagram',
                      onTap: () => _shareInviteLink('Instagram'),
                    ),
                    _SocialButton(
                      icon: Icons.music_note,
                      color: Colors.white,
                      label: 'TikTok',
                      onTap: () => _shareInviteLink('TikTok'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
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

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
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
            child: Icon(icon, color: color, size: 28),
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

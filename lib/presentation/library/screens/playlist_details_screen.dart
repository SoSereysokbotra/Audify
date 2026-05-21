import 'package:flutter/material.dart';

import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../domain/models/song_model.dart';
import '../../player/screens/now_playing_screen.dart';

class PlaylistDetailsScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailsScreen({super.key, required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final store = AudifyStore.instance;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final playlist = store.playlistById(playlistId);
        if (playlist == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(),
            body: const Center(
              child: Text('Playlist deleted', style: AppTextStyles.bodyLarge),
            ),
          );
        }

        final songs = store.songsForPlaylist(playlist.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(playlist.title, style: AppTextStyles.h2),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit playlist',
                onPressed: () => _showEditDialog(context, playlist),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete playlist',
                onPressed: () => _confirmDelete(context, playlist),
              ),
            ],
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      playlist.coverUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(playlist.title, style: AppTextStyles.h1),
                        const SizedBox(height: 8),
                        Text(
                          playlist.description.isEmpty
                              ? 'No description'
                              : playlist.description,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${playlist.isPrivate ? 'Private' : 'Public'} playlist • ${songs.length} songs',
                          style: AppTextStyles.helper,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _showAddSongsSheet(context, playlist),
                icon: const Icon(Icons.playlist_add, color: Colors.black),
                label: const Text('Add Songs'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (songs.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      'No songs yet. Add songs to build this playlist.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...songs.map(
                  (song) => _PlaylistSongTile(
                    song: song,
                    onFavorite: () => store.toggleFavorite(song.id),
                    isFavorite: store.isFavorite(song.id),
                    onRemove: () {
                      store.removeSongFromPlaylist(playlist.id, song.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Removed ${song.title}')),
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

  void _showEditDialog(BuildContext context, UserPlaylist playlist) {
    final titleController = TextEditingController(text: playlist.title);
    final descriptionController = TextEditingController(
      text: playlist.description,
    );
    var isPrivate = playlist.isPrivate;

    showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text('Edit Playlist', style: AppTextStyles.h2),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descriptionController,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  SwitchListTile(
                    value: isPrivate,
                    onChanged: (value) {
                      setDialogState(() => isPrivate = value);
                    },
                    title: const Text('Private playlist'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    AudifyStore.instance.updatePlaylist(
                      playlistId: playlist.id,
                      title: title,
                      description: descriptionController.text,
                      isPrivate: isPrivate,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, UserPlaylist playlist) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('Delete Playlist?', style: AppTextStyles.h2),
          content: Text(
            'This will remove "${playlist.title}" from your library.',
            style: AppTextStyles.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                AudifyStore.instance.deletePlaylist(playlist.id);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddSongsSheet(BuildContext context, UserPlaylist playlist) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: AudifyStore.instance,
          builder: (context, _) {
            final store = AudifyStore.instance;
            final current = store.playlistById(playlist.id);
            final existingIds = current?.songIds.toSet() ?? <String>{};
            final available = store.songs
                .where((song) => !existingIds.contains(song.id))
                .toList();

            return SafeArea(
              child: available.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Every available song is already in this playlist.',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (context, index) {
                        final song = available[index];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              song.coverUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            song.title,
                            style: AppTextStyles.bodyLarge,
                          ),
                          subtitle: Text(
                            song.artist,
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              store.addSongToPlaylist(playlist.id, song.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Added ${song.title}')),
                              );
                            },
                          ),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

class _PlaylistSongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback onFavorite;
  final VoidCallback onRemove;
  final bool isFavorite;

  const _PlaylistSongTile({
    required this.song,
    required this.onFavorite,
    required this.onRemove,
    required this.isFavorite,
  });

  Future<void> _openPlayer(BuildContext context) async {
    try {
      await LocalAudioPlayer.instance.playSong(song);
      if (!context.mounted) return;
      Navigator.push(context, AppMotion.route(NowPlayingScreen(song: song)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Add the file ${song.localAudioPath ?? 'for this song'} first.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => _openPlayer(context),
      contentPadding: EdgeInsets.zero,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(song.coverUrl, width: 52, height: 52),
      ),
      title: Text(song.title, style: AppTextStyles.bodyLarge),
      subtitle: Text(song.artist, style: AppTextStyles.bodySmall),
      trailing: Wrap(
        spacing: 4,
        children: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.accent : AppColors.secondaryText,
            ),
            onPressed: onFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.secondaryText,
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

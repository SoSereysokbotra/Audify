import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/local_audio_player.dart';
import '../../../data/audify_store.dart';
import '../../../domain/models/song_model.dart';

class NowPlayingScreen extends StatefulWidget {
  final SongModel song;

  const NowPlayingScreen({Key? key, required this.song}) : super(key: key);

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final LocalAudioPlayer _audio = LocalAudioPlayer.instance;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _togglePlayback() async {
    try {
      await _audio.togglePlayPause();
    } catch (_) {
      AudifyStore.instance.addNotification(
        category: AudifyNotificationCategory.playback,
        title: 'Playback problem',
        message:
            'Audify could not play "${widget.song.title}". Check the audio file.',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add the file ${widget.song.localAudioPath} first.'),
        ),
      );
    }
  }

  void _showPlaylistPicker(BuildContext context) {
    final store = AudifyStore.instance;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final playlists = store.playlists;
            return SafeArea(
              child: playlists.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Create a playlist first, then add songs to it.',
                        style: AppTextStyles.bodyLarge,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final alreadyAdded = playlist.songIds.contains(
                          widget.song.id,
                        );
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.network(
                              playlist.coverUrl,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            playlist.title,
                            style: AppTextStyles.bodyLarge,
                          ),
                          subtitle: Text(
                            '${playlist.songIds.length} songs',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: Icon(
                            alreadyAdded
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: alreadyAdded
                                ? AppColors.accent
                                : Colors.white54,
                          ),
                          onTap: alreadyAdded
                              ? null
                              : () {
                                  store.addSongToPlaylist(
                                    playlist.id,
                                    widget.song.id,
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added ${widget.song.title} to ${playlist.title}',
                                      ),
                                    ),
                                  );
                                },
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  void _showOptions(BuildContext context) {
    final store = AudifyStore.instance;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListenableBuilder(
          listenable: store,
          builder: (context, _) {
            final isFavorite = store.isFavorite(widget.song.id);
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.accent : Colors.white,
                    ),
                    title: Text(
                      isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      store.toggleFavorite(widget.song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removed ${widget.song.title} from favorites'
                                : 'Added ${widget.song.title} to favorites',
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                    ),
                    title: Text(
                      "Add to Playlist",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showPlaylistPicker(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share, color: Colors.white),
                    title: Text(
                      "Share",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgress() {
    return StreamBuilder<Duration?>(
      stream: _audio.durationStream,
      builder: (context, durationSnapshot) {
        final duration = durationSnapshot.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: _audio.positionStream,
          builder: (context, positionSnapshot) {
            final position = positionSnapshot.data ?? Duration.zero;
            final max = duration.inMilliseconds <= 0
                ? 1.0
                : duration.inMilliseconds.toDouble();
            final value = position.inMilliseconds.clamp(0, max.toInt());

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    min: 0,
                    max: max,
                    value: value.toDouble(),
                    onChanged: (newValue) {
                      _audio.seek(Duration(milliseconds: newValue.round()));
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(position),
                      style: AppTextStyles.helper.copyWith(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: AppTextStyles.helper.copyWith(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return StreamBuilder(
      stream: _audio.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = _audio.player.playing;
        return GestureDetector(
          onTap: _togglePlayback,
          child: Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: 36,
            ),
          ),
        );
      },
    );
  }

  /// Builds the current song info — reacts to audio player changes so the
  /// title/artist update automatically when auto-next fires.
  Widget _buildSongInfo() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final song = _audio.currentSong ?? widget.song;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListenableBuilder(
              listenable: AudifyStore.instance,
              builder: (context, _) {
                final isFavorite = AudifyStore.instance.isFavorite(song.id);
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.accent : Colors.white54,
                    size: 28,
                  ),
                  onPressed: () {
                    AudifyStore.instance.toggleFavorite(song.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isFavorite
                              ? 'Removed ${song.title} from favorites'
                              : 'Added ${song.title} to favorites',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    song.title,
                    style: AppTextStyles.h1.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.artist,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Colors.white54,
                size: 28,
              ),
              onPressed: () => _showOptions(context),
            ),
          ],
        );
      },
    );
  }

  /// Builds the album art — updates when auto-next fires.
  Widget _buildAlbumArt() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final song = _audio.currentSong ?? widget.song;
        return Container(
          width: MediaQuery.of(context).size.width * 0.90,
          height: MediaQuery.of(context).size.width * 1,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.12),
                blurRadius: 80,
                spreadRadius: 20,
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(song.coverUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  /// Builds the shuffle button — highlights when active.
  Widget _buildShuffleButton() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final isActive = _audio.shuffleEnabled;
        return IconButton(
          icon: Icon(
            Icons.shuffle,
            color: isActive ? AppColors.accent : Colors.white54,
            size: 24,
          ),
          onPressed: () => _audio.toggleShuffle(),
        );
      },
    );
  }

  /// Builds the repeat button — shows different icon for each mode.
  Widget _buildRepeatButton() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final mode = _audio.repeatMode;
        IconData icon;
        Color color;

        switch (mode) {
          case RepeatMode.off:
            icon = Icons.repeat;
            color = Colors.white54;
            break;
          case RepeatMode.all:
            icon = Icons.repeat;
            color = AppColors.accent;
            break;
          case RepeatMode.one:
            icon = Icons.repeat_one;
            color = AppColors.accent;
            break;
        }

        return IconButton(
          icon: Icon(icon, color: color, size: 24),
          onPressed: () => _audio.cycleRepeatMode(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Now Playing',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              _buildAlbumArt(),
              const Spacer(flex: 1),
              _buildSongInfo(),
              const SizedBox(height: 40),
              _buildProgress(),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildShuffleButton(),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_previous,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () => _audio.skipPrevious(),
                  ),
                  _buildPlayButton(),
                  IconButton(
                    icon: const Icon(
                      Icons.skip_next,
                      color: Colors.white,
                      size: 36,
                    ),
                    onPressed: () => _audio.skipNext(),
                  ),
                  _buildRepeatButton(),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

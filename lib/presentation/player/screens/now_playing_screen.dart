import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../../data/local_audio_player.dart';
import '../../../data/mock_data.dart';
import '../../../domain/models/artist_model.dart';
import '../../../domain/models/song_model.dart';
import 'explore_feed_screen.dart';
import 'lyrics_screen.dart';

class NowPlayingScreen extends StatefulWidget {
  final SongModel song;

  const NowPlayingScreen({super.key, required this.song});

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

  void _sharePoster(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareSheetWidget(song: song),
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

  Widget _buildTimerButton() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final isActive = _audio.sleepTimerEndTime != null;
        return IconButton(
          icon: Icon(
            Icons.timer_outlined,
            color: isActive ? AppColors.accent : Colors.white54,
            size: 24,
          ),
          onPressed: () => _showSleepTimerOptions(context),
        );
      },
    );
  }

  void _showSleepTimerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Stop audio in',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  '5 minutes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _audio.startSleepTimer(const Duration(minutes: 5));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  '10 minutes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _audio.startSleepTimer(const Duration(minutes: 10));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  '15 minutes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _audio.startSleepTimer(const Duration(minutes: 15));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  '30 minutes',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _audio.startSleepTimer(const Duration(minutes: 30));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'Turn off timer',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _audio.cancelSleepTimer();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight =
        screenHeight - topPadding - bottomPadding - kToolbarHeight;

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: availableHeight,
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
                          _buildTimerButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.speaker_group_outlined,
                              color: Colors.white54,
                              size: 24,
                            ),
                            onPressed: () => _showDevicesOptions(context),
                          ),
                          Row(
                            children: [
                              AnimatedBuilder(
                                animation: _audio,
                                builder: (context, _) {
                                  return IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white54,
                                      size: 24,
                                    ),
                                    onPressed: () => _sharePoster(
                                      context,
                                      _audio.currentSong ?? widget.song,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(
                                  Icons.queue_music,
                                  color: Colors.white54,
                                  size: 24,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              _buildExploreSection(),
              _buildLyricsPreviewSection(),
              _buildAboutArtistSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreSection() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final song = _audio.currentSong ?? widget.song;
        final artist = song.artist;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Explore $artist',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  children: [
                    _buildExploreCard(
                      title: 'Songs by ${widget.song.artist}',
                      imageUrl: widget.song.coverUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExploreFeedScreen(
                              songs:
                                  MockData.localSongs, // Use mock data for now
                              initialIndex: 0,
                              title: widget.song.artist,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildExploreCard(
                      title: 'Similar to ${widget.song.artist}',
                      imageUrl:
                          'https://i.pinimg.com/736x/20/7a/b1/207ab15d7d5a91ad76e050959df4cb5a.jpg',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ExploreFeedScreen(
                              songs: MockData.localSongs.reversed.toList(),
                              initialIndex: 0,
                              title: 'Similar Artists',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLyricsPreviewSection() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final song = _audio.currentSong ?? widget.song;

        // Show lyrics preview if we have lyrics
        if (song.lyrics == null || song.lyrics!.isEmpty) {
          return const SizedBox.shrink();
        }

        final timestampPattern = RegExp(
          r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]',
        );
        final lines = song.lyrics!
            .split('\n')
            .map((line) => line.replaceAll(timestampPattern, '').trim())
            .where((line) => line.isNotEmpty)
            .toList();
        final previewLines = lines.take(7).toList(); // Show first ~7 lines

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF4A4A4A), // Dark grey
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lyrics preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...previewLines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      line,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LyricsScreen(song: song),
                        ),
                      );
                    },
                    child: const Text(
                      'Show lyrics',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutArtistSection() {
    return AnimatedBuilder(
      animation: _audio,
      builder: (context, _) {
        final song = _audio.currentSong ?? widget.song;
        final artists = song.artist.split(',').map((e) => e.trim()).toList();

        return Column(
          children: artists.map((artistName) {
            // Find artist in mock data to get image
            final allArtists = [
              ...MockData.trendingArtists,
              ...MockData.mockIdols,
            ];
            final matchedArtist = allArtists.firstWhere(
              (a) => a.name.toLowerCase() == artistName.toLowerCase(),
              orElse: () => ArtistModel(
                id: 'unknown',
                name: artistName,
                imageUrl: song.coverUrl, // fallback to song cover
              ),
            );

            // Generate some mock bio and listeners
            final listeners = (artistName.length * 4.2).toStringAsFixed(1) + 'M';
            final rank = (artistName.length * 7) % 200 + 1;
            final bio =
                '$artistName has proven to be one of the industry\'s most consistent hitmakers and sought-after collaborators. They have amassed enormous success globally, delivering chart-topping hits and captivating audiences with their unique sound and compelling songwriting. From early beginnings to sold-out arenas, $artistName continues to push creative boundaries.';

            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF282828), // Dark grey
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          matchedArtist.imageUrl,
                          height: 250,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Positioned(
                          top: 16,
                          left: 16,
                          child: Text(
                            'About the artist',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#$rank in the world',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            matchedArtist.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$listeners monthly listeners',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            bio,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showDevicesOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Current device',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.phone_iphone, color: AppColors.accent),
                title: const Text(
                  'This phone',
                  style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.check, color: AppColors.accent),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const Divider(color: Colors.white24),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select a device',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.speaker, color: Colors.white),
                title: const Text(
                  'Bluetooth Speaker',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connecting to Bluetooth Speaker...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tv, color: Colors.white),
                title: const Text(
                  'Smart TV',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Connecting to Smart TV...')),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExploreCard({
    required String title,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShareSheetWidget extends StatefulWidget {
  final SongModel song;

  const _ShareSheetWidget({required this.song});

  @override
  State<_ShareSheetWidget> createState() => _ShareSheetWidgetState();
}

class _ShareSheetWidgetState extends State<_ShareSheetWidget> {
  final GlobalKey _posterKey = GlobalKey();
  Color _backgroundColor = const Color(0xFF6A1B1A); // Default dark red
  bool _isSharing = false;

  final List<Color> _colors = [
    const Color(0xFF6A1B1A), // Dark red
    const Color(0xFF1B3A6A), // Dark blue
    const Color(0xFF1A6A3A), // Dark green
    const Color(0xFF6A4A1A), // Dark brown
    const Color(0xFF2A2A2A), // Dark gray
  ];

  Future<void> _captureAndShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary =
          _posterKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      // Use a higher pixel ratio for better quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/share_poster.png');
      await file.writeAsBytes(pngBytes);

      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Listen to ${widget.song.title} by ${widget.song.artist} on Audify!',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to share poster: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Preview Area
          RepaintBoundary(
            key: _posterKey,
            child: Container(
              width: 250,
              height: 400,
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.song.coverUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.song.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.music_note,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Audify',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Color Pickers
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _colors.map((color) {
              final isSelected = _backgroundColor == color;
              return GestureDetector(
                onTap: () => setState(() => _backgroundColor = color),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          // Share Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSharing ? null : _captureAndShare,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isSharing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

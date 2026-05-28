import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../../../domain/models/song_model.dart';
import '../../../data/local_audio_player.dart';

class LyricsScreen extends StatefulWidget {
  final SongModel song;

  const LyricsScreen({super.key, required this.song});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  final LocalAudioPlayer _audio = LocalAudioPlayer.instance;
  final ScrollController _lyricsScrollController = ScrollController();
  int _lastCenteredLine = -1;

  @override
  void dispose() {
    _lyricsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _parseLyrics(widget.song.lyrics);

    return Scaffold(
      backgroundColor: const Color(
        0xFF4A4A4A,
      ), // Dark grey background matching image
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.song.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.song.artist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 48), // Balance for down arrow
                ],
              ),
            ),

            // Lyrics List
            Expanded(
              child: StreamBuilder<Duration>(
                stream: _audio.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final currentLineIndex = _activeLyricIndex(lines, position);
                  _scrollToActiveLine(currentLineIndex);

                  return ListView.builder(
                    controller: _lyricsScrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    itemCount: lines.length,
                    itemBuilder: (context, index) {
                      final isActive = index == currentLineIndex;
                      final isPassed = index < currentLineIndex;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          style: TextStyle(
                            color: isActive || isPassed
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: isActive ? 25 : 22,
                            fontWeight: isActive
                                ? FontWeight.w900
                                : FontWeight.bold,
                            height: 1.4,
                          ),
                          child: Text(lines[index].text),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  StreamBuilder<Duration?>(
                    stream: _audio.durationStream,
                    builder: (context, durationSnapshot) {
                      final duration = durationSnapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: _audio.positionStream,
                        builder: (context, positionSnapshot) {
                          final position =
                              positionSnapshot.data ?? Duration.zero;
                          final max = duration.inMilliseconds <= 0
                              ? 1.0
                              : duration.inMilliseconds.toDouble();
                          final value = position.inMilliseconds
                              .clamp(0, max.toInt())
                              .toDouble();

                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 4.0,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6.0,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14.0,
                                  ),
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white30,
                                  thumbColor: Colors.white,
                                ),
                                child: Slider(
                                  value: value,
                                  max: max,
                                  onChanged: (val) {
                                    _audio.seek(
                                      Duration(milliseconds: val.toInt()),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  StreamBuilder<PlayerState>(
                    stream: _audio.playerStateStream,
                    builder: (context, snapshot) {
                      final isPlaying = snapshot.data?.playing ?? false;
                      return GestureDetector(
                        onTap: () {
                          _audio.togglePlayPause();
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _scrollToActiveLine(int index) {
    if (index == _lastCenteredLine) return;
    _lastCenteredLine = index;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_lyricsScrollController.hasClients) return;
      final targetOffset = (index * 58.0 - 160).clamp(
        0.0,
        _lyricsScrollController.position.maxScrollExtent,
      );
      _lyricsScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<_SyncedLyricLine> _parseLyrics(String? lyrics) {
    final rawLines = lyrics?.split('\n') ?? const <String>[];
    if (rawLines.isEmpty) {
      return const [_SyncedLyricLine(Duration.zero, 'No lyrics available')];
    }

    final timestampPattern = RegExp(r'\[(\d{1,2}):(\d{2})(?:[.:](\d{1,3}))?\]');
    final syncedLines = <_SyncedLyricLine>[];
    var latestTime = Duration.zero;

    for (
      var fallbackIndex = 0;
      fallbackIndex < rawLines.length;
      fallbackIndex++
    ) {
      final rawLine = rawLines[fallbackIndex];
      final matches = timestampPattern.allMatches(rawLine).toList();
      final text = rawLine.replaceAll(timestampPattern, '').trim();
      if (text.isEmpty) continue;

      if (matches.isEmpty) {
        final fallbackTime = syncedLines.isEmpty
            ? Duration(seconds: fallbackIndex * 3)
            : latestTime + const Duration(seconds: 3);
        latestTime = fallbackTime;
        syncedLines.add(_SyncedLyricLine(fallbackTime, text, fallbackIndex));
        continue;
      }

      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '') ?? 0;
        final fractionText = (match.group(3) ?? '').padRight(3, '0');
        final milliseconds = int.tryParse(fractionText.substring(0, 3)) ?? 0;

        final time = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: milliseconds,
        );
        latestTime = time;
        syncedLines.add(_SyncedLyricLine(time, text, fallbackIndex));
      }
    }

    syncedLines.sort((a, b) {
      final timeComparison = a.time.compareTo(b.time);
      if (timeComparison != 0) return timeComparison;
      return a.sequence.compareTo(b.sequence);
    });
    return syncedLines.isEmpty
        ? const [_SyncedLyricLine(Duration.zero, 'No lyrics available')]
        : syncedLines;
  }

  int _activeLyricIndex(List<_SyncedLyricLine> lines, Duration position) {
    var activeIndex = 0;
    for (var index = 0; index < lines.length; index++) {
      if (position < lines[index].time) break;
      activeIndex = index;
    }
    return activeIndex;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString();
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _SyncedLyricLine {
  final Duration time;
  final String text;
  final int sequence;

  const _SyncedLyricLine(this.time, this.text, [this.sequence = 0]);
}

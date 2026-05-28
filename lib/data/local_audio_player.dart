import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/models/song_model.dart';
import 'audify_store.dart';

enum RepeatMode { off, all, one }

class LocalAudioPlayer extends ChangeNotifier {
  LocalAudioPlayer._() {
    // Listen for song completion to auto-play next
    _player.playerStateStream.listen(_onPlayerStateChanged);
  }

  static final LocalAudioPlayer instance = LocalAudioPlayer._();

  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  SongModel? _currentSong;
  List<SongModel> _queue = [];
  int _currentIndex = -1;

  bool _shuffleEnabled = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Track if we already triggered auto-next for the current completion event
  bool _handlingCompletion = false;

  Timer? _sleepTimer;
  DateTime? _sleepTimerEndTime;

  // ── Getters ──────────────────────────────────────────────────────────────

  AudioPlayer get player => _player;
  SongModel? get currentSong => _currentSong;
  bool get hasSong => _currentSong != null;

  bool get shuffleEnabled => _shuffleEnabled;
  RepeatMode get repeatMode => _repeatMode;

  bool get hasPrevious => _currentIndex > 0;
  bool get hasNext => _currentIndex < _queue.length - 1 || _repeatMode == RepeatMode.all;

  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // ── Queue management ─────────────────────────────────────────────────────

  /// Set a queue of songs and start playing from [startIndex].
  Future<void> playQueue(List<SongModel> songs, {int startIndex = 0}) async {
    _queue = List.from(songs);
    await _playAtIndex(startIndex);
  }

  /// Play a single song. If a queue is already loaded, find the song in it;
  /// otherwise create a single-song queue.
  Future<void> playSong(SongModel song) async {
    final indexInQueue = _queue.indexWhere((s) => s.id == song.id);
    if (indexInQueue != -1) {
      await _playAtIndex(indexInQueue);
    } else {
      // Build queue from the full song list so prev/next work
      final allSongs = AudifyStore.instance.songs;
      final globalIndex = allSongs.indexWhere((s) => s.id == song.id);
      if (globalIndex != -1) {
        _queue = List.from(allSongs);
        await _playAtIndex(globalIndex);
      } else {
        _queue = [song];
        await _playAtIndex(0);
      }
    }
  }

  Future<void> _playAtIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;

    final song = _queue[index];
    final audioPath = song.localAudioPath;
    if (audioPath == null || audioPath.isEmpty) {
      throw const LocalAudioException('No local audio file is set for this song.');
    }

    _currentIndex = index;
    _currentSong = song;
    notifyListeners();

    if (audioPath.startsWith('assets/')) {
      await _player.setAsset(audioPath);
    } else {
      await _player.setFilePath(audioPath);
    }

    await _player.play();
    AudifyStore.instance.recordPlayedSong(song);
    notifyListeners();
  }

  // ── Playback controls ─────────────────────────────────────────────────────

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimerEndTime = DateTime.now().add(duration);
    _sleepTimer = Timer(duration, () async {
      if (_player.playing) {
        await _player.pause();
      }
      _sleepTimerEndTime = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEndTime = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    _queue = [];
    _currentIndex = -1;
    notifyListeners();
  }

  /// Skip to next song respecting shuffle and repeat settings.
  Future<void> skipNext() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    int nextIndex;
    if (_shuffleEnabled) {
      nextIndex = _randomIndexExcluding(_currentIndex);
    } else {
      nextIndex = _currentIndex + 1;
    }

    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        // End of queue, stop
        return;
      }
    }

    await _playAtIndex(nextIndex);
  }

  /// Skip to previous song. If position > 3 s, restart current song instead.
  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;

    final position = _player.position;
    if (position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }

    final prevIndex = _currentIndex - 1;
    if (prevIndex < 0) {
      await _player.seek(Duration.zero);
      return;
    }

    await _playAtIndex(prevIndex);
  }

  // ── Shuffle & Repeat ──────────────────────────────────────────────────────

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _onPlayerStateChanged(PlayerState state) {
    if (state.processingState == ProcessingState.completed && !_handlingCompletion) {
      _handlingCompletion = true;
      _handleSongCompletion().then((_) => _handlingCompletion = false);
    }
  }

  Future<void> _handleSongCompletion() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    int nextIndex;
    if (_shuffleEnabled) {
      nextIndex = _randomIndexExcluding(_currentIndex);
    } else {
      nextIndex = _currentIndex + 1;
    }

    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = 0;
      } else {
        // End of queue — no repeat, stay stopped
        return;
      }
    }

    await _playAtIndex(nextIndex);
  }

  int _randomIndexExcluding(int exclude) {
    if (_queue.length == 1) return 0;
    int idx;
    do {
      idx = _random.nextInt(_queue.length);
    } while (idx == exclude);
    return idx;
  }
}

class LocalAudioException implements Exception {
  final String message;

  const LocalAudioException(this.message);

  @override
  String toString() => message;
}

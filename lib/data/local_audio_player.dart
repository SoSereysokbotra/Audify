import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../domain/models/song_model.dart';

class LocalAudioPlayer extends ChangeNotifier {
  LocalAudioPlayer._();

  static final LocalAudioPlayer instance = LocalAudioPlayer._();

  final AudioPlayer _player = AudioPlayer();

  SongModel? _currentSong;

  AudioPlayer get player => _player;
  SongModel? get currentSong => _currentSong;
  bool get hasSong => _currentSong != null;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> playSong(SongModel song) async {
    final audioPath = song.localAudioPath;
    if (audioPath == null || audioPath.isEmpty) {
      throw const LocalAudioException(
        'No local audio file is set for this song.',
      );
    }

    if (_currentSong?.id != song.id) {
      _currentSong = song;
      notifyListeners();
      await _player.setAsset(audioPath);
    }

    await _player.play();
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) => _player.seek(position);
}

class LocalAudioException implements Exception {
  final String message;

  const LocalAudioException(this.message);

  @override
  String toString() => message;
}

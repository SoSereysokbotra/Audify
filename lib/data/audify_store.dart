import 'package:flutter/foundation.dart';

import '../domain/models/playlist_model.dart';
import '../domain/models/song_model.dart';
import 'mock_data.dart';

class UserProfileData {
  final String displayName;
  final String bio;
  final String? imagePath;

  const UserProfileData({
    required this.displayName,
    required this.bio,
    this.imagePath,
  });

  UserProfileData copyWith({
    String? displayName,
    String? bio,
    String? imagePath,
  }) {
    return UserProfileData(
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class UserPlaylist {
  final String id;
  final String title;
  final String description;
  final String creator;
  final String coverUrl;
  final bool isPrivate;
  final List<String> songIds;

  const UserPlaylist({
    required this.id,
    required this.title,
    required this.description,
    required this.creator,
    required this.coverUrl,
    required this.isPrivate,
    required this.songIds,
  });

  UserPlaylist copyWith({
    String? title,
    String? description,
    String? creator,
    String? coverUrl,
    bool? isPrivate,
    List<String>? songIds,
  }) {
    return UserPlaylist(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      creator: creator ?? this.creator,
      coverUrl: coverUrl ?? this.coverUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      songIds: songIds ?? this.songIds,
    );
  }

  PlaylistModel toPlaylistModel() {
    return PlaylistModel(
      id: id,
      title: title,
      creator: creator,
      coverUrl: coverUrl,
    );
  }
}

class AudifyStore extends ChangeNotifier {
  AudifyStore._() {
    _seedPlaylists();
  }

  static final AudifyStore instance = AudifyStore._();

  final List<SongModel> _songs = [...MockData.localSongs];

  final List<UserPlaylist> _playlists = [];
  final Set<String> _favoriteSongIds = {'1', '4'};

  UserProfileData _profile = const UserProfileData(
    displayName: 'User Name',
    bio: 'Music lover building playlists on Audify.',
  );

  List<SongModel> get songs => List.unmodifiable(_songs);
  List<UserPlaylist> get playlists => List.unmodifiable(_playlists);
  List<String> get favoriteSongIds => List.unmodifiable(_favoriteSongIds);
  UserProfileData get profile => _profile;

  List<SongModel> get favoriteSongs =>
      _songs.where((song) => _favoriteSongIds.contains(song.id)).toList();

  void _seedPlaylists() {
    for (final entry in MockData.yourPlaylists.asMap().entries) {
      final playlist = entry.value;
      final songIds = switch (playlist.id) {
        'p1' => ['1', '2', '3', '4'],
        'p2' => ['2', '8', '11', '12'],
        'p3' => ['5', '6', '4'],
        'p4' => ['7', '9', '10'],
        _ => _songs.take(3).map((song) => song.id).toList(),
      };

      _playlists.add(
        UserPlaylist(
          id: playlist.id,
          title: playlist.title,
          description: '${playlist.title} playlist on Audify.',
          creator: playlist.creator,
          coverUrl: playlist.coverUrl,
          isPrivate: playlist.creator == 'You',
          songIds: songIds,
        ),
      );
    }
  }

  SongModel? songById(String id) {
    for (final song in _songs) {
      if (song.id == id) return song;
    }
    return null;
  }

  UserPlaylist? playlistById(String id) {
    for (final playlist in _playlists) {
      if (playlist.id == id) return playlist;
    }
    return null;
  }

  List<SongModel> songsForPlaylist(String playlistId) {
    final playlist = playlistById(playlistId);
    if (playlist == null) return [];
    return playlist.songIds
        .map(songById)
        .whereType<SongModel>()
        .toList(growable: false);
  }

  UserPlaylist createPlaylist({
    required String title,
    String description = '',
    List<String> songIds = const [],
    bool isPrivate = false,
    String? coverUrl,
  }) {
    final playlist = UserPlaylist(
      id: 'playlist_${DateTime.now().microsecondsSinceEpoch}',
      title: title.trim(),
      description: description.trim(),
      creator: 'You',
      coverUrl: coverUrl ?? 'https://picsum.photos/id/111/200/200',
      isPrivate: isPrivate,
      songIds: List<String>.from(songIds),
    );

    _playlists.insert(0, playlist);
    notifyListeners();
    return playlist;
  }

  void updatePlaylist({
    required String playlistId,
    String? title,
    String? description,
    bool? isPrivate,
  }) {
    final index = _playlists.indexWhere(
      (playlist) => playlist.id == playlistId,
    );
    if (index == -1) return;

    _playlists[index] = _playlists[index].copyWith(
      title: title?.trim(),
      description: description?.trim(),
      isPrivate: isPrivate,
    );
    notifyListeners();
  }

  void deletePlaylist(String playlistId) {
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere(
      (playlist) => playlist.id == playlistId,
    );
    if (index == -1) return;
    final playlist = _playlists[index];
    if (playlist.songIds.contains(songId)) return;

    _playlists[index] = playlist.copyWith(
      songIds: [...playlist.songIds, songId],
    );
    notifyListeners();
  }

  void removeSongFromPlaylist(String playlistId, String songId) {
    final index = _playlists.indexWhere(
      (playlist) => playlist.id == playlistId,
    );
    if (index == -1) return;
    final playlist = _playlists[index];

    _playlists[index] = playlist.copyWith(
      songIds: playlist.songIds.where((id) => id != songId).toList(),
    );
    notifyListeners();
  }

  bool isFavorite(String songId) => _favoriteSongIds.contains(songId);

  void toggleFavorite(String songId) {
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
    } else {
      _favoriteSongIds.add(songId);
    }
    notifyListeners();
  }

  void removeFavorite(String songId) {
    if (_favoriteSongIds.remove(songId)) {
      notifyListeners();
    }
  }

  void updateProfile({
    required String displayName,
    required String bio,
    String? imagePath,
  }) {
    _profile = _profile.copyWith(
      displayName: displayName.trim(),
      bio: bio.trim(),
      imagePath: imagePath,
    );
    notifyListeners();
  }
}

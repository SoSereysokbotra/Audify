import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class ListeningHistoryEntry {
  final SongModel song;
  final DateTime playedAt;

  const ListeningHistoryEntry({required this.song, required this.playedAt});
}

enum AudifyNotificationCategory {
  music,
  playlist,
  favorite,
  playback,
  account,
  profile,
  whatsNew,
}

class AudifyNotification {
  final String id;
  final AudifyNotificationCategory category;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  const AudifyNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  AudifyNotification copyWith({bool? isRead}) {
    return AudifyNotification(
      id: id,
      category: category,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

class AudifyStore extends ChangeNotifier {
  static final AudifyStore instance = AudifyStore._();

  StreamSubscription<User?>? _authSubscription;
  User? _currentUser;

  AudifyStore._() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    if (user != null) {
      _loadFavoritesFromFirestore();
      _loadPlaylistsFromFirestore();
      _loadNotificationsFromFirestore();
    } else {
      _favoriteSongIds.clear();
      _playlists.clear();
      _notifications.clear();
      notifyListeners();
    }
  }

  Future<void> _loadPlaylistsFromFirestore() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final playlistsData = data['playlists'] as List<dynamic>?;
        if (playlistsData != null) {
          final loaded = playlistsData
              .map(
                (e) => _playlistFromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList();
          _playlists
            ..clear()
            ..addAll(loaded);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error loading playlists from Firestore: $e");
    }
  }

  Future<void> _syncPlaylistsToFirestore() async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'playlists': _playlists.map(_playlistToJson).toList(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error syncing playlists to Firestore: $e");
    }
  }

  Map<String, dynamic> _playlistToJson(UserPlaylist p) => {
    'id': p.id,
    'title': p.title,
    'description': p.description,
    'creator': p.creator,
    'coverUrl': p.coverUrl,
    'isPrivate': p.isPrivate,
    'songIds': p.songIds,
  };

  UserPlaylist _playlistFromJson(Map<String, dynamic> m) => UserPlaylist(
    id: m['id'] as String,
    title: m['title'] as String,
    description: m['description'] as String,
    creator: m['creator'] as String,
    coverUrl: m['coverUrl'] as String,
    isPrivate: m['isPrivate'] as bool,
    songIds: List<String>.from(m['songIds'] as List<dynamic>),
  );

  Future<void> _loadFavoritesFromFirestore() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        final favs = data['favoriteSongIds'] as List<dynamic>?;
        if (favs != null) {
          _favoriteSongIds.clear();
          _favoriteSongIds.addAll(favs.cast<String>());
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
    }
  }

  Future<void> _syncFavoritesToFirestore() async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'favoriteSongIds': _favoriteSongIds.toList(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error syncing favorites: $e");
    }
  }

  String _categoryToJson(AudifyNotificationCategory category) => category.name;

  AudifyNotificationCategory _categoryFromJson(String? value) {
    return AudifyNotificationCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => AudifyNotificationCategory.whatsNew,
    );
  }

  Map<String, dynamic> _notificationToJson(AudifyNotification notification) => {
    'id': notification.id,
    'category': _categoryToJson(notification.category),
    'title': notification.title,
    'message': notification.message,
    'createdAt': Timestamp.fromDate(notification.createdAt),
    'isRead': notification.isRead,
  };

  AudifyNotification _notificationFromJson(Map<String, dynamic> data) {
    final createdAtValue = data['createdAt'];
    final createdAt = createdAtValue is Timestamp
        ? createdAtValue.toDate()
        : DateTime.tryParse(createdAtValue?.toString() ?? '') ?? DateTime.now();

    return AudifyNotification(
      id:
          data['id'] as String? ??
          'notification_${DateTime.now().microsecondsSinceEpoch}',
      category: _categoryFromJson(data['category'] as String?),
      title: data['title'] as String? ?? 'Audify',
      message: data['message'] as String? ?? '',
      createdAt: createdAt,
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Future<void> _loadNotificationsFromFirestore() async {
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final notificationsData = data['notifications'] as List<dynamic>?;
      if (notificationsData == null) return;

      final loaded =
          notificationsData
              .map(
                (item) => _notificationFromJson(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _notifications
        ..clear()
        ..addAll(loaded.take(40));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading notifications from Firestore: $e");
    }
  }

  Future<void> _syncNotificationsToFirestore() async {
    if (_currentUser == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set({
            'notifications': _notifications.map(_notificationToJson).toList(),
          }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error syncing notifications to Firestore: $e");
    }
  }

  final List<SongModel> _songs = List.from(MockData.localSongs);

  final List<UserPlaylist> _playlists = [];
  final List<ListeningHistoryEntry> _listeningHistory = [];
  final Set<String> _favoriteSongIds = {};
  final List<AudifyNotification> _notifications = [];

  UserProfileData _profile = const UserProfileData(displayName: '', bio: '');

  List<SongModel> get songs => List.unmodifiable(_songs);
  List<UserPlaylist> get playlists => List.unmodifiable(_playlists);
  List<ListeningHistoryEntry> get listeningHistory =>
      List.unmodifiable(_listeningHistory);
  List<String> get favoriteSongIds => List.unmodifiable(_favoriteSongIds);
  UserProfileData get profile => _profile;
  List<AudifyNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;

  List<SongModel> get favoriteSongs =>
      _songs.where((song) => _favoriteSongIds.contains(song.id)).toList();

  List<SongModel> get recentlyPlayedSongs {
    final seenSongIds = <String>{};
    final songs = <SongModel>[];

    for (final entry in _listeningHistory) {
      if (seenSongIds.add(entry.song.id)) {
        songs.add(entry.song);
      }
      if (songs.length == 4) break;
    }

    return songs;
  }

  String _fileNameFromPath(String path) {
    final parts = path.split(RegExp(r'[\\/]'));
    return parts.isEmpty ? path : parts.last;
  }

  String _songTitleFromPath(String path) {
    final fileName = _fileNameFromPath(path);
    final extensionIndex = fileName.lastIndexOf('.');
    final name = extensionIndex == -1
        ? fileName
        : fileName.substring(0, extensionIndex);
    return name
        .replaceAll(RegExp(r'[_-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  int importLocalAudioFiles(List<String> paths) {
    var addedCount = 0;

    for (final path in paths) {
      final trimmedPath = path.trim();
      if (trimmedPath.isEmpty) continue;
      final alreadyImported = _songs.any(
        (song) => song.localAudioPath == trimmedPath,
      );
      if (alreadyImported) continue;

      final title = _songTitleFromPath(trimmedPath);
      _songs.insert(
        0,
        SongModel(
          id: 'local_${DateTime.now().microsecondsSinceEpoch}_$addedCount',
          title: title.isEmpty ? _fileNameFromPath(trimmedPath) : title,
          artist: 'Local storage',
          coverUrl: 'https://picsum.photos/id/${100 + addedCount}/400/400',
          localAudioPath: trimmedPath,
        ),
      );
      addedCount++;
    }

    if (addedCount > 0) {
      addNotification(
        category: AudifyNotificationCategory.music,
        title: addedCount == 1 ? 'New song added' : 'New music added',
        message: addedCount == 1
            ? 'A local song is now available in your library.'
            : '$addedCount local songs are now available in your library.',
      );
      notifyListeners();
    }
    return addedCount;
  }

  void recordPlayedSong(SongModel song) {
    _listeningHistory.removeWhere((entry) => entry.song.id == song.id);
    _listeningHistory.insert(
      0,
      ListeningHistoryEntry(song: song, playedAt: DateTime.now()),
    );

    if (_listeningHistory.length > 100) {
      _listeningHistory.removeRange(100, _listeningHistory.length);
    }

    notifyListeners();
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
    addNotification(
      category: AudifyNotificationCategory.playlist,
      title: 'Playlist created',
      message: playlist.songIds.isEmpty
          ? '"${playlist.title}" is ready for songs.'
          : '"${playlist.title}" is ready with ${playlist.songIds.length} songs.',
    );
    notifyListeners();
    _syncPlaylistsToFirestore();
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
    addNotification(
      category: AudifyNotificationCategory.playlist,
      title: 'Playlist updated',
      message: '"${_playlists[index].title}" has been updated.',
    );
    notifyListeners();
    _syncPlaylistsToFirestore();
  }

  void deletePlaylist(String playlistId) {
    final removedPlaylist = playlistById(playlistId);
    _playlists.removeWhere((playlist) => playlist.id == playlistId);
    if (removedPlaylist != null) {
      addNotification(
        category: AudifyNotificationCategory.playlist,
        title: 'Playlist deleted',
        message: '"${removedPlaylist.title}" was removed from your library.',
      );
    }
    notifyListeners();
    _syncPlaylistsToFirestore();
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
    final song = songById(songId);
    addNotification(
      category: AudifyNotificationCategory.playlist,
      title: 'Song added to playlist',
      message: song == null
          ? 'A song was added to "${playlist.title}".'
          : '"${song.title}" was added to "${playlist.title}".',
    );
    notifyListeners();
    _syncPlaylistsToFirestore();
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
    final song = songById(songId);
    addNotification(
      category: AudifyNotificationCategory.playlist,
      title: 'Song removed from playlist',
      message: song == null
          ? 'A song was removed from "${playlist.title}".'
          : '"${song.title}" was removed from "${playlist.title}".',
    );
    notifyListeners();
    _syncPlaylistsToFirestore();
  }

  bool isFavorite(String songId) => _favoriteSongIds.contains(songId);

  void toggleFavorite(String songId) {
    final song = songById(songId);
    if (_favoriteSongIds.contains(songId)) {
      _favoriteSongIds.remove(songId);
      addNotification(
        category: AudifyNotificationCategory.favorite,
        title: 'Removed from favorites',
        message: song == null
            ? 'A song was removed from favorites.'
            : '"${song.title}" was removed from favorites.',
      );
    } else {
      _favoriteSongIds.add(songId);
      addNotification(
        category: AudifyNotificationCategory.favorite,
        title: 'Added to favorites',
        message: song == null
            ? 'A song was added to favorites.'
            : '"${song.title}" was added to favorites.',
      );
    }
    notifyListeners();
    _syncFavoritesToFirestore();
  }

  void removeFavorite(String songId) {
    if (_favoriteSongIds.remove(songId)) {
      final song = songById(songId);
      addNotification(
        category: AudifyNotificationCategory.favorite,
        title: 'Removed from favorites',
        message: song == null
            ? 'A song was removed from favorites.'
            : '"${song.title}" was removed from favorites.',
      );
      notifyListeners();
      _syncFavoritesToFirestore();
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
    addNotification(
      category: AudifyNotificationCategory.profile,
      title: 'Profile updated',
      message: 'Your Audify profile changes were saved.',
    );
    notifyListeners();
  }

  void addNotification({
    required AudifyNotificationCategory category,
    required String title,
    required String message,
  }) {
    final notification = AudifyNotification(
      id: 'notification_${DateTime.now().microsecondsSinceEpoch}',
      category: category,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );

    _notifications.insert(0, notification);
    if (_notifications.length > 40) {
      _notifications.removeRange(40, _notifications.length);
    }
    notifyListeners();
    _syncNotificationsToFirestore();
  }

  void markNotificationRead(String notificationId) {
    final index = _notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
    _syncNotificationsToFirestore();
  }

  void markAllNotificationsRead() {
    if (_notifications.every((notification) => notification.isRead)) return;

    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
    _syncNotificationsToFirestore();
  }

  void clearNotifications() {
    if (_notifications.isEmpty) return;

    _notifications.clear();
    notifyListeners();
    _syncNotificationsToFirestore();
  }
}

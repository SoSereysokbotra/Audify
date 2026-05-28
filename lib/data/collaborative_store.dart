import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import '../domain/models/collaborative_playlist_model.dart';
import '../domain/models/song_model.dart';

class CollaborativeStore extends ChangeNotifier {
  static final CollaborativeStore instance = CollaborativeStore._();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  StreamSubscription? _collabSubscription;

  final List<CollaborativePlaylistModel> _collaborativePlaylists = [];

  List<CollaborativePlaylistModel> get collaborativePlaylists =>
      List.unmodifiable(_collaborativePlaylists);

  CollaborativeStore._() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToCollaborativePlaylists(user.uid);
      } else {
        _collabSubscription?.cancel();
        _collaborativePlaylists.clear();
        notifyListeners();
      }
    });
  }

  void _subscribeToCollaborativePlaylists(String userId) {
    _collabSubscription?.cancel();
    _collabSubscription = _firestore
        .collection('collaborative_playlists')
        .where('collaboratorIds', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
          _collaborativePlaylists.clear();
          for (var doc in snapshot.docs) {
            try {
              _collaborativePlaylists.add(
                CollaborativePlaylistModel.fromJson(doc.data()),
              );
            } catch (e) {
              debugPrint("Error parsing collab playlist: $e");
            }
          }
          notifyListeners();
        });
  }

  Future<String> createCollaborativePlaylist({
    required String name,
    required String description,
    required String coverUrl,
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'mock_user_${_uuid.v4().substring(0, 8)}';

    final id = _uuid.v4();
    final newPlaylist = CollaborativePlaylistModel(
      id: id,
      name: name,
      description: description,
      coverUrl: coverUrl,
      creatorId: uid,
      collaboratorIds: [uid],
      privacy: 'Public',
      songs: [],
      activityFeed: [
        ActivityEvent(
          id: _uuid.v4(),
          userId: uid,
          action: 'created',
          target: name,
          timestamp: DateTime.now(),
        ),
      ],
    );

    // Optimistic UI
    _collaborativePlaylists.add(newPlaylist);
    notifyListeners();

    await _firestore
        .collection('collaborative_playlists')
        .doc(id)
        .set(newPlaylist.toJson());

    return id;
  }

  Future<void> addSongToCollab(String playlistId, SongModel song) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'mock_user_123';

    final index = _collaborativePlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _collaborativePlaylists[index];
    if (playlist.songs.any((s) => s.songId == song.id)) {
      return; // already exists
    }

    final collabSong = CollaborativeSong(
      songId: song.id,
      addedBy: uid,
      addedAt: DateTime.now(),
    );

    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: uid,
      action: 'added',
      target: song.title,
      timestamp: DateTime.now(),
    );

    // Optimistic UI
    final updatedPlaylist = playlist.copyWith(
      songs: [...playlist.songs, collabSong],
      activityFeed: [event, ...playlist.activityFeed],
    );
    _collaborativePlaylists[index] = updatedPlaylist;
    notifyListeners();

    // Firebase update
    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .update({
          'songs': FieldValue.arrayUnion([collabSong.toJson()]),
          'activityFeed': FieldValue.arrayUnion([event.toJson()]),
        });
  }

  Future<void> removeSongFromCollab(
    String playlistId,
    String songId,
    String songTitle,
  ) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'mock_user_123';

    final index = _collaborativePlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _collaborativePlaylists[index];
    final songToRemove = playlist.songs.cast<CollaborativeSong?>().firstWhere(
      (s) => s?.songId == songId,
      orElse: () => null,
    );
    if (songToRemove == null) return;

    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: uid,
      action: 'removed',
      target: songTitle,
      timestamp: DateTime.now(),
    );

    // Optimistic UI
    final updatedPlaylist = playlist.copyWith(
      songs: playlist.songs.where((s) => s.songId != songId).toList(),
      activityFeed: [event, ...playlist.activityFeed],
    );
    _collaborativePlaylists[index] = updatedPlaylist;
    notifyListeners();

    // Firebase update
    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .update({
          'songs': FieldValue.arrayRemove([songToRemove.toJson()]),
          'activityFeed': FieldValue.arrayUnion([event.toJson()]),
        });
  }

  Future<void> updateCollaborativePlaylist({
    required String playlistId,
    String? name,
    String? description,
    String? coverUrl,
  }) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'mock_user_123';

    final index = _collaborativePlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _collaborativePlaylists[index];
    final updatedName = name?.trim();
    final updatedDescription = description?.trim();
    final updatedCoverUrl = coverUrl?.trim();

    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: uid,
      action: 'updated',
      target: updatedName?.isNotEmpty == true ? updatedName! : playlist.name,
      timestamp: DateTime.now(),
    );

    final updatedPlaylist = playlist.copyWith(
      name: updatedName?.isNotEmpty == true ? updatedName : null,
      description: updatedDescription,
      coverUrl: updatedCoverUrl?.isNotEmpty == true ? updatedCoverUrl : null,
      activityFeed: [event, ...playlist.activityFeed],
    );

    _collaborativePlaylists[index] = updatedPlaylist;
    notifyListeners();

    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .update({
          'name': updatedPlaylist.name,
          'description': updatedPlaylist.description,
          'coverUrl': updatedPlaylist.coverUrl,
          'activityFeed': FieldValue.arrayUnion([event.toJson()]),
        });
  }

  Future<void> joinCollaborativePlaylist(String playlistId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseException(
        plugin: 'audify',
        code: 'not-signed-in',
        message: 'Please sign in before joining a collaborative playlist.',
      );
    }
    final uid = user.uid;

    final doc = await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .get();
    if (!doc.exists || doc.data() == null) {
      throw Exception('Playlist not found');
    }

    final playlist = CollaborativePlaylistModel.fromJson(doc.data()!);
    if (playlist.collaboratorIds.contains(uid)) return;

    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: uid,
      action: 'joined',
      target: playlist.name,
      timestamp: DateTime.now(),
    );

    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .update({
          'collaboratorIds': FieldValue.arrayUnion([uid]),
          'activityFeed': FieldValue.arrayUnion([event.toJson()]),
        });
  }

  Future<void> leaveCollaborativePlaylist(String playlistId) async {
    final user = _auth.currentUser;
    final uid = user?.uid ?? 'mock_user_123';

    final index = _collaborativePlaylists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;

    final playlist = _collaborativePlaylists[index];
    if (playlist.creatorId == uid) {
      throw Exception('The creator must delete this playlist instead.');
    }

    final event = ActivityEvent(
      id: _uuid.v4(),
      userId: uid,
      action: 'left',
      target: playlist.name,
      timestamp: DateTime.now(),
    );

    _collaborativePlaylists.removeAt(index);
    notifyListeners();

    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .update({
          'collaboratorIds': FieldValue.arrayRemove([uid]),
          'activityFeed': FieldValue.arrayUnion([event.toJson()]),
        });
  }

  Future<void> deleteCollaborativePlaylist(String playlistId) async {
    final index = _collaborativePlaylists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _collaborativePlaylists.removeAt(index);
      notifyListeners();
    }

    await _firestore
        .collection('collaborative_playlists')
        .doc(playlistId)
        .delete();
  }
}

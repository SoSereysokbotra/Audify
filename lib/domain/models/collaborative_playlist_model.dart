import 'package:cloud_firestore/cloud_firestore.dart';

class CollaborativeSong {
  final String songId;
  final String addedBy; // User ID
  final DateTime addedAt;

  CollaborativeSong({
    required this.songId,
    required this.addedBy,
    required this.addedAt,
  });

  Map<String, dynamic> toJson() => {
    'songId': songId,
    'addedBy': addedBy,
    'addedAt': Timestamp.fromDate(addedAt),
  };

  factory CollaborativeSong.fromJson(Map<String, dynamic> json) {
    final addedAtRaw = json['addedAt'];
    DateTime parsedDate;
    if (addedAtRaw is Timestamp) {
      parsedDate = addedAtRaw.toDate();
    } else {
      parsedDate = DateTime.parse(addedAtRaw.toString());
    }

    return CollaborativeSong(
      songId: json['songId'] as String,
      addedBy: json['addedBy'] as String,
      addedAt: parsedDate,
    );
  }
}

class ActivityEvent {
  final String id;
  final String userId;
  final String action; // e.g., 'added', 'removed', 'created'
  final String target; // e.g., 'Blinding Lights'
  final DateTime timestamp;

  ActivityEvent({
    required this.id,
    required this.userId,
    required this.action,
    required this.target,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'action': action,
    'target': target,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory ActivityEvent.fromJson(Map<String, dynamic> json) {
    final timestampRaw = json['timestamp'];
    DateTime parsedDate;
    if (timestampRaw is Timestamp) {
      parsedDate = timestampRaw.toDate();
    } else {
      parsedDate = DateTime.parse(timestampRaw.toString());
    }

    return ActivityEvent(
      id: json['id'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      target: json['target'] as String,
      timestamp: parsedDate,
    );
  }
}

class CollaborativePlaylistModel {
  final String id;
  final String name;
  final String description;
  final String coverUrl;
  final String creatorId;
  final List<String> collaboratorIds;
  final String privacy;
  final List<CollaborativeSong> songs;
  final List<ActivityEvent> activityFeed;

  CollaborativePlaylistModel({
    required this.id,
    required this.name,
    required this.description,
    required this.coverUrl,
    required this.creatorId,
    required this.collaboratorIds,
    required this.privacy,
    required this.songs,
    required this.activityFeed,
  });

  CollaborativePlaylistModel copyWith({
    String? name,
    String? description,
    String? coverUrl,
    List<String>? collaboratorIds,
    String? privacy,
    List<CollaborativeSong>? songs,
    List<ActivityEvent>? activityFeed,
  }) {
    return CollaborativePlaylistModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      creatorId: creatorId,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
      privacy: privacy ?? this.privacy,
      songs: songs ?? this.songs,
      activityFeed: activityFeed ?? this.activityFeed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'coverUrl': coverUrl,
    'creatorId': creatorId,
    'collaboratorIds': collaboratorIds,
    'privacy': privacy,
    'songs': songs.map((s) => s.toJson()).toList(),
    'activityFeed': activityFeed.map((a) => a.toJson()).toList(),
  };

  factory CollaborativePlaylistModel.fromJson(Map<String, dynamic> json) {
    return CollaborativePlaylistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      coverUrl: json['coverUrl'] as String,
      creatorId: json['creatorId'] as String,
      collaboratorIds: List<String>.from(json['collaboratorIds'] ?? []),
      privacy: json['privacy'] as String? ?? 'Public',
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map(
                (e) => CollaborativeSong.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      activityFeed:
          (json['activityFeed'] as List<dynamic>?)
              ?.map((e) => ActivityEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

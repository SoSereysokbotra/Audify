import 'package:cloud_firestore/cloud_firestore.dart';
import 'collaborative_playlist_model.dart'; // Reusing CollaborativeSong

class BlendModel {
  final String id;
  final String creatorId;
  final String? friendId;
  final double compatibilityScore; // e.g., 0.85 for 85%
  final List<String> sharedArtists;
  final List<String> sharedGenres;
  final String moodMatch;
  final List<CollaborativeSong> blendedSongs;
  final DateTime createdAt;

  BlendModel({
    required this.id,
    required this.creatorId,
    this.friendId,
    required this.compatibilityScore,
    required this.sharedArtists,
    required this.sharedGenres,
    required this.moodMatch,
    required this.blendedSongs,
    required this.createdAt,
  });

  BlendModel copyWith({
    String? friendId,
    double? compatibilityScore,
    List<String>? sharedArtists,
    List<String>? sharedGenres,
    String? moodMatch,
    List<CollaborativeSong>? blendedSongs,
  }) {
    return BlendModel(
      id: id,
      creatorId: creatorId,
      friendId: friendId ?? this.friendId,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      sharedArtists: sharedArtists ?? this.sharedArtists,
      sharedGenres: sharedGenres ?? this.sharedGenres,
      moodMatch: moodMatch ?? this.moodMatch,
      blendedSongs: blendedSongs ?? this.blendedSongs,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'creatorId': creatorId,
        'friendId': friendId,
        'compatibilityScore': compatibilityScore,
        'sharedArtists': sharedArtists,
        'sharedGenres': sharedGenres,
        'moodMatch': moodMatch,
        'blendedSongs': blendedSongs.map((s) => s.toJson()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory BlendModel.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime parsedDate;
    if (createdAtRaw is Timestamp) {
      parsedDate = createdAtRaw.toDate();
    } else {
      parsedDate = DateTime.parse(createdAtRaw.toString());
    }

    return BlendModel(
      id: json['id'] as String,
      creatorId: json['creatorId'] as String,
      friendId: json['friendId'] as String?,
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      sharedArtists: List<String>.from(json['sharedArtists'] ?? []),
      sharedGenres: List<String>.from(json['sharedGenres'] ?? []),
      moodMatch: json['moodMatch'] as String? ?? 'Vibing',
      blendedSongs: (json['blendedSongs'] as List<dynamic>?)
              ?.map((e) => CollaborativeSong.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: parsedDate,
    );
  }
}

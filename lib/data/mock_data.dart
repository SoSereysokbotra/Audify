import 'package:flutter/material.dart';
import '../../domain/models/song_model.dart';
import '../../domain/models/album_model.dart';
import '../../domain/models/radio_station_model.dart';
import '../../domain/models/artist_model.dart';
import '../../domain/models/playlist_model.dart';
import '../../domain/models/mix_model.dart';
import '../../domain/models/genre_model.dart';

class MockData {
  static const List<SongModel> recentlyPlayed = [
    SongModel(id: '1', title: 'ខ្យល់', artist: 'KAI', coverUrl: 'https://picsum.photos/id/1011/200/200'),
    SongModel(id: '2', title: 'បងក្រ', artist: 'Tena, YCN Rakhie', coverUrl: 'https://picsum.photos/id/1025/200/200'),
    SongModel(id: '3', title: 'ស្នេហ៍មួយសង - Speed Up', artist: 'SNAPPER', coverUrl: 'https://picsum.photos/id/1062/200/200'),
    SongModel(id: '4', title: 'Love Me Like You Do', artist: 'Ellie Goulding', coverUrl: 'https://picsum.photos/id/1074/200/200'),
  ];

  static const List<RadioStationModel> popularRadio = [
    RadioStationModel(
      id: 'r1',
      name: 'Sinn Sisamouth',
      featuredArtists: 'Sinn Sisamouth, Ros Serey Sothea, Pen Ran, So Savoeun...',
      coverUrls: [
        'https://picsum.photos/id/64/200/200',
        'https://picsum.photos/id/65/200/200',
        'https://picsum.photos/id/66/200/200',
      ],
      backgroundGradient: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    RadioStationModel(
      id: 'r2',
      name: 'Pich Solikah',
      featuredArtists: 'Pich Solikah, Suly Pheng, N Records...',
      coverUrls: [
        'https://picsum.photos/id/177/200/200',
        'https://picsum.photos/id/158/200/200',
        'https://picsum.photos/id/338/200/200',
      ],
      backgroundGradient: [Color(0xFFB19CD9), Color(0xFF9966FF)],
    ),
    RadioStationModel(
      id: 'r3',
      name: 'Modern Hits Radio',
      featuredArtists: 'Various modern artists',
      coverUrls: [
        'https://picsum.photos/id/449/200/200',
        'https://picsum.photos/id/450/200/200',
      ],
      backgroundGradient: [Color(0xFFFF6B6B), Color(0xFFFF8E72)],
    ),
  ];

  static const List<AlbumModel> popularAlbums = [
    AlbumModel(id: 'a1', title: 'Days of Gold', artist: 'Boy Playing Guitar', coverUrl: 'https://picsum.photos/id/145/400/400'),
    AlbumModel(id: 'a2', title: 'Cosmic Dreams', artist: 'Space Surfer', coverUrl: 'https://picsum.photos/id/103/400/400'),
    AlbumModel(id: 'a3', title: 'Midnight Drive', artist: 'Synthwave', coverUrl: 'https://picsum.photos/id/1071/400/400'),
    AlbumModel(id: 'a4', title: 'Acoustic Soul', artist: 'Raw Sessions', coverUrl: 'https://picsum.photos/id/1082/400/400'),
  ];

  static const List<ArtistModel> trendingArtists = [
    ArtistModel(id: 'ar1', name: 'The Weeknd', imageUrl: 'https://picsum.photos/id/1005/300/300'),
    ArtistModel(id: 'ar2', name: 'VannDa', imageUrl: 'https://picsum.photos/id/1027/300/300'),
    ArtistModel(id: 'ar3', name: 'Taylor Swift', imageUrl: 'https://picsum.photos/id/1012/300/300'),
    ArtistModel(id: 'ar4', name: 'Suly Pheng', imageUrl: 'https://picsum.photos/id/1035/300/300'),
    ArtistModel(id: 'ar5', name: 'G-Devith', imageUrl: 'https://picsum.photos/id/1043/300/300'),
  ];

  static const List<AlbumModel> newReleases = [
    AlbumModel(id: 'nr1', title: 'Starboy', artist: 'The Weeknd', coverUrl: 'https://picsum.photos/id/1050/400/400'),
    AlbumModel(id: 'nr2', title: 'Midnights', artist: 'Taylor Swift', coverUrl: 'https://picsum.photos/id/1060/400/400'),
    AlbumModel(id: 'nr3', title: 'Time', artist: 'VannDa', coverUrl: 'https://picsum.photos/id/1070/400/400'),
    AlbumModel(id: 'nr4', title: 'Lover', artist: 'Suly Pheng', coverUrl: 'https://picsum.photos/id/1080/400/400'),
  ];

  static const List<PlaylistModel> yourPlaylists = [
    PlaylistModel(id: 'p1', title: 'Chill Vibes', creator: 'You', coverUrl: 'https://picsum.photos/id/10/200/200'),
    PlaylistModel(id: 'p2', title: 'Workout', creator: 'You', coverUrl: 'https://picsum.photos/id/20/200/200'),
    PlaylistModel(id: 'p3', title: 'Khmer Indie', creator: 'Audify', coverUrl: 'https://picsum.photos/id/30/200/200'),
    PlaylistModel(id: 'p4', title: 'Lofi Beats', creator: 'Audify', coverUrl: 'https://picsum.photos/id/40/200/200'),
  ];

  static const List<MixModel> madeForYou = [
    MixModel(id: 'm1', title: 'Daily Mix 1', subtitle: 'KAI, Tena, Suly Pheng and more', coverUrl: 'https://picsum.photos/id/111/400/200', gradientStartHex: '0xFF4A00E0', gradientEndHex: '0xFF8E2DE2'),
    MixModel(id: 'm2', title: 'Chill Mix', subtitle: 'Relax and unwind to these gentle tunes', coverUrl: 'https://picsum.photos/id/222/400/200', gradientStartHex: '0xFF11998e', gradientEndHex: '0xFF38ef7d'),
    MixModel(id: 'm3', title: 'Discover Weekly', subtitle: 'New music based on your listening history', coverUrl: 'https://picsum.photos/id/333/400/200', gradientStartHex: '0xFFee0979', gradientEndHex: '0xFFff6a00'),
  ];

  static const List<GenreModel> browseGenres = [
    GenreModel(id: 'g1', title: 'Pop', colorHex: '0xFFE13300', imageUrl: 'https://picsum.photos/id/1015/200/200'),
    GenreModel(id: 'g2', title: 'Hip-Hop', colorHex: '0xFFBA5D07', imageUrl: 'https://picsum.photos/id/1025/200/200'),
    GenreModel(id: 'g3', title: 'Khmer Music', colorHex: '0xFFFFFFFF', imageUrl: 'https://picsum.photos/id/1035/200/200'),
    GenreModel(id: 'g4', title: 'Podcasts', colorHex: '0xFF27856A', imageUrl: 'https://picsum.photos/id/1045/200/200'),
    GenreModel(id: 'g5', title: 'Made For You', colorHex: '0xFF1E3264', imageUrl: 'https://picsum.photos/id/1055/200/200'),
    GenreModel(id: 'g6', title: 'New Releases', colorHex: '0xFFE8115B', imageUrl: 'https://picsum.photos/id/1065/200/200'),
    GenreModel(id: 'g7', title: 'Charts', colorHex: '0xFF8D67AB', imageUrl: 'https://picsum.photos/id/1075/200/200'),
    GenreModel(id: 'g8', title: 'Live Events', colorHex: '0xFF7358FF', imageUrl: 'https://picsum.photos/id/1084/200/200'),
  ];
}

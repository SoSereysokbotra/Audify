import 'package:flutter/material.dart';
import '../../domain/models/song_model.dart';
import '../../domain/models/album_model.dart';
import '../../domain/models/radio_station_model.dart';
import '../../domain/models/artist_model.dart';
import '../../domain/models/playlist_model.dart';
import '../../domain/models/mix_model.dart';
import '../../domain/models/genre_model.dart';

class MockData {
  static const List<SongModel> localSongs = [
    SongModel(
      id: '1',
      title: 'Back to Friends',
      artist: 'Sombr',
      coverUrl:
          'https://i.pinimg.com/736x/20/7a/b1/207ab15d7d5a91ad76e050959df4cb5a.jpg',
      localAudioPath: 'assets/audio/song-01_back_to_friends.mp3',
    ),
    SongModel(
      id: '2',
      title: 'The one that got away',
      artist: 'Katy Perry',
      coverUrl:
          'https://images.genius.com/9278c644f451b2497b31a976be2e8556.1000x1000x1.png',
      localAudioPath: 'assets/audio/song-02_the_one_that_got_away.mp3',
    ),
    SongModel(
      id: '3',
      title: 'Love Me Not',
      artist: 'Ravyn Lenae',
      coverUrl:
          'https://i.pinimg.com/736x/c9/ab/88/c9ab88de2a23ee4d34012a0c3ffe7244.jpg',
      localAudioPath: 'assets/audio/song-03_love_me_not.mp3',
    ),
    SongModel(
      id: '4',
      title: 'Multo',
      artist: 'Cup of Joe',
      coverUrl:
          'https://cdn-images.dzcdn.net/images/cover/09654ad0dc15a52a4c6d4f3994c0b3d2/1900x1900-000000-81-0-0.jpg',
      localAudioPath: 'assets/audio/song-04_multo.mp3',
    ),
    SongModel(
      id: '5',
      title: 'Joon Oun Tov Rok Ke',
      artist: 'Khmer Music',
      coverUrl: 'https://picsum.photos/id/1027/400/400',
      localAudioPath: 'assets/audio/song-05_joon_oun_tov_rok_ke.mp3',
    ),
    SongModel(
      id: '6',
      title: 'Maong 72',
      artist: 'Khmer Music',
      coverUrl: 'https://picsum.photos/id/1035/400/400',
      localAudioPath: 'assets/audio/song-06_maong_72.mp3',
    ),
    SongModel(
      id: '7',
      title: 'Let Her Go',
      artist: 'Passenger',
      coverUrl: 'https://picsum.photos/id/145/400/400',
      localAudioPath: 'assets/audio/song-07_let_her_go.mp3',
    ),
    SongModel(
      id: '8',
      title: "Here's Your Perfect",
      artist: 'Jamie Miller',
      coverUrl: 'https://picsum.photos/id/1074/400/400',
      localAudioPath: 'assets/audio/song-08_heres_your_perfect.mp3',
    ),
    SongModel(
      id: '9',
      title: "We Don't Talk Anymore",
      artist: 'Charlie Puth, Selena Gomez',
      coverUrl: 'https://picsum.photos/id/1060/400/400',
      localAudioPath: 'assets/audio/song-09_we_dont_talk_anymore.mp3',
    ),
    SongModel(
      id: '10',
      title: '7 Years',
      artist: 'Lukas Graham',
      coverUrl: 'https://picsum.photos/id/1082/400/400',
      localAudioPath: 'assets/audio/song-10_7_years.mp3',
    ),
    SongModel(
      id: '11',
      title: 'Impossible',
      artist: 'James Arthur',
      coverUrl: 'https://picsum.photos/id/1050/400/400',
      localAudioPath: 'assets/audio/song-11_impossible.mp3',
    ),
    SongModel(
      id: '12',
      title: 'Should Be Me',
      artist: 'Justin Bieber',
      coverUrl: 'https://picsum.photos/id/1012/400/400',
      localAudioPath: 'assets/audio/song-12_should_be_me.mp3',
    ),
    SongModel(
      id: '13',
      title: 'It Will Rain',
      artist: 'Bruno Mars',
      coverUrl: 'https://picsum.photos/id/1062/400/400',
      localAudioPath: 'assets/audio/song-13_it_will_rain.mp3',
    ),
    SongModel(
      id: '14',
      title: 'When I Was Your Man',
      artist: 'Bruno Mars',
      coverUrl: 'https://picsum.photos/id/1063/400/400',
      localAudioPath: 'assets/audio/song-14_when_i_was_your_man.mp3',
    ),
    SongModel(
      id: '15',
      title: 'Outside',
      artist: 'Calvin Harris, Ellie Goulding',
      coverUrl: 'https://picsum.photos/id/1064/400/400',
      localAudioPath: 'assets/audio/song-15_outside_slowed_reverb.mp3',
    ),
    SongModel(
      id: '16',
      title: 'Cinnamon Girl',
      artist: 'Lana Del Rey',
      coverUrl: 'https://picsum.photos/id/1065/400/400',
      localAudioPath: 'assets/audio/song-16_cinnamon_girl.mp3',
    ),
    SongModel(
      id: '17',
      title: "I'll Do It",
      artist: 'Heidi Montag',
      coverUrl: 'https://picsum.photos/id/1066/400/400',
      localAudioPath: 'assets/audio/song-17_ill_do_it_slowed_reverb.mp3',
    ),
    SongModel(
      id: '18',
      title: 'Margaret',
      artist: 'Lana Del Rey, Bleachers',
      coverUrl: 'https://picsum.photos/id/1067/400/400',
      localAudioPath: 'assets/audio/song-18_margaret.mp3',
    ),
    SongModel(
      id: '19',
      title: 'No. 1 Party Anthem',
      artist: 'Arctic Monkeys',
      coverUrl: 'https://picsum.photos/id/1068/400/400',
      localAudioPath: 'assets/audio/song-19_no_1_party_anthem.mp3',
    ),
    SongModel(
      id: '20',
      title: 'Men Arom',
      artist: 'Tena',
      coverUrl: 'https://picsum.photos/id/1069/400/400',
      localAudioPath: 'assets/audio/song-20_men_arom.mp3',
    ),
    SongModel(
      id: '21',
      title: 'Arom Pel Khouch Jit',
      artist: 'Chhorn Sovannareach',
      coverUrl: 'https://picsum.photos/id/1070/400/400',
      localAudioPath: 'assets/audio/song-21_arom_pel_khouch_jit.mp3',
    ),
  ];

  static List<SongModel> get recentlyPlayed =>
      localSongs.take(4).toList(growable: false);

  static const List<RadioStationModel> popularRadio = [
    RadioStationModel(
      id: 'r1',
      name: 'Khmer Favorites Radio',
      featuredArtists: 'ជូនអូនទៅរកគេ, ម៉ោង 72 and more',
      coverUrls: [
        'https://picsum.photos/id/64/200/200',
        'https://picsum.photos/id/65/200/200',
        'https://picsum.photos/id/66/200/200',
      ],
      backgroundGradient: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    RadioStationModel(
      id: 'r2',
      name: 'Heartbreak Radio',
      featuredArtists: 'Katy Perry, Jamie Miller, James Arthur...',
      coverUrls: [
        'https://picsum.photos/id/177/200/200',
        'https://picsum.photos/id/158/200/200',
        'https://picsum.photos/id/338/200/200',
      ],
      backgroundGradient: [Color(0xFFB19CD9), Color(0xFF9966FF)],
    ),
    RadioStationModel(
      id: 'r3',
      name: 'Acoustic Pop Radio',
      featuredArtists: 'Passenger, Lukas Graham, Charlie Puth...',
      coverUrls: [
        'https://picsum.photos/id/449/200/200',
        'https://picsum.photos/id/450/200/200',
      ],
      backgroundGradient: [Color(0xFFFF6B6B), Color(0xFFFF8E72)],
    ),
  ];

  static const List<AlbumModel> popularAlbums = [
    AlbumModel(
      id: 'a1',
      title: 'Days of Gold',
      artist: 'Boy Playing Guitar',
      coverUrl: 'https://picsum.photos/id/145/400/400',
    ),
    AlbumModel(
      id: 'a2',
      title: 'Cosmic Dreams',
      artist: 'Space Surfer',
      coverUrl: 'https://picsum.photos/id/103/400/400',
    ),
    AlbumModel(
      id: 'a3',
      title: 'Midnight Drive',
      artist: 'Synthwave',
      coverUrl: 'https://picsum.photos/id/1071/400/400',
    ),
    AlbumModel(
      id: 'a4',
      title: 'Acoustic Soul',
      artist: 'Raw Sessions',
      coverUrl: 'https://picsum.photos/id/1082/400/400',
    ),
  ];

  static const List<ArtistModel> trendingArtists = [
    ArtistModel(
      id: 'ar1',
      name: 'Sombr',
      imageUrl: 'https://picsum.photos/id/1005/300/300',
    ),
    ArtistModel(
      id: 'ar2',
      name: 'Katy Perry',
      imageUrl: 'https://picsum.photos/id/1027/300/300',
    ),
    ArtistModel(
      id: 'ar3',
      name: 'Cup of Joe',
      imageUrl: 'https://picsum.photos/id/1012/300/300',
    ),
    ArtistModel(
      id: 'ar4',
      name: 'Passenger',
      imageUrl: 'https://picsum.photos/id/1035/300/300',
    ),
    ArtistModel(
      id: 'ar5',
      name: 'Charlie Puth',
      imageUrl: 'https://picsum.photos/id/1043/300/300',
    ),
  ];

  static const List<AlbumModel> newReleases = [
    AlbumModel(
      id: 'nr1',
      title: 'Starboy',
      artist: 'The Weeknd',
      coverUrl: 'https://picsum.photos/id/1050/400/400',
    ),
    AlbumModel(
      id: 'nr2',
      title: 'Midnights',
      artist: 'Taylor Swift',
      coverUrl: 'https://picsum.photos/id/1060/400/400',
    ),
    AlbumModel(
      id: 'nr3',
      title: 'Time',
      artist: 'VannDa',
      coverUrl: 'https://picsum.photos/id/1070/400/400',
    ),
    AlbumModel(
      id: 'nr4',
      title: 'Lover',
      artist: 'Suly Pheng',
      coverUrl: 'https://picsum.photos/id/1080/400/400',
    ),
  ];

  static const List<PlaylistModel> yourPlaylists = [
    PlaylistModel(
      id: 'p1',
      title: 'Local Favorites',
      creator: 'You',
      coverUrl: 'https://picsum.photos/id/10/200/200',
    ),
    PlaylistModel(
      id: 'p2',
      title: 'Heartbreak Hits',
      creator: 'You',
      coverUrl: 'https://picsum.photos/id/20/200/200',
    ),
    PlaylistModel(
      id: 'p3',
      title: 'Khmer Music',
      creator: 'Audify',
      coverUrl: 'https://picsum.photos/id/30/200/200',
    ),
    PlaylistModel(
      id: 'p4',
      title: 'Acoustic Pop',
      creator: 'Audify',
      coverUrl: 'https://picsum.photos/id/40/200/200',
    ),
  ];

  static const List<MixModel> madeForYou = [
    MixModel(
      id: 'm1',
      title: 'Daily Mix 1',
      subtitle: 'KAI, Tena, Suly Pheng and more',
      coverUrl: 'https://picsum.photos/id/111/400/200',
      gradientStartHex: '0xFF4A00E0',
      gradientEndHex: '0xFF8E2DE2',
    ),
    MixModel(
      id: 'm2',
      title: 'Chill Mix',
      subtitle: 'Relax and unwind to these gentle tunes',
      coverUrl: 'https://picsum.photos/id/222/400/200',
      gradientStartHex: '0xFF11998e',
      gradientEndHex: '0xFF38ef7d',
    ),
    MixModel(
      id: 'm3',
      title: 'Discover Weekly',
      subtitle: 'New music based on your listening history',
      coverUrl: 'https://picsum.photos/id/333/400/200',
      gradientStartHex: '0xFFee0979',
      gradientEndHex: '0xFFff6a00',
    ),
  ];

  static const List<GenreModel> browseGenres = [
    GenreModel(
      id: 'g1',
      title: 'Pop',
      colorHex: '0xFFE13300',
      imageUrl: 'https://picsum.photos/id/1015/200/200',
    ),
    GenreModel(
      id: 'g2',
      title: 'Hip-Hop',
      colorHex: '0xFFBA5D07',
      imageUrl: 'https://picsum.photos/id/1025/200/200',
    ),
    GenreModel(
      id: 'g3',
      title: 'Khmer Music',
      colorHex: '0xFFFFFFFF',
      imageUrl: 'https://picsum.photos/id/1035/200/200',
    ),
    GenreModel(
      id: 'g4',
      title: 'Podcasts',
      colorHex: '0xFF27856A',
      imageUrl: 'https://picsum.photos/id/1045/200/200',
    ),
    GenreModel(
      id: 'g5',
      title: 'Made For You',
      colorHex: '0xFF1E3264',
      imageUrl: 'https://picsum.photos/id/1055/200/200',
    ),
    GenreModel(
      id: 'g6',
      title: 'New Releases',
      colorHex: '0xFFE8115B',
      imageUrl: 'https://picsum.photos/id/1065/200/200',
    ),
    GenreModel(
      id: 'g7',
      title: 'Charts',
      colorHex: '0xFF8D67AB',
      imageUrl: 'https://picsum.photos/id/1075/200/200',
    ),
    GenreModel(
      id: 'g8',
      title: 'Live Events',
      colorHex: '0xFF7358FF',
      imageUrl: 'https://picsum.photos/id/1084/200/200',
    ),
  ];
}

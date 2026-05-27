import 'package:flutter/material.dart';
import '../../domain/models/song_model.dart';
import '../../domain/models/album_model.dart';
import '../../domain/models/radio_station_model.dart';
import '../../domain/models/artist_model.dart';
import '../../domain/models/playlist_model.dart';
import '../../domain/models/mix_model.dart';
import '../../domain/models/genre_model.dart';
import '../../domain/models/podcast_model.dart';

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
      coverUrl:
          'https://i.ytimg.com/vi/N7tQqKupYDo/hq720.jpg?sqp=-oaymwE7CK4FEIIDSFryq4qpAy0IARUAAAAAGAElAADIQj0AgKJD8AEB-AH-CYAC0AWKAgwIABABGGUgYChaMA8=&rs=AOn4CLAkJgPxQ-cP-ZoRCRmhOjBwmf92kg',
      localAudioPath: 'assets/audio/song-05_joon_oun_tov_rok_ke.mp3',
    ),
    SongModel(
      id: '6',
      title: 'Maong 72',
      artist: 'Khmer Music',
      coverUrl: 'https://i.ytimg.com/vi/iDPSm-temwE/maxresdefault.jpg',
      localAudioPath: 'assets/audio/song-06_maong_72.mp3',
    ),
    SongModel(
      id: '7',
      title: 'Let Her Go',
      artist: 'Passenger',
      coverUrl: 'https://i.ytimg.com/vi/RBumgq5yVrA/maxresdefault.jpg',
      localAudioPath: 'assets/audio/song-07_let_her_go.mp3',
    ),
    SongModel(
      id: '8',
      title: "Here's Your Perfect",
      artist: 'Jamie Miller',
      coverUrl: 'https://i.ytimg.com/vi/77AByXC_02s/maxresdefault.jpg',
      localAudioPath: 'assets/audio/song-08_heres_your_perfect.mp3',
    ),
    SongModel(
      id: '9',
      title: "We Don't Talk Anymore",
      artist: 'Charlie Puth, Selena Gomez',
      coverUrl:
          'https://i1.sndcdn.com/artworks-zXopyj5CzVwSC8RM-k7RKDg-t500x500.jpg',
      localAudioPath: 'assets/audio/song-09_we_dont_talk_anymore.mp3',
    ),
    SongModel(
      id: '10',
      title: '7 Years',
      artist: 'Lukas Graham',
      coverUrl:
          'https://i.pinimg.com/236x/24/46/56/2446565338cee272c90cb038ac7794a3.jpg',
      localAudioPath: 'assets/audio/song-10_7_years.mp3',
    ),
    SongModel(
      id: '11',
      title: 'Impossible',
      artist: 'James Arthur',
      coverUrl:
          'https://i.pinimg.com/736x/6a/41/dd/6a41dde6e5c372d7a7c38f2ce4574a52.jpg',
      localAudioPath: 'assets/audio/song-11_impossible.mp3',
    ),
    SongModel(
      id: '12',
      title: 'Should Be Me',
      artist: 'Justin Bieber',
      coverUrl:
          'https://m.media-amazon.com/images/M/MV5BNmRkNTExYmYtNDQzMC00Mjk1LWJlMmMtZjYyMTcwMDAzYjYwXkEyXkFqcGc@._V1_.jpg',
      localAudioPath: 'assets/audio/song-12_should_be_me.mp3',
    ),
    SongModel(
      id: '13',
      title: 'It Will Rain',
      artist: 'Bruno Mars',
      coverUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSJpEluJ0mJpvc4vcnS2PaEFdJL2rX5QPglvw&s',
      localAudioPath: 'assets/audio/song-13_it_will_rain.mp3',
    ),
    SongModel(
      id: '14',
      title: 'When I Was Your Man',
      artist: 'Bruno Mars',
      coverUrl:
          'https://upload.wikimedia.org/wikipedia/en/6/62/Bruno-mars-when-i-was-your-man.jpg',
      localAudioPath: 'assets/audio/song-14_when_i_was_your_man.mp3',
    ),
    SongModel(
      id: '15',
      title: 'Outside',
      artist: 'Calvin Harris, Ellie Goulding',
      coverUrl:
          'https://i.pinimg.com/1200x/3b/b3/5c/3bb35c263b47c3aa07f9f7ad64c3b5d7.jpg',
      localAudioPath: 'assets/audio/song-15_outside_slowed_reverb.mp3',
    ),
    SongModel(
      id: '16',
      title: 'Cinnamon Girl',
      artist: 'Lana Del Rey',
      coverUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhcXuUdyMAWfV-evjy6G8iDNp2M0cgSfmXug&s',
      localAudioPath: 'assets/audio/song-16_cinnamon_girl.mp3',
    ),
    SongModel(
      id: '17',
      title: "I'll Do It",
      artist: 'Heidi Montag',
      coverUrl:
          'https://i.pinimg.com/736x/f4/7b/2e/f47b2e8ea4618a69120ce3de0c5d1071.jpg',
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
      coverUrl: 'https://i.ytimg.com/vi/ySfztM4CoDs/maxresdefault.jpg',
      localAudioPath: 'assets/audio/song-19_no_1_party_anthem.mp3',
    ),
    SongModel(
      id: '20',
      title: 'Men Arom',
      artist: 'Tena',
      coverUrl:
          'https://i.scdn.co/image/ab67616d00001e02f101fe3679006543615d8003',
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
        'https://i.pinimg.com/736x/8e/53/30/8e5330de74b1edacc3f64937756e2bee.jpg',
        'https://i.pinimg.com/736x/2c/25/9f/2c259fd87f3cc2046df0d55c83aa228a.jpg',
        'https://i.pinimg.com/736x/87/40/d9/8740d9f0b7ef38c601bad32025cf1ad1.jpg',
      ],
      backgroundGradient: [Color(0xFFFFD700), Color(0xFFFFA500)],
    ),
    RadioStationModel(
      id: 'r2',
      name: 'Heartbreak Radio',
      featuredArtists: 'Katy Perry, Jamie Miller, James Arthur...',
      coverUrls: [
        'https://images.genius.com/9278c644f451b2497b31a976be2e8556.1000x1000x1.png',
        'https://yt3.googleusercontent.com/Vd6eCo7GOLe6YGEK1TLtIw5snD3r47v2AF0vkkPcTGpDoFCty5QpdpWLQ1kxCuft8iCEeo1aMw=s900-c-k-c0x00ffffff-no-rj',
        'https://upload.wikimedia.org/wikipedia/en/a/ad/James_Arthur_-_Back_from_the_Edge.jpg',
      ],
      backgroundGradient: [Color(0xFFB19CD9), Color(0xFF9966FF)],
    ),
    RadioStationModel(
      id: 'r3',
      name: 'Acoustic Pop Radio',
      featuredArtists: 'Passenger, Lukas Graham, Charlie Puth...',
      coverUrls: [
        'https://i.scdn.co/image/ab67616100005174a340be7e0bd2c71a3f2ca9ce',
        'https://i.scdn.co/image/ab67616100005174a74cfdcc8251c711227bb0e5',
      ],
      backgroundGradient: [Color(0xFFFF6B6B), Color(0xFFFF8E72)],
    ),
  ];

  static const List<AlbumModel> popularAlbums = [
    AlbumModel(
      id: 'a1',
      title: 'Days of Gold',
      artist: 'Boy Playing Guitar',
      coverUrl:
          'https://i.pinimg.com/736x/e0/fa/cf/e0facfae91321fb09588ff1b49bed99c.jpg',
    ),
    AlbumModel(
      id: 'a2',
      title: 'Cosmic Dreams',
      artist: 'Space Surfer',
      coverUrl:
          'https://i.pinimg.com/736x/90/e3/b1/90e3b1345e72db0845bb5ae2064152b4.jpg',
    ),
    AlbumModel(
      id: 'a3',
      title: 'Midnight Drive',
      artist: 'Synthwave',
      coverUrl:
          'https://i.pinimg.com/1200x/06/df/af/06dfafefceb6dc9c122ceafcc733bf4b.jpg',
    ),
    AlbumModel(
      id: 'a4',
      title: 'Acoustic Soul',
      artist: 'Raw Sessions',
      coverUrl:
          'https://i.pinimg.com/1200x/a1/43/25/a14325eed297bddcbf45dcd5ea2aa750.jpg',
    ),
  ];

  static const List<ArtistModel> trendingArtists = [
    ArtistModel(
      id: 'ar1',
      name: 'Sombr',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/5/53/Sombr%2C_Islington_Academy%2C_London_%28cropped%29.jpg',
    ),
    ArtistModel(
      id: 'ar2',
      name: 'Katy Perry',
      imageUrl:
          'https://deadline.com/wp-content/uploads/2024/02/katy-perry-american-idol.jpg',
    ),
    ArtistModel(
      id: 'ar3',
      name: 'Cup of Joe',
      imageUrl:
          'https://yt3.googleusercontent.com/Bh9-8_9hC8UYAVih3G43dF2k4Xf0fFB4b6ydZERAURYKoIV3O6Gi3oHIIdo59xKgUbczuz4V=s900-c-k-c0x00ffffff-no-rj',
    ),
    ArtistModel(
      id: 'ar4',
      name: 'Passenger',
      imageUrl:
          'https://www.liveabout.com/thmb/Mh77rJFz_C6UdUTmYPDZEJcqUEo=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-136282985-a9824a2e0c4941b8b80185f57d69f6e4.jpg',
    ),
    ArtistModel(
      id: 'ar5',
      name: 'Charlie Puth',
      imageUrl:
          'https://i.pinimg.com/736x/e6/32/d5/e632d5e486c14efde36c86bc54e89d59.jpg',
    ),
  ];

  static const List<AlbumModel> newReleases = [
    AlbumModel(
      id: 'nr1',
      title: 'Starboy',
      artist: 'The Weeknd',
      coverUrl:
          'https://media.newyorker.com/photos/5b16cfe87018915289e3cb28/master/pass/StFelix-Charlie-Puth.jpg',
    ),
    AlbumModel(
      id: 'nr2',
      title: 'Midnights',
      artist: 'Taylor Swift',
      coverUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKot_PzzDBxuuM7w9BkFJnE6i6tR75bly6eg&s',
    ),
    AlbumModel(
      id: 'nr3',
      title: 'Time',
      artist: 'VannDa',
      coverUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTP9gcKFkzs_PWG1mk5o2ZLbTSi64DqSQgHtw&s',
    ),
    AlbumModel(
      id: 'nr4',
      title: 'Lover',
      artist: 'Suly Pheng',
      coverUrl: 'https://i.audiomack.com/suly-pheng/ad2cdefc0f.webp?width=456',
    ),
  ];

  static const List<PlaylistModel> yourPlaylists = [
    PlaylistModel(
      id: 'p1',
      title: 'Local Favorites',
      creator: 'You',
      coverUrl:
          'https://i.pinimg.com/1200x/86/33/75/863375de702f6f28a2c4e70603ff7ba7.jpg',
    ),
    PlaylistModel(
      id: 'p2',
      title: 'Heartbreak Hits',
      creator: 'You',
      coverUrl:
          'https://i.pinimg.com/736x/17/ef/ba/17efba17266b3b5bf6ab96b2415daa9b.jpg',
    ),
    PlaylistModel(
      id: 'p3',
      title: 'Khmer Music',
      creator: 'Audify',
      coverUrl:
          'https://i.pinimg.com/736x/17/ef/ba/17efba17266b3b5bf6ab96b2415daa9b.jpg',
    ),
    PlaylistModel(
      id: 'p4',
      title: 'Acoustic Pop',
      creator: 'Audify',
      coverUrl:
          'https://i.pinimg.com/736x/15/56/72/1556725fd4f0784b7ebf8a7a8b3a0b6f.jpg',
    ),
  ];

  static const List<MixModel> madeForYou = [
    MixModel(
      id: 'm1',
      title: 'Daily Mix 1',
      subtitle: 'KAI, Tena, Suly Pheng and more',
      coverUrl:
          'https://i.pinimg.com/736x/2e/dd/00/2edd00dbb256d425cbb9a269b7899586.jpg',
      gradientStartHex: '0xFF4A00E0',
      gradientEndHex: '0xFF8E2DE2',
    ),
    MixModel(
      id: 'm2',
      title: 'Chill Mix',
      subtitle: 'Relax and unwind to these gentle tunes',
      coverUrl:
          'https://i.pinimg.com/736x/22/13/9e/22139e119cbaf197138ac63325e5da1b.jpg',
      gradientStartHex: '0xFF11998e',
      gradientEndHex: '0xFF38ef7d',
    ),
    MixModel(
      id: 'm3',
      title: 'Discover Weekly',
      subtitle: 'New music based on your listening history',
      coverUrl:
          'https://i.pinimg.com/1200x/cd/36/b9/cd36b922115d150bd13ec1988f135091.jpg',
      gradientStartHex: '0xFFee0979',
      gradientEndHex: '0xFFff6a00',
    ),
  ];

  static const List<GenreModel> browseGenres = [
    GenreModel(
      id: 'g1',
      title: 'Pop',
      colorHex: '0xFFE13300',
      imageUrl:
          'https://i.pinimg.com/1200x/d5/81/71/d58171e2b49edf5ac2c2f9ab36f11d9d.jpg',
    ),
    GenreModel(
      id: 'g2',
      title: 'Hip-Hop',
      colorHex: '0xFFBA5D07',
      imageUrl:
          'https://i.pinimg.com/736x/52/5e/4e/525e4e1024fd9af6172ad9d42c06498e.jpg',
    ),
    GenreModel(
      id: 'g3',
      title: 'Khmer Music',
      colorHex: '0xFFFFFFFF',
      imageUrl:
          'https://i.pinimg.com/736x/1b/27/25/1b2725a953afd02429bafc3bdbecd707.jpg',
    ),
    GenreModel(
      id: 'g4',
      title: 'Podcasts',
      colorHex: '0xFF27856A',
      imageUrl:
          'https://i.pinimg.com/736x/ed/b0/72/edb072f1f8bde61ae3996cb05d8bf876.jpg',
    ),
    GenreModel(
      id: 'g5',
      title: 'Made For You',
      colorHex: '0xFF1E3264',
      imageUrl:
          'https://i.pinimg.com/1200x/86/33/75/863375de702f6f28a2c4e70603ff7ba7.jpg',
    ),
    GenreModel(
      id: 'g6',
      title: 'New Releases',
      colorHex: '0xFFE8115B',
      imageUrl:
          'https://i.pinimg.com/1200x/e3/c5/55/e3c55503141dfa4a0589939e90e8676a.jpg',
    ),
    GenreModel(
      id: 'g7',
      title: 'Charts',
      colorHex: '0xFF8D67AB',
      imageUrl:
          'https://i.pinimg.com/736x/d2/fa/24/d2fa243e10fdd57fe416e168d3a457e9.jpg',
    ),
    GenreModel(
      id: 'g8',
      title: 'Live Events',
      colorHex: '0xFF7358FF',
      imageUrl:
          'https://i.pinimg.com/736x/7b/ab/2d/7bab2d0f6e4eb929c4097b4b9935756a.jpg',
    ),
  ];

  static const List<ArtistModel> mockIdols = [
    ArtistModel(
      id: 'idol1',
      name: 'Taylor Swift',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQKot_PzzDBxuuM7w9BkFJnE6i6tR75bly6eg&s',
    ),
    ArtistModel(
      id: 'idol2',
      name: 'VannDa',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTP9gcKFkzs_PWG1mk5o2ZLbTSi64DqSQgHtw&s',
    ),
    ArtistModel(
      id: 'idol3',
      name: 'Sombr',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/5/53/Sombr%2C_Islington_Academy%2C_London_%28cropped%29.jpg',
    ),
    ArtistModel(
      id: 'idol4',
      name: 'Katy Perry',
      imageUrl:
          'https://deadline.com/wp-content/uploads/2024/02/katy-perry-american-idol.jpg',
    ),
    ArtistModel(
      id: 'idol5',
      name: 'The Weeknd',
      imageUrl:
          'https://media.newyorker.com/photos/5b16cfe87018915289e3cb28/master/pass/StFelix-Charlie-Puth.jpg',
    ),
    ArtistModel(
      id: 'idol6',
      name: 'Suly Pheng',
      imageUrl: 'https://i.audiomack.com/suly-pheng/ad2cdefc0f.webp?width=456',
    ),
    ArtistModel(
      id: 'idol7',
      name: 'Cup of Joe',
      imageUrl:
          'https://yt3.googleusercontent.com/Bh9-8_9hC8UYAVih3G43dF2k4Xf0fFB4b6ydZERAURYKoIV3O6Gi3oHIIdo59xKgUbczuz4V=s900-c-k-c0x00ffffff-no-rj',
    ),
    ArtistModel(
      id: 'idol8',
      name: 'Passenger',
      imageUrl:
          'https://www.liveabout.com/thmb/Mh77rJFz_C6UdUTmYPDZEJcqUEo=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/GettyImages-136282985-a9824a2e0c4941b8b80185f57d69f6e4.jpg',
    ),
    ArtistModel(
      id: 'idol9',
      name: 'Charlie Puth',
      imageUrl:
          'https://i.pinimg.com/736x/e6/32/d5/e632d5e486c14efde36c86bc54e89d59.jpg',
    ),
    ArtistModel(
      id: 'idol10',
      name: 'Bruno Mars',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/en/6/62/Bruno-mars-when-i-was-your-man.jpg',
    ),
    ArtistModel(
      id: 'idol11',
      name: 'Lana Del Rey',
      imageUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhcXuUdyMAWfV-evjy6G8iDNp2M0cgSfmXug&s',
    ),
    ArtistModel(
      id: 'idol12',
      name: 'Justin Bieber',
      imageUrl:
          'https://m.media-amazon.com/images/M/MV5BNmRkNTExYmYtNDQzMC00Mjk1LWJlMmMtZjYyMTcwMDAzYjYwXkEyXkFqcGc@._V1_.jpg',
    ),
  ];

  static const List<PodcastModel> podcasts = [
    PodcastModel(
      id: 'pod_nacht',
      title: 'nacht',
      category: 'Music',
      coverUrl:
          'https://i.pinimg.com/736x/22/13/9e/22139e119cbaf197138ac63325e5da1b.jpg',
    ),
    PodcastModel(
      id: 'pod_mj',
      title: 'Michael Jackson A Capella',
      category: 'Music',
      coverUrl:
          'https://i.pinimg.com/1200x/a1/43/25/a14325eed297bddcbf45dcd5ea2aa750.jpg',
    ),
    PodcastModel(
      id: 'pod_more_music',
      title: 'More in Music',
      category: 'Music',
      coverUrl: '',
      isCategoryTile: true,
    ),
    PodcastModel(
      id: 'pod_rotten_mango',
      title: 'Rotten Mango',
      category: 'True Crime',
      coverUrl:
          'https://i.pinimg.com/1200x/e3/c5/55/e3c55503141dfa4a0589939e90e8676a.jpg',
    ),
    PodcastModel(
      id: 'pod_anything_goes',
      title: 'anything goes with emma chamberlain',
      category: 'Comedy',
      coverUrl:
          'https://i.pinimg.com/736x/ed/b0/72/edb072f1f8bde61ae3996cb05d8bf876.jpg',
    ),
    PodcastModel(
      id: 'pod_more_comedy',
      title: 'More in Comedy',
      category: 'Comedy',
      coverUrl: '',
      isCategoryTile: true,
    ),
    PodcastModel(
      id: 'pod_atomic_habits',
      title: 'Atomic Habits',
      category: 'Books',
      coverUrl:
          'https://m.media-amazon.com/images/I/81F90H7hnML._UF1000,1000_QL80_.jpg',
    ),
    PodcastModel(
      id: 'pod_nepali_story',
      title: 'Nepali Audiobook Series',
      category: 'Books',
      coverUrl:
          'https://i.pinimg.com/736x/1b/27/25/1b2725a953afd02429bafc3bdbecd707.jpg',
    ),
    PodcastModel(
      id: 'pod_more_books',
      title: 'More in Books',
      category: 'Books',
      coverUrl: '',
      isCategoryTile: true,
    ),
    PodcastModel(
      id: 'pod_ted_daily',
      title: 'TED Talks Daily',
      category: 'Education',
      coverUrl:
          'https://i.pinimg.com/736x/d2/fa/24/d2fa243e10fdd57fe416e168d3a457e9.jpg',
    ),
    PodcastModel(
      id: 'pod_good_people',
      title: 'Hello Good People',
      category: 'Business',
      coverUrl:
          'https://i.pinimg.com/736x/8e/53/30/8e5330de74b1edacc3f64937756e2bee.jpg',
    ),
    PodcastModel(
      id: 'pod_more_business',
      title: 'More in Business',
      category: 'Business',
      coverUrl: '',
      isCategoryTile: true,
    ),
  ];
}

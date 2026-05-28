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
      lyrics: '''Touch my body tender
'Cause the feeling makes me weak
Kicking off the covers
I see the ceiling, while you're looking down at me
How can we go back to being friends
When we just shared a bed?
How can you look at me and pretend
I'm someone you've never met?
It was last December
You were layin' on my chest
I still remember
I was scared to take a breath, didn't want you to move your head
How can we go back to being friends
When we just shared a bed? (Yeah)
How can you look at me and pretend
I'm someone you've never met?
The devil in your eyes
Won't deny the lies
You've sold, I'm holding on too tight
While you let go, this is casual
How can we go back to being friends
When we just shared a bed? (Yeah)
How can you look at me and pretend
I'm someone you've never met?
How can we go back to being friends
When we just shared a bed? (Yeah)
How can you look at me and pretend
I'm someone you've never met?
I'm someone you've never met
Oh yeah''',
    ),
    SongModel(
      id: '2',
      title: 'The one that got away',
      artist: 'Katy Perry',
      coverUrl:
          'https://images.genius.com/9278c644f451b2497b31a976be2e8556.1000x1000x1.png',
      localAudioPath: 'assets/audio/song-02_the_one_that_got_away.mp3',
      lyrics: '''[00:03.000] Summer after high school when we first met
[00:07.000] We make out in your Mustang to Radiohead
[00:11.000] And on my 18th birthday we got matching tattoos
[00:19.000] Used to steal your parents' liquor and climb to the roof
[00:23.000] Talk about our future like we had a clue
[00:27.000] Never planned that one day. I'd be losing you
[00:33.000] In another life
[00:37.000] I would be your girl
[00:41.000] We keep all our promises
[00:44.000] Be us against the world
[00:49.000] In another life
[00:53.000] I would make you stay
[00:56.000] So I don't have to say
[00:59.000] You were the one that got away
[01:04.000] The one that got away
[01:09.000] I was June and you were my Johnny Cash
[01:12.000] Never one without the other we made a pact
[01:16.000] Sometimes when I miss you
[01:18.000] I put those records on
[01:24.000] Someone said you had your tattoo removed
[01:28.000] Saw you downtown singing the blues
[01:32.000] Its time to face the music
[01:34.000] I'm no longer your muse
[01:38.000] In another life
[01:42.000] I would be your girl
[01:46.000] We keep all our promises
[01:50.000] Be us against the world
[01:54.000] In another life
[01:58.000] I would make you stay
[02:02.000] So I don't have to say
[02:05.000] You were the one that got away
[02:10.000] The one that got away
[02:12.000] The o-o-o-o-o-o-one
[02:13.000] The o-o-o-o-o-o-one
[02:13.000] The o-o-o-o-o-o-one
[02:14.000] The one that got away
[02:14.000] I'm falling for you like dominoes
[02:16.000] From the top of the hundredth floor
[02:19.000] Look out below Geronimo
[02:20.000] Tryin' to get behind the closed doors to your soul
[02:24.000] Why'd you have to end the show
[02:26.000] We had such a beautiful plot
[02:27.000] There was still more story to go
[02:31.000] Now look, I'm not insinuating that
[02:35.000] You're some type of fair weather player
[02:39.000] But even if the whole world falls over
[02:45.000] I wouldn't be aware of a glacier
[02:47.000] I just wanna see you wake up
[02:50.000] Doing your hair in the mirror with your makeup
[02:55.000] Then, maybe in the next lifetime we could make up
[03:01.000] In another life
[03:02.000] I would be your girl
[03:05.000] We keep all our promises
[03:09.000] Be us against the world
[03:13.000] In another life
[03:17.000] I would make you stay
[03:21.000] So I don't have to say
[03:24.000] You were the one that got away
[03:29.000] The one that got away
[03:31.000] The o- o- o- o- o- one
[03:37.000] The o- o- o- o- o- one
[03:41.000] The o- o- o- o- o- one
[03:45.000] In another life
[03:49.000] I would make you stay
[03:53.000] So I don’t have to say
[03:56.000] You were the one that got away
[04:01.000] The one that got away''',
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
      lyrics: '''[00:26.000] well you only need the light when it's burning low only miss the sun when it starts to snow only know you love her when you let her go
[00:39.000] only know you've been high when you're feeling low only hate the road when you're missing home only know you love her when you let her go
[00:52.000] and you let her go
[01:05.000] staring at the bottom of your claws hoping one day you'll make a dream last
[01:11.000] but dreams come slow and they go so fast you see when you close your eyes maybe
[01:21.000] one day you'll understand why everything you touch surely dies
[01:29.000] but you only need the light when it's burning low only miss the sun when it starts to snow only know you love her when you let her go
[01:49.000] only know you love her when you let her go staring at the ceiling in the dark same old empty
[02:00.000] feeling in your heart cause love comes slow and it goes so
[02:05.000] fast we see you when you fall asleep but never to touch and
[02:13.000] never to keep courts you love to too much and you dive too deep
[02:33.000] only know you've been high when you're feeling low
[02:37.000] only hate the road when you're missing home only know you'll love her when you let her go
[02:55.000] oh
[03:12.000] cause you only need the light when it's running low only miss the sun when it starts to snow only know you love her when you let her go
[03:25.000] only know you've been high when you feel alone only hate the road when you're missing home
[03:41.000] only miss the sun when it starts to snow only know you love her when you let her go
[03:51.000] only know you've been high when you're feeling low only hate the road when you're missing home only know you love her when you let her go
[04:06.000] and you let her go you let her go''',
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
      lyrics: '''[00:04.000] We don't talk anymore
[00:04.000] We don't talk anymore
[00:04.000] We don't talk anymore like we used to do
[00:11.000] We don't love anymore
[00:11.000] What was all of it for
[00:11.000] Oh, we don't talk anymore like we used to do
[00:18.000] I just heard you found the one you've been looking
[00:26.000] You've been looking for
[00:26.000] I wish I would have known that wasn't me
[00:33.000] 'Cause even after all this time I still wonder
[00:33.000] Why I can't move on just the way you did so easily
[00:41.000] Don't want to know
[00:41.000] Kind of dress you're wearing tonight
[00:41.000] If he's holding on to you so tight
[00:48.000] The way I did before
[00:48.000] I overdosed
[00:48.000] Should have known your love was a game
[00:55.000] Now I can't get you out of my brain
[00:55.000] Oh, it's such a shame
[00:55.000] We don't talk anymore
[01:03.000] We don't talk anymore
[01:03.000] We don't talk anymore like we used to do
[01:12.000] We don't love anymore
[01:12.000] What was all of it for
[01:12.000] We don't talk anymore like we used to do
[01:21.000] I just hope you're lying next to somebody
[01:21.000] Who knows how to love you like me
[01:21.000] There must be a good reason that you're gone
[01:30.000] Every now and then I think you might want to come show up at your door
[01:30.000] But I'm just too afraid that I'll be wrong
[01:39.000] Don't want to know
[01:39.000] If you're looking into her eyes
[01:39.000] She's holding on to you so tight
[01:49.000] The way I did before
[01:49.000] I overdosed
[01:49.000] Should have known your love was a game
[01:55.000] Now I can't get you out of my brain
[01:55.000] Oh, it's such a shame
[01:55.000] We don't talk anymore
[02:03.000] We don't talk anymore
[02:03.000] We don't talk anymore like we used to do
[02:10.000] We don't love anymore
[02:10.000] What was all of it for
[02:10.000] We don't talk anymore like we used to do
[02:18.000] (Music)
[02:26.000] Like we used to do
[02:30.000] (Music)
[02:38.000] Don't want to know
[02:38.000] Kind of dress you're wearing tonight
[02:38.000] If he's giving it to you just right
[02:46.000] The way I did before
[02:46.000] I overdosed
[02:46.000] Should have known your love was a game
[02:53.000] Now I can't get you out of my brain
[02:53.000] Oh, it's such a shame
[02:53.000] We don't talk anymore
[03:00.000] We don't talk anymore
[03:00.000] We don't talk anymore like we used to do
[03:08.000] We don't love anymore
[03:08.000] What was all of it for
[03:08.000] Oh, we don't talk anymore like we used to do
[03:16.000] We don't talk
[03:18.000] (Music)
[03:23.000] Anymore
[03:23.000] We don't talk anymore
[03:23.000] Can't get you out
[03:32.000] Oh, it's such a shame
[03:32.000] We don't talk anymore''',
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
      lyrics: '''[00:00.000] (light music) (bright music)
[00:09.000] Look at what you've done
[00:09.000] Stand still, fallin' away from me
[00:17.000] When it takes so long
[00:17.000] Fire's out, what do you want to be
[00:24.000] I'm holdin' on
[00:24.000] Myself was never enough for me
[00:32.000] Gotta be so strong
[00:32.000] There's a power in what you do
[00:32.000] Now, every other day I'll be watching you
[00:39.000] Oh oh
[00:39.000] Show you what it feels like
[00:39.000] Now I'm on the outside
[00:48.000] Oh oh
[00:48.000] We did everything right, now I'm on the outside
[00:56.000] Oh oh
[00:56.000] I'll show you what it feels like
[00:56.000] Now I'm on the outside
[01:03.000] Oh oh
[01:03.000] We did everything right, now I'm on the outside
[01:24.000] Though you give me no reason
[01:24.000] For me to stay close to you
[01:24.000] Tell me what lovers do
[01:32.000] How are we still breathing
[01:32.000] It's never for us to choose
[01:32.000] I'll be the strength in you
[01:39.000] I'm holdin' on
[01:39.000] Myself was never enough for me
[01:47.000] Gotta be so strong
[01:47.000] There's a power in what you do
[01:47.000] Now, every other day I'll be watching you
[01:47.000] Oh oh
[01:56.000] Oh oh
[01:56.000] Show you what it feels like
[01:56.000] Now I'm on the outside
[02:03.000] Oh oh
[02:03.000] We did everything right, now I'm on the outside
[02:11.000] Oh oh
[02:11.000] Show you what it feels like
[02:11.000] Now I'm on the outside
[02:18.000] Oh oh
[02:18.000] We did everything right, now I'm on the outside
[02:18.000] (upbeat energetic music)
[02:39.000] (light music)
[02:39.000] I'll show you what it feels like
[02:39.000] Now I'm on the outside
[02:50.000] I'll show you what it feels like
[02:50.000] Show you what it feels like
[03:00.000] Now I'm on the outside
[03:00.000] We did everything right, now I'm on the outside
[03:13.000] (upbeat energetic music)''',
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

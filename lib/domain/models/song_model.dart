class SongModel {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String? localAudioPath;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    this.localAudioPath,
  });
}

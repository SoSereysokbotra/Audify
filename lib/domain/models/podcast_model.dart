class PodcastModel {
  final String id;
  final String title;
  final String category;
  final String coverUrl;
  final bool isCategoryTile;

  const PodcastModel({
    required this.id,
    required this.title,
    required this.category,
    required this.coverUrl,
    this.isCategoryTile = false,
  });
}

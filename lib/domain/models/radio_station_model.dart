import 'package:flutter/material.dart';

class RadioStationModel {
  final String id;
  final String name;
  final String featuredArtists;
  final List<String> coverUrls;
  final List<Color> backgroundGradient;

  const RadioStationModel({
    required this.id,
    required this.name,
    required this.featuredArtists,
    required this.coverUrls,
    required this.backgroundGradient,
  });
}

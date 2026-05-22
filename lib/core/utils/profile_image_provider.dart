import 'dart:io';

import 'package:flutter/material.dart';

bool isNetworkProfileImage(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return false;
  final uri = Uri.tryParse(imagePath);
  return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
}

ImageProvider? profileImageProvider(String? imagePath) {
  if (imagePath == null || imagePath.isEmpty) return null;
  if (isNetworkProfileImage(imagePath)) {
    return NetworkImage(imagePath);
  }
  return FileImage(File(imagePath));
}

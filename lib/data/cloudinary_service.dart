import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadException implements Exception {
  final String message;

  const CloudinaryUploadException(this.message);

  @override
  String toString() => message;
}

class CloudinaryService {
  CloudinaryService._();

  static final CloudinaryService instance = CloudinaryService._();

  static const _cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
  );
  static const _nextPublicCloudName = String.fromEnvironment(
    'NEXT_PUBLIC_CLOUDINARY_CLOUD_NAME',
    defaultValue: 'dg5grwcd5',
  );
  static const _cloudinaryApiKey = String.fromEnvironment('CLOUDINARY_API_KEY');
  static const _nextPublicApiKey = String.fromEnvironment(
    'NEXT_PUBLIC_CLOUDINARY_API_KEY',
    defaultValue: '197854366855442',
  );
  static const _apiSecret = String.fromEnvironment('CLOUDINARY_API_SECRET');
  static const _uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'ml_default',
  );

  static final _cloudName = _cloudinaryCloudName.isNotEmpty
      ? _cloudinaryCloudName
      : _nextPublicCloudName;
  static final _apiKey = _cloudinaryApiKey.isNotEmpty
      ? _cloudinaryApiKey
      : _nextPublicApiKey;

  Future<String> uploadProfileImage(String imagePath) async {
    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const CloudinaryUploadException('Selected image was not found.');
    }

    final uri = Uri.https(
      'api.cloudinary.com',
      '/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    if (_uploadPreset.isNotEmpty) {
      request.fields['upload_preset'] = _uploadPreset;
    } else {
      if (_apiSecret.isEmpty) {
        throw const CloudinaryUploadException(
          'Cloudinary API secret is missing. Run with --dart-define=CLOUDINARY_API_SECRET=your_secret or configure an unsigned upload preset.',
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const folder = 'audify_profiles';
      final signaturePayload = 'folder=$folder&timestamp=$timestamp$_apiSecret';
      final signature = sha1.convert(utf8.encode(signaturePayload)).toString();

      request.fields.addAll({
        'api_key': _apiKey,
        'folder': folder,
        'timestamp': timestamp.toString(),
        'signature': signature,
      });
    }

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final jsonBody = jsonDecode(body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = jsonBody['error'];
      final message = error is Map<String, dynamic>
          ? error['message']?.toString()
          : null;
      throw CloudinaryUploadException(
        message ?? 'Cloudinary upload failed. Please try again.',
      );
    }

    final secureUrl = jsonBody['secure_url']?.toString();
    if (secureUrl == null || secureUrl.isEmpty) {
      throw const CloudinaryUploadException(
        'Cloudinary did not return an image URL.',
      );
    }
    return secureUrl;
  }
}

import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/collaborative_store.dart';
import 'collaborative_playlist_screen.dart'; // We will create this next

class CreateCollaborativeScreen extends StatefulWidget {
  const CreateCollaborativeScreen({super.key});

  @override
  State<CreateCollaborativeScreen> createState() =>
      _CreateCollaborativeScreenState();
}

class _CreateCollaborativeScreenState extends State<CreateCollaborativeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _coverImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _createPlaylist() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final id = await CollaborativeStore.instance.createCollaborativePlaylist(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        coverUrl: 'https://picsum.photos/id/123/400/400',
      );

      if (!mounted) return;
      Navigator.pop(context); // Pop creation screen

      // Navigate to Collaborative Playlist Screen, passing autoShare=true
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CollaborativePlaylistScreen(playlistId: id, autoShare: true),
        ),
      );
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create Collaborative Playlist'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    image: _coverImage != null
                        ? DecorationImage(
                            image: FileImage(_coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _coverImage == null
                      ? const Icon(
                          CupertinoIcons.camera_fill,
                          size: 64,
                          color: Colors.white54,
                        )
                      : null,
                ),
              ),
            ).animate().fade().scale(
              duration: 400.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'My Playlist',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white24),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent),
                ),
              ),
            ).animate().fade(delay: 100.ms).slideY(),
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Description',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: InputBorder.none,
              ),
            ).animate().fade(delay: 200.ms).slideY(),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPlaylist,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.disabled,
                  disabledForegroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ).animate().fade(delay: 400.ms).slideY(),
          ],
        ),
      ),
    );
  }
}

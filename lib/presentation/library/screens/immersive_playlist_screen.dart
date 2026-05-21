import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ImmersivePlaylistScreen extends StatefulWidget {
  const ImmersivePlaylistScreen({Key? key}) : super(key: key);

  @override
  State<ImmersivePlaylistScreen> createState() => _ImmersivePlaylistScreenState();
}

class _ImmersivePlaylistScreenState extends State<ImmersivePlaylistScreen> {
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

  // Placeholder songs
  final List<Map<String, String>> _songs = [
    {"title": "Scott Street", "artist": "Phoebe Bridgers"},
    {"title": "Sweet", "artist": "Cigarettes After Sex"},
    {"title": "Fix You", "artist": "Coldplay"},
    {"title": "If I Had A Gun...", "artist": "Noel Gallagher's High Flying Birds"},
    {"title": "Somebody's Pleasure", "artist": "Aziz Hedra"},
    {"title": "Those Eyes", "artist": "New West"},
    {"title": "I Love You So", "artist": "The Walters"},
    {"title": "Cry", "artist": "Cigarettes After Sex"},
    {"title": "I Wanna Be Yours", "artist": "Arctic Monkeys"},
  ];

  int _currentIndex = 4; // Highlight "Somebody's Pleasure" by default

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _backgroundImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: \$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
            tooltip: "Change Background",
            onPressed: _pickImage,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Layer
          if (_backgroundImage != null)
            Image.file(
              _backgroundImage!,
              fit: BoxFit.cover,
            )
          else
            Image.network(
              'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&q=80', // Sunset placeholder
              fit: BoxFit.cover,
            ),
            
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          
          // Song List Layer
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                final isPlaying = index == _currentIndex;
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Album Art Placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.music_note, color: Colors.white54),
                        ),
                        const SizedBox(width: 16),
                        // Song Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song["title"]!,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isPlaying ? Colors.greenAccent : Colors.white,
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song["artist"]!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Animated EQ icon if playing
                        if (isPlaying)
                          const Icon(Icons.equalizer, color: Colors.greenAccent, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

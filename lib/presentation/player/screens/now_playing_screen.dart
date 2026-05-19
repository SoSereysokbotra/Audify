import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NowPlayingScreen extends StatefulWidget {
  final String title;
  final String artist;
  final String imagePath;

  const NowPlayingScreen({
    Key? key,
    this.title = "Unstable",
    this.artist = "Mr. Kitty",
    this.imagePath =
        "https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80", // Placeholder matching the vibe
  }) : super(key: key);

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final double _progress = 0.35; // Mock progress
  bool _isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Matches other screens
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Now Playing",
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              
              // Glowing Artwork
              Container(
                width: MediaQuery.of(context).size.width * 0.90,
                height: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.12),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Song Info Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border,
                        color: Colors.white54, size: 28),
                    onPressed: () {},
                  ),
                  Column(
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.artist,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white54,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: Colors.white54, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Progress Wave (Fake waveform)
              _buildFakeWaveform(),
              const SizedBox(height: 12),
              
              // Timers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("1:04",
                      style: AppTextStyles.helper
                          .copyWith(color: Colors.white54, fontSize: 12)),
                  Text("2:52",
                      style: AppTextStyles.helper
                          .copyWith(color: Colors.white54, fontSize: 12)),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle,
                        color: Colors.white54, size: 24),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 36),
                    onPressed: () {},
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                    },
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 4,
                          )
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white, size: 36),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat,
                        color: Colors.white54, size: 24),
                    onPressed: () {},
                  ),
                ],
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  // Generates a mock waveform that matches the provided design
  Widget _buildFakeWaveform() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          int barCount = 50;
          double spacing = 2.0;
          double barWidth = (constraints.maxWidth / barCount) - spacing;
          
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(barCount, (index) {
              // Creating a pseudo-random wave pattern
              double height;
              if (index % 10 == 0) height = 30;
              else if (index % 5 == 0) height = 24;
              else if (index % 3 == 0) height = 16;
              else if (index % 2 == 0) height = 10;
              else height = 6;
              
              // Smooth out edges slightly
              if (index < 5 || index > barCount - 5) {
                height = height * 0.5;
              }

              bool isPlayed = index < (barCount * _progress);
              return Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  color: isPlayed ? Colors.white : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

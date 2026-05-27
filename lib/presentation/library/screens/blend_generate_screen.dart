import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/collaborative_store.dart';
import 'blend_playlist_screen.dart'; // We will create this next

class BlendGenerateScreen extends StatefulWidget {
  final String blendId;

  const BlendGenerateScreen({super.key, required this.blendId});

  @override
  State<BlendGenerateScreen> createState() => _BlendGenerateScreenState();
}

class _BlendGenerateScreenState extends State<BlendGenerateScreen> {
  String _statusText = 'Analyzing your music taste...';

  @override
  void initState() {
    super.initState();
    _startGenerationProcess();
  }

  Future<void> _startGenerationProcess() async {
    try {
      // Fake delays for the cool UI animation
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _statusText = 'Comparing top artists...');

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => _statusText = 'Finding perfect matches...');

      // Actual backend call (Mock AI)
      final blend = await CollaborativeStore.instance.joinBlendAndGenerate(widget.blendId);

      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      
      // Navigate to the final blend screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BlendPlaylistScreen(blend: blend),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusText = 'Error generating blend: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing orb animation
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [AppColors.accent, Colors.transparent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 20,
                  ),
                ],
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), duration: 2.seconds)
                .fade(begin: 0.5, end: 1.0, duration: 2.seconds),
                
            const SizedBox(height: 64),
            Text(
              _statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fade().slideY(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/navigation_router.dart';
import '../widgets/custom_button.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.networkUrl(
            Uri.parse(
              "https://res.cloudinary.com/dg5grwcd5/video/upload/ac_none/v1779164874/PixVerse_V6_Image_Text_360P_Minimal_blackandwh_2_vdkvng.mp4",
            ),
          )
          ..initialize().then((_) {
            _controller.play();
            _controller.setLooping(true);
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Video
          Positioned.fill(
            child: _controller.value.isInitialized
                ? Transform.scale(
                    scale: 1.2, // Makes the background video larger
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _controller.value.size.width,
                          height: _controller.value.size.height,
                          child: VideoPlayer(_controller),
                        ),
                      ),
                    ),
                  )
                : Container(color: Colors.black), // Fallback while loading
          ),
          // Dark Overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 40,
                  ), // Push slightly down from the very top edge
                  AppMotionEntry(
                    child: const Icon(
                      Icons.music_note,
                      color: AppColors.primaryText,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppMotionEntry(
                    delay: const Duration(milliseconds: 120),
                    child: Text(
                      "Millions of songs.\nFree on Audify.",
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 36,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Spacer pushes the buttons to the bottom
                  const Spacer(),

                  AppMotionEntry(
                    delay: const Duration(milliseconds: 180),
                    child: CustomButton(
                      text: "Sign up free",
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      textColor: Colors.black,
                      onPressed: () {
                        NavigationRouter.navigateTo(
                          context,
                          const RegisterScreen(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppMotionEntry(
                    delay: const Duration(milliseconds: 240),
                    child: CustomButton(
                      text: "Log in",
                      isOutlined: true,
                      onPressed: () {
                        NavigationRouter.navigateTo(
                          context,
                          const LoginScreen(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24), // Some padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

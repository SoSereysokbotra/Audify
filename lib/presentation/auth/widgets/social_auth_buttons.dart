import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/dialog_utils.dart';
import '../../../data/audify_store.dart';
import '../../../data/social_auth_service.dart';
import '../../../main.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  Future<void> _handleSocialSignIn(
    BuildContext context,
    Future<UserCredential?> Function() signIn,
    String provider,
  ) async {
    DialogUtils.showLoadingDialog(context);
    try {
      final credential = await signIn();
      if (!context.mounted) return;
      DialogUtils.hideDialog(context);

      if (credential == null) return;

      AudifyStore.instance.addNotification(
        category: AudifyNotificationCategory.account,
        title: '$provider sign-in successful',
        message: 'Welcome to Audify.',
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthGate()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      DialogUtils.hideDialog(context);
      AudifyStore.instance.addNotification(
        category: AudifyNotificationCategory.account,
        title: '$provider sign-in problem',
        message: e.message ?? '$provider sign-in failed.',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '$provider sign-in failed.')),
      );
    } catch (_) {
      if (!context.mounted) return;
      DialogUtils.hideDialog(context);
      AudifyStore.instance.addNotification(
        category: AudifyNotificationCategory.account,
        title: '$provider sign-in problem',
        message: 'An unexpected sign-in error occurred.',
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$provider sign-in failed.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SocialButton(
          icon: const _GoogleLogo(),
          label: 'Continue with Google',
          onPressed: () => _handleSocialSignIn(
            context,
            SocialAuthService.instance.signInWithGoogle,
            'Google',
          ),
        ),
        const SizedBox(height: 12),
        _SocialButton(
          icon: const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 24),
          label: 'Continue with Facebook',
          onPressed: () => _handleSocialSignIn(
            context,
            SocialAuthService.instance.signInWithFacebook,
            'Facebook',
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: SizedBox(width: 24, height: 24, child: Center(child: icon)),
      label: Text(label, style: AppTextStyles.bodyLarge),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryText,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(22),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.18;
    final rect =
        Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const start = -0.05;
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, start, 1.45, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, start + 1.45, 1.25, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, start + 2.70, 1.18, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, start + 3.88, 1.65, false, paint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = strokeWidth;
    final midY = size.height * 0.52;
    canvas.drawLine(
      Offset(size.width * 0.52, midY),
      Offset(size.width * 0.88, midY),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

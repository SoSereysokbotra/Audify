import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SocialAuthService {
  SocialAuthService._();

  static final SocialAuthService instance = SocialAuthService._();

  bool _googleInitialized = false;

  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      return FirebaseAuth.instance.signInWithPopup(provider);
    }

    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize();
      _googleInitialized = true;
    }

    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw FirebaseAuthException(
        code: 'google-sign-in-unavailable',
        message: 'Google sign-in is not available on this device.',
      );
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      return FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }

      throw FirebaseAuthException(
        code: e.code.name,
        message: e.description ?? 'Google sign-in failed.',
      );
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    if (kIsWeb) {
      final provider = FacebookAuthProvider()
        ..addScope('email')
        ..addScope('public_profile');
      final credential = await FirebaseAuth.instance.signInWithPopup(provider);
      await _syncFacebookProfilePhoto(credential.user);
      return credential;
    }

    final result = await FacebookAuth.instance.login(
      permissions: const ['email', 'public_profile'],
    );

    switch (result.status) {
      case LoginStatus.success:
        final token = result.accessToken;
        if (token == null) {
          throw FirebaseAuthException(
            code: 'missing-facebook-token',
            message: 'Facebook did not return an access token.',
          );
        }

        final credential = FacebookAuthProvider.credential(token.tokenString);
        final userCredential = await FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        await _syncFacebookProfilePhoto(userCredential.user);
        return userCredential;
      case LoginStatus.cancelled:
        return null;
      case LoginStatus.operationInProgress:
        throw FirebaseAuthException(
          code: 'facebook-operation-in-progress',
          message: 'A Facebook sign-in operation is already in progress.',
        );
      case LoginStatus.failed:
        throw FirebaseAuthException(
          code: 'facebook-sign-in-failed',
          message: result.message ?? 'Facebook sign-in failed.',
        );
    }
  }

  Future<void> _syncFacebookProfilePhoto(User? user) async {
    if (user == null) return;

    final photoUrl = await _facebookProfilePhotoUrl();
    if (photoUrl == null || photoUrl.isEmpty || photoUrl == user.photoURL) {
      return;
    }

    await user.updatePhotoURL(photoUrl);
    await user.reload();
  }

  Future<String?> _facebookProfilePhotoUrl() async {
    try {
      final data = await FacebookAuth.instance.getUserData(
        fields: 'picture.width(500).height(500)',
      );
      final picture = data['picture'];
      if (picture is! Map) return null;

      final pictureData = picture['data'];
      if (pictureData is! Map) return null;

      return pictureData['url'] as String?;
    } catch (_) {
      return null;
    }
  }
}

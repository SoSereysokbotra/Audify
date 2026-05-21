import 'package:flutter/material.dart';
import '../motion/app_motion.dart';

class NavigationRouter {
  static void navigateTo(BuildContext context, Widget screen) {
    Navigator.push(context, AppMotion.route(screen));
  }

  static void navigateAndReplace(BuildContext context, Widget screen) {
    Navigator.pushReplacement(context, AppMotion.route(screen));
  }

  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}

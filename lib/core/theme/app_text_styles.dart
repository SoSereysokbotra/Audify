import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.3, color: AppColors.primaryText);
  static const TextStyle h2 = TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.4, color: AppColors.primaryText);
  static const TextStyle bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.primaryText);
  static const TextStyle bodySmall = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.secondaryText);
  static const TextStyle button = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black);
  static const TextStyle inputLabel = TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryText);
  static const TextStyle helper = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.secondaryText);
}

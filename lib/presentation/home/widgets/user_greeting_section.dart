import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UserGreetingSection extends StatelessWidget {
  const UserGreetingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                "N",
                style: AppTextStyles.h2.copyWith(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text("Welcome back, N", style: AppTextStyles.h2),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.primaryText),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

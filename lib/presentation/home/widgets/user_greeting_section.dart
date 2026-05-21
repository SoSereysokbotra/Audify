import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/motion/app_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/audify_store.dart';
import '../../main_layout/screens/settings_screen.dart';

class UserGreetingSection extends StatelessWidget {
  const UserGreetingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AudifyStore.instance,
      builder: (context, _) {
        final profile = AudifyStore.instance.profile;
        final firebaseName = FirebaseAuth.instance.currentUser?.displayName;
        final name = firebaseName?.trim().isNotEmpty == true
            ? firebaseName!
            : profile.displayName;
        final initial = name.trim().isEmpty
            ? '?'
            : name.trim()[0].toUpperCase();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.pinkAccent,
                  backgroundImage: profile.imagePath == null
                      ? null
                      : FileImage(File(profile.imagePath!)),
                  child: profile.imagePath == null
                      ? Text(
                          initial,
                          style: AppTextStyles.h2.copyWith(color: Colors.black),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Welcome back, $name",
                  style: AppTextStyles.h2,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: AppColors.primaryText,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    AppMotion.route(const SettingsScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

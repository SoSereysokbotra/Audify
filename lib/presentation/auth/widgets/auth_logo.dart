import 'package:flutter/material.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({super.key, this.size = 104});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: SizedBox.square(
          dimension: size,
          child: Transform.scale(
            scale: 1.65,
            child: Image.asset('assets/app_icon.png', fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

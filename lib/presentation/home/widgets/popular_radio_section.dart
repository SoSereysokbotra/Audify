import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/mock_data.dart';
import 'radio_card.dart';

class PopularRadioSection extends StatelessWidget {
  const PopularRadioSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Popular radio", style: AppTextStyles.h1),
              GestureDetector(
                onTap: () {},
                child: Text("See all", style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondaryText)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: MockData.popularRadio.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return RadioCard(station: MockData.popularRadio[index]);
            },
          ),
        ),
      ],
    );
  }
}

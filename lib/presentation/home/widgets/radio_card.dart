import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../domain/models/radio_station_model.dart';

class RadioCard extends StatelessWidget {
  final RadioStationModel station;

  const RadioCard({Key? key, required this.station}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opening radio station: ${station.name}")),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: station.backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.music_note, color: Colors.black, size: 20),
                  Text(
                    "RADIO",
                    style: AppTextStyles.helper.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Spacer(),
              // Overlapping circles logic
              SizedBox(
                height: 80,
                child: Stack(
                  children: [
                    for (int i = 0; i < station.coverUrls.length; i++)
                      Positioned(
                        left: i * 35.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: station.backgroundGradient.last, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              station.coverUrls[i],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                station.name,
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                station.featuredArtists,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.black87),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

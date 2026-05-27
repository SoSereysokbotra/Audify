import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BirthdayScreen extends StatefulWidget {
  final Function(DateTime) onContinue;

  const BirthdayScreen({super.key, required this.onContinue});

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {
  late DateTime _selectedDate;
  final DateTime _minimumDate = DateTime(1900, 1, 1);
  final DateTime _maximumDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Default to 18 years ago
    final now = DateTime.now();
    _selectedDate = DateTime(now.year - 18, now.month, now.day);
  }

  bool _isValidAge() {
    // Basic validation: Can't be born in the future or less than 5 years old
    final difference = DateTime.now().difference(_selectedDate).inDays;
    return difference > (365 * 5);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's your\nbirthday?",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "We use this to personalize your experience.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 60),

            // Birthday Picker
            Expanded(
              child: Center(
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      brightness: Brightness.dark,
                      primaryColor: AppColors.accent,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: _selectedDate,
                      minimumDate: _minimumDate,
                      maximumDate: _maximumDate,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isValidAge()
                    ? () => widget.onContinue(_selectedDate)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.surface,
                  disabledForegroundColor: Colors.white54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            if (!_isValidAge())
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    "You must be at least 5 years old.",
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

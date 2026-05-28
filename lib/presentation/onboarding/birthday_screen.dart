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
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  late final FixedExtentScrollController _yearController;
  late final FixedExtentScrollController _monthController;
  late final FixedExtentScrollController _dayController;

  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  final int _minimumYear = 1900;
  late final int _maximumYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _maximumYear = now.year;
    _selectedYear = now.year - 18;
    _selectedMonth = now.month;
    _selectedDay = now.day;

    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - _minimumYear,
    );
    _monthController = FixedExtentScrollController(
      initialItem: _selectedMonth - 1,
    );
    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
  }

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  DateTime get _selectedDate =>
      DateTime(_selectedYear, _selectedMonth, _selectedDay);

  int get _yearCount => _maximumYear - _minimumYear + 1;

  int get _daysInSelectedMonth =>
      DateTime(_selectedYear, _selectedMonth + 1, 0).day;

  bool _isValidAge() {
    final difference = DateTime.now().difference(_selectedDate).inDays;
    return difference > (365 * 5);
  }

  void _updateSelectedDate({
    int? year,
    int? month,
    int? day,
    bool jumpDayWheel = false,
  }) {
    setState(() {
      _selectedYear = year ?? _selectedYear;
      _selectedMonth = month ?? _selectedMonth;
      _selectedDay = day ?? _selectedDay;

      final maxDay = _daysInSelectedMonth;
      if (_selectedDay > maxDay) {
        _selectedDay = maxDay;
        if (jumpDayWheel) {
          _dayController.jumpToItem(maxDay - 1);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValidAge = _isValidAge();

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 430),
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 78,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        'SET BIRTHDAY',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                      Positioned(
                        right: 12,
                        child: IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white.withValues(alpha: 0.55),
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 34, 26, 30),
                  child: SizedBox(
                    height: 268,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.045),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _BirthdayWheel(
                                controller: _yearController,
                                itemCount: _yearCount,
                                selectedIndex: _selectedYear - _minimumYear,
                                labelForIndex: (index) =>
                                    '${_minimumYear + index}',
                                onSelectedItemChanged: (index) {
                                  _updateSelectedDate(
                                    year: _minimumYear + index,
                                    jumpDayWheel: true,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: _BirthdayWheel(
                                controller: _monthController,
                                itemCount: _months.length,
                                selectedIndex: _selectedMonth - 1,
                                labelForIndex: (index) => _months[index],
                                onSelectedItemChanged: (index) {
                                  _updateSelectedDate(
                                    month: index + 1,
                                    jumpDayWheel: true,
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: _BirthdayWheel(
                                controller: _dayController,
                                itemCount: _daysInSelectedMonth,
                                selectedIndex: _selectedDay - 1,
                                labelForIndex: (index) => '${index + 1}',
                                onSelectedItemChanged: (index) {
                                  _updateSelectedDate(day: index + 1);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: isValidAge
                          ? () => widget.onContinue(_selectedDate)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white24,
                        disabledForegroundColor: Colors.white54,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        'SUBMIT',
                        style: TextStyle(
                          color: isValidAge ? Colors.black : Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!isValidAge)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                    child: Text(
                      'You must be at least 5 years old.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BirthdayWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final int selectedIndex;
  final String Function(int index) labelForIndex;
  final ValueChanged<int> onSelectedItemChanged;

  const _BirthdayWheel({
    required this.controller,
    required this.itemCount,
    required this.selectedIndex,
    required this.labelForIndex,
    required this.onSelectedItemChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker.builder(
      scrollController: controller,
      itemExtent: 42,
      diameterRatio: 1.25,
      squeeze: 1.08,
      magnification: 1,
      useMagnifier: false,
      selectionOverlay: const SizedBox.shrink(),
      onSelectedItemChanged: onSelectedItemChanged,
      childCount: itemCount,
      itemBuilder: (context, index) {
        final distance = (index - selectedIndex).abs();
        final opacity = switch (distance) {
          0 => 1.0,
          1 => 0.64,
          2 => 0.35,
          _ => 0.18,
        };
        final fontSize = distance == 0 ? 24.0 : 18.0;

        return Center(
          child: Text(
            labelForIndex(index),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: opacity),
              fontSize: fontSize,
              fontWeight: distance == 0 ? FontWeight.w500 : FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        );
      },
    );
  }
}

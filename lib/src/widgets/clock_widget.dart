import 'dart:async';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Live digital clock (top-left) with a subtitle date line beneath it.
class ClockWidget extends StatefulWidget {
  const ClockWidget({super.key});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  static const _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
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

  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hour12 = _now.hour % 12 == 0 ? 12 : _now.hour % 12;
    final amPm = _now.hour < 12 ? 'AM' : 'PM';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$hour12:${_now.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontFamily: AppTypography.display,
                fontWeight: FontWeight.w700,
                fontSize: 56,
                height: 1,
                letterSpacing: -1.5,
                color: AppColors.textPrimary,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 5),
              child: Text(
                amPm,
                style: const TextStyle(
                  fontFamily: AppTypography.display,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1.2,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_weekdays[_now.weekday - 1]}, ${_now.day} ${_months[_now.month - 1]}',
          style: const TextStyle(
            fontFamily: AppTypography.body,
            fontWeight: FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.3,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
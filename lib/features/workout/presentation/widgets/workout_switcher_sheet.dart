import 'package:flutter/material.dart';
import 'day_picker_sheet.dart';

class WorkoutSwitcherSheet extends StatelessWidget {
  const WorkoutSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return DayPickerSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return const DayPickerSheet();
  }
}

import 'package:flutter/material.dart';
import 'alternatives_sheet.dart';

class AlternativeExerciseBottomSheet extends StatelessWidget {
  final String originalExerciseId;
  final String currentPerformedId;
  final Function(String) onSelect;

  const AlternativeExerciseBottomSheet({
    super.key,
    required this.originalExerciseId,
    required this.currentPerformedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return AlternativesSheet(
      originalExerciseId: originalExerciseId,
      currentPerformedId: currentPerformedId,
      onSelect: onSelect,
    );
  }
}

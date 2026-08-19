import 'package:flutter/material.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../data/datasources/replacement_matrix.dart';

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
    final alternatives = ReplacementMatrix.matrix[originalExerciseId] ?? [];

    // Include original as an option
    final List<String> allOptions = [originalExerciseId, ...alternatives];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Select Alternative',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final id = allOptions[index];
                final exercise = WorkoutCatalog.getExerciseById(id);
                final isSelected = id == currentPerformedId;

                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Text(exercise.name),
                  selected: isSelected,
                  onTap: () {
                    onSelect(id);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

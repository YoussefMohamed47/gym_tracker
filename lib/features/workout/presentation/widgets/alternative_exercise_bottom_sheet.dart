import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Swap Exercise',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Select a variation or alternative for this slot',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final id = allOptions[index];
                final exercise = WorkoutCatalog.getExerciseById(id);
                final isSelected = id == currentPerformedId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    tileColor: isSelected 
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) 
                        : null,
                    leading: Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    title: Text(
                      exercise.name,
                      style: GoogleFonts.outfit(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      onSelect(id);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

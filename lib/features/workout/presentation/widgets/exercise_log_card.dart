import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/weight_converter.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_log.dart';
import '../../domain/entities/workout_definition.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseLogCard extends StatelessWidget {
  final ExerciseLog log;
  final ExerciseSlot slot;
  final WeightUnit displayUnit;
  final Function(double?) onWeightChanged;
  final VoidCallback onTogglePerformed;
  final VoidCallback onSelectAlternative;
  final VoidCallback onAddPhoto;

  const ExerciseLogCard({
    super.key,
    required this.log,
    required this.slot,
    required this.displayUnit,
    required this.onWeightChanged,
    required this.onTogglePerformed,
    required this.onSelectAlternative,
    required this.onAddPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final originalExercise = WorkoutCatalog.getExerciseById(log.plannedExerciseId);
    final performedExercise = WorkoutCatalog.getExerciseById(log.performedExerciseId);
    final isAlternative = log.plannedExerciseId != log.performedExerciseId;

    final displayWeight = log.weightKg != null
        ? WeightConverter.convert(log.weightKg!, WeightUnit.kg, displayUnit)
        : null;

    final weightController = TextEditingController(
      text: displayWeight != null ? WeightConverter.format(displayWeight) : '',
    );
    // Move cursor to end
    weightController.selection = TextSelection.fromPosition(
      TextPosition(offset: weightController.text.length),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAlternative)
                        Text(
                          'Planned: ${originalExercise.name}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      Text(
                        performedExercise.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
                if (performedExercise.videoUrl != null)
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline, color: AppColors.primaryBlue),
                    onPressed: () async {
                      final url = Uri.parse(performedExercise.videoUrl!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                IconButton(
                  icon: Icon(
                    log.isPerformed ? Icons.check_circle : Icons.check_circle_outline,
                    color: log.isPerformed ? Colors.green : Colors.grey,
                  ),
                  onPressed: onTogglePerformed,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(context, '${slot.prescribedSets} sets'),
                const SizedBox(width: 8),
                _buildInfoChip(context, '${slot.prescribedReps} reps'),
                const SizedBox(width: 8),
                _buildInfoChip(context, 'Rest: ${slot.prescribedRest}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weight',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: '0.0',
                          suffixText: displayUnit.name,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          final weight = double.tryParse(value);
                          onWeightChanged(weight);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    IconButton(
                      icon: Icon(
                        log.imagePath != null ? Icons.image : Icons.add_a_photo_outlined,
                        color: log.imagePath != null ? AppColors.primaryBlue : Colors.grey,
                      ),
                      onPressed: onAddPhoto,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: onSelectAlternative,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Alternative'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: Colors.grey.shade700,
                  ),
                ),
                if (log.weightKg != null)
                  Text(
                    'Recorded',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/replacement_matrix.dart';
import '../../data/datasources/workout_catalog.dart';
import '../utils/video_launcher.dart';

class AlternativesSheet extends StatelessWidget {
  final String originalExerciseId;
  final String currentPerformedId;
  final Function(String) onSelect;

  const AlternativesSheet({
    super.key,
    required this.originalExerciseId,
    required this.currentPerformedId,
    required this.onSelect,
  });

  static Future<void> show(
    BuildContext context, {
    required String originalExerciseId,
    required String currentPerformedId,
    required Function(String) onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AlternativesSheet(
        originalExerciseId: originalExerciseId,
        currentPerformedId: currentPerformedId,
        onSelect: onSelect,
      ),
    );
  }

  List<String> _extractTags(String exerciseId, String name) {
    final text = '${exerciseId}_$name'.toLowerCase();
    final tags = <String>[];
    if (text.contains('chest') || text.contains('bench') || text.contains('fly')) tags.add('CHEST');
    if (text.contains('back') || text.contains('row') || text.contains('lat')) tags.add('BACK');
    if (text.contains('shoulder') || text.contains('delt') || text.contains('lateral')) tags.add('SHOULDERS');
    if (text.contains('bicep') || text.contains('curl')) tags.add('BICEPS');
    if (text.contains('tricep') || text.contains('push down')) tags.add('TRICEPS');
    if (text.contains('leg') || text.contains('squat') || text.contains('adduction')) tags.add('LEGS');
    if (text.contains('calf')) tags.add('CALVES');

    if (text.contains('cable')) {
      tags.add('CABLE');
    } else if (text.contains('db') || text.contains('dumbbell')) {
      tags.add('DUMBBELL');
    } else if (text.contains('machine') || text.contains('smith')) {
      tags.add('MACHINE');
    }
    if (tags.isEmpty) tags.add('VARIATION');
    return tags;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final originalExercise = WorkoutCatalog.getExerciseById(originalExerciseId);
    final originalTags = _extractTags(originalExercise.id, originalExercise.name);

    final rawAlternatives = ReplacementMatrix.matrix[originalExerciseId] ?? [];
    // Combine original with alternatives, ensuring uniqueness
    final allOptions = <String>{originalExerciseId, ...originalExercise.alternatives, ...rawAlternatives}.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? ReportThemeTokens.sheetSurfaceDark : ReportThemeTokens.sheetSurfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.borderSubtle : AppColors.outline,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ALTERNATIVE EXERCISES',
                      style: ReportThemeTokens.outfitHeader(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.textPrimary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            originalExercise.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (originalTags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              originalTags.first,
                              style: ReportThemeTokens.outfitSubtext(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.indigoAccent,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Alternates List (ListView.builder with lazy building)
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: allOptions.length,
              itemBuilder: (context, index) {
                final id = allOptions[index];
                final exercise = WorkoutCatalog.getExerciseById(id);
                final isCurrent = id == currentPerformedId;
                final isOriginal = id == originalExerciseId;
                final tags = _extractTags(exercise.id, exercise.name);
                final hasVideo = exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.indigoAccent.withValues(alpha: 0.12)
                        : (isDark ? AppColors.darkCard : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCurrent
                          ? AppColors.indigoAccent
                          : (isDark ? AppColors.borderSubtle : AppColors.outline),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Form Guide Play Button
                      IconButton(
                        icon: Icon(
                          hasVideo ? Icons.play_circle_fill_rounded : Icons.play_circle_outline_rounded,
                          color: hasVideo ? AppColors.indigoAccent : AppColors.textMuted,
                          size: 26,
                        ),
                        onPressed: hasVideo ? () => VideoLauncher.launch(context, exercise.videoUrl!) : null,
                        tooltip: hasVideo ? 'View Form Guide' : 'No video available',
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                      const SizedBox(width: 8),

                      // Name + Tag
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    exercise.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: ReportThemeTokens.outfitHeader(
                                      fontSize: 14,
                                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.bold,
                                      color: isCurrent
                                          ? AppColors.indigoAccent
                                          : (isDark ? AppColors.textPrimary : Colors.black87),
                                    ),
                                  ),
                                ),
                                if (isOriginal) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.indigoAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'ORIGINAL',
                                      style: ReportThemeTokens.outfitSubtext(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.indigoAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (tags.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                tags.join(' • '),
                                style: ReportThemeTokens.outfitSubtext(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Trailing Swap Button or Selected State
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.indigoAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: AppColors.indigoAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ACTIVE',
                                style: ReportThemeTokens.outfitSubtext(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.indigoAccent,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            final previousId = currentPerformedId;
                            onSelect(id);
                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Swapped to ${exercise.name}'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () => onSelect(previousId),
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.darkElevated : const Color(0xFFF0F2F7),
                            foregroundColor: isDark ? AppColors.textPrimary : Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            minimumSize: const Size(60, 36),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? AppColors.borderSubtle : AppColors.outline,
                              ),
                            ),
                          ),
                          child: Text(
                            'Swap',
                            style: ReportThemeTokens.outfitSubtext(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textPrimary : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

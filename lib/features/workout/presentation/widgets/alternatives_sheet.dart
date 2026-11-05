import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/alternatives_library.dart';
import '../../data/datasources/custom_alternatives_store.dart';
import '../../data/datasources/replacement_matrix.dart';
import '../../data/datasources/workout_catalog.dart';
import '../../domain/entities/exercise_definition.dart';
import '../utils/video_launcher.dart';

/// Swap one planned exercise for another: the plan's suggestions, the ones
/// you saved yourself, and a search over every exercise in the app.
class AlternativesSheet extends StatefulWidget {
  final String originalExerciseId;
  final String currentPerformedId;
  final Function(String) onSelect;

  /// Where "+ Add" saves; defaults to the app's store. Tests pass their own.
  final CustomAlternativesStore? store;

  const AlternativesSheet({
    super.key,
    required this.originalExerciseId,
    required this.currentPerformedId,
    required this.onSelect,
    this.store,
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

  /// Muscle and equipment tags, also used so "cable chest" finds cable flies.
  static List<String> tagsFor(String exerciseId, String name) {
    final text = '${exerciseId}_$name'.toLowerCase();
    final tags = <String>[];
    if (text.contains('chest') ||
        text.contains('bench') ||
        text.contains('fly') ||
        text.contains('crossover') ||
        text.contains('push up') ||
        text.contains('chest dip')) {
      tags.add('CHEST');
    }
    if (text.contains('back') ||
        text.contains('row') ||
        text.contains('lat') && !text.contains('lateral') ||
        text.contains('pull up') ||
        text.contains('pulldown')) {
      tags.add('BACK');
    }
    if (text.contains('shrug')) tags.add('TRAPS');
    if (text.contains('shoulder') ||
        text.contains('delt') ||
        text.contains('lateral') ||
        text.contains('y raise') ||
        text.contains('face pull')) {
      tags.add('SHOULDERS');
    }
    if (text.contains('bicep') ||
        text.contains('curl') && !text.contains('leg curl') ||
        text.contains('hammer')) {
      tags.add('BICEPS');
    }
    if (text.contains('tricep') ||
        text.contains('push down') ||
        text.contains('skull') ||
        text.contains('kickback') && !text.contains('glute') ||
        text.contains('close grip')) {
      tags.add('TRICEPS');
    }
    if (text.contains('wrist') || text.contains('forearm')) {
      tags.add('FOREARMS');
    }
    if (text.contains('leg') ||
        text.contains('squat') ||
        text.contains('adduction') ||
        text.contains('copenhagen')) {
      tags.add('LEGS');
    }
    if (text.contains('hip thrust') ||
        text.contains('glute') ||
        text.contains('rdl') ||
        text.contains('pull through') ||
        text.contains('back extension')) {
      tags.add('GLUTES');
    }
    if (text.contains('calf') || text.contains('calve')) tags.add('CALVES');
    if (text.contains('plank') ||
        text.contains('dead bug') ||
        text.contains('pallof') ||
        text.contains('bird dog')) {
      tags.add('CORE');
    }

    if (text.contains('cable')) {
      tags.add('CABLE');
    } else if (text.contains('smith')) {
      tags.add('SMITH');
    } else if (text.contains('machine')) {
      tags.add('MACHINE');
    } else if (text.contains('db') || text.contains('dumbbell')) {
      tags.add('DUMBBELL');
    } else if (text.contains('barbell') || text.contains('ez bar')) {
      tags.add('BARBELL');
    }
    if (tags.isEmpty) tags.add('VARIATION');
    return tags;
  }

  /// Exercises whose name or tags contain every word of [query].
  static const _equipmentTags = {
    'CABLE',
    'SMITH',
    'MACHINE',
    'DUMBBELL',
    'BARBELL',
    'VARIATION',
  };

  /// The muscle tags of an exercise, without equipment.
  static Set<String> musclesOf(String exerciseId) {
    final e = WorkoutCatalog.getExerciseById(exerciseId);
    return tagsFor(e.id, e.name).toSet().difference(_equipmentTags);
  }

  /// Exercises whose name or tags contain every word of [query]. With
  /// [sameMuscleAs], only exercises that train the same muscle group are
  /// returned (mobility moves match other bodyweight-only moves).
  static List<ExerciseDefinition> search(
    String query, {
    Set<String> exclude = const {},
    String? sameMuscleAs,
  }) {
    final target = sameMuscleAs == null ? null : musclesOf(sameMuscleAs);
    final targetIsMobility =
        sameMuscleAs != null &&
        target!.isEmpty &&
        !WorkoutCatalog.getExerciseById(sameMuscleAs).isWeightAllowed;
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    final results = <ExerciseDefinition>[];
    for (final e in WorkoutCatalog.searchableExercises) {
      if (exclude.contains(e.id)) continue;
      if (target != null) {
        final muscles = musclesOf(e.id);
        final sameGroup = target.isNotEmpty
            ? muscles.intersection(target).isNotEmpty
            : targetIsMobility && !e.isWeightAllowed;
        if (!sameGroup) continue;
      }
      final haystack = '${e.name} ${tagsFor(e.id, e.name).join(' ')}'
          .toLowerCase()
          .replaceAll('db', 'db dumbbell')
          .replaceAll('sa ', 'sa single arm ');
      if (words.every(haystack.contains)) results.add(e);
    }
    return results;
  }

  @override
  State<AlternativesSheet> createState() => _AlternativesSheetState();
}

class _AlternativesSheetState extends State<AlternativesSheet> {
  final _query = TextEditingController();
  late final CustomAlternativesStore? _store =
      widget.store ??
      (di.sl.isRegistered<CustomAlternativesStore>()
          ? di.sl<CustomAlternativesStore>()
          : null);
  late List<String> _saved =
      _store?.forExercise(widget.originalExerciseId) ?? const [];

  /// Tiles whose how-to steps are open.
  final Set<String> _open = {};

  String _searchHint() {
    final muscles = AlternativesSheet.musclesOf(widget.originalExerciseId);
    if (muscles.isEmpty) return 'Search similar exercises';
    return 'Search ${muscles.map((m) => m.toLowerCase()).join(' / ')} exercises';
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<String> get _suggested {
    final original = WorkoutCatalog.getExerciseById(widget.originalExerciseId);
    return <String>{
      widget.originalExerciseId,
      ...original.alternatives,
      ...?ReplacementMatrix.matrix[widget.originalExerciseId],
      ...?AlternativesLibrary.forExercise[widget.originalExerciseId],
    }.where((id) => !_saved.contains(id)).toList();
  }

  // Hive updates its in-memory copy at once, so the list refreshes now and
  // the disk write finishes in the background.
  void _add(String id) {
    HapticFeedback.selectionClick();
    final store = _store;
    if (store != null) unawaited(store.add(widget.originalExerciseId, id));
    setState(() {
      _saved = store?.forExercise(widget.originalExerciseId) ?? [..._saved, id];
    });
  }

  void _remove(String id) {
    HapticFeedback.selectionClick();
    final store = _store;
    if (store != null) unawaited(store.remove(widget.originalExerciseId, id));
    setState(() {
      _saved =
          store?.forExercise(widget.originalExerciseId) ??
          _saved.where((s) => s != id).toList();
    });
  }

  void _swap(String id) {
    HapticFeedback.mediumImpact();
    final previousId = widget.currentPerformedId;
    final name = WorkoutCatalog.getExerciseById(id).name;
    final messenger = ScaffoldMessenger.of(context);
    widget.onSelect(id);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('Swapped to $name'),
        persist: false,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => widget.onSelect(previousId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final original = WorkoutCatalog.getExerciseById(widget.originalExerciseId);
    final originalTags = AlternativesSheet.tagsFor(original.id, original.name);
    final query = _query.text.trim();
    final suggested = _suggested;
    final listed = {...suggested, ..._saved};
    final matches = query.isEmpty
        ? const <String>{}
        : AlternativesSheet.search(
            query,
            sameMuscleAs: widget.originalExerciseId,
          ).map((e) => e.id).toSet();
    final listedMatches = [
      for (final id in listed)
        if (matches.contains(id)) id,
    ];
    // Search stays within the same training: e.g. chest exercises for a
    // chest exercise. Already-listed options are matched by name only.
    final results = AlternativesSheet.search(
      query,
      exclude: listed,
      sameMuscleAs: widget.originalExerciseId,
    );

    final children = <Widget>[
      if (query.isEmpty) ...[
        if (_saved.isNotEmpty) ...[
          _sectionLabel('SAVED BY YOU'),
          for (final id in _saved) _tile(context, id, saved: true),
          const SizedBox(height: 8),
          _sectionLabel('SUGGESTED'),
        ],
        for (final id in suggested) _tile(context, id),
      ] else ...[
        // While searching, matching listed options stay on top.
        for (final id in listedMatches)
          _tile(context, id, saved: _saved.contains(id)),
        if (results.isNotEmpty) _sectionLabel('MORE EXERCISES'),
        for (final e in results) _tile(context, e.id, canAdd: true),
        if (results.isEmpty && listedMatches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Text(
              'No exercise matches "$query"',
              textAlign: TextAlign.center,
              style: ReportThemeTokens.outfitSubtext(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
      ],
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: isDark
              ? ReportThemeTokens.sheetSurfaceDark
              : ReportThemeTokens.sheetSurfaceLight,
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
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Swap exercise',
                        style: ReportThemeTokens.outfitHeader(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${original.name}  ·  ${originalTags.first}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
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
            const SizedBox(height: 12),
            TextField(
              controller: _query,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: _searchHint(),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () => setState(_query.clear),
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(child: ListView(shrinkWrap: true, children: children)),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
    child: Text(
      text,
      style: ReportThemeTokens.outfitSubtext(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        color: AppColors.textSecondary,
      ).copyWith(letterSpacing: 1.4),
    ),
  );

  Widget _tile(
    BuildContext context,
    String id, {
    bool saved = false,
    bool canAdd = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exercise = WorkoutCatalog.getExerciseById(id);
    final isCurrent = id == widget.currentPerformedId;
    final isOriginal = id == widget.originalExerciseId;
    final tags = AlternativesSheet.tagsFor(exercise.id, exercise.name);
    final hasVideo = exercise.videoUrl != null && exercise.videoUrl!.isNotEmpty;
    final hasSteps = exercise.howTo.isNotEmpty;
    final isOpen = _open.contains(id);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(6, 8, 8, 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  hasVideo
                      ? Icons.play_circle_fill_rounded
                      : Icons.play_circle_outline_rounded,
                  color: hasVideo
                      ? AppColors.indigoAccent
                      : AppColors.textMuted,
                  size: 26,
                ),
                onPressed: hasVideo
                    ? () => VideoLauncher.launch(context, exercise.videoUrl!)
                    : null,
                tooltip: hasVideo ? 'How to' : 'No video',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: hasSteps
                      ? () => setState(
                          () => isOpen ? _open.remove(id) : _open.add(id),
                        )
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              exercise.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ReportThemeTokens.outfitHeader(
                                fontSize: 14,
                                fontWeight: isCurrent
                                    ? FontWeight.w900
                                    : FontWeight.bold,
                                color: isCurrent
                                    ? AppColors.indigoAccent
                                    : (isDark
                                          ? AppColors.textPrimary
                                          : Colors.black87),
                              ),
                            ),
                          ),
                          if (isOriginal) ...[
                            const SizedBox(width: 6),
                            _badge('PLANNED'),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (exercise.repRange != null)
                            '${exercise.repRange} reps',
                          ...tags,
                        ].join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (hasSteps)
                        Text(
                          isOpen ? 'Hide how to ▴' : 'How to ▾',
                          style: ReportThemeTokens.outfitSubtext(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.indigoAccent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (saved)
                IconButton(
                  tooltip: 'Remove from list',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.bookmark_remove_outlined, size: 20),
                  color: AppColors.textSecondary,
                  onPressed: () => _remove(id),
                )
              else if (canAdd)
                TextButton(
                  onPressed: () => _add(id),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.indigoAccent,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 34),
                  ),
                  child: const Text('+ Add'),
                ),
              const SizedBox(width: 4),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.indigoAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Doing',
                    style: ReportThemeTokens.outfitSubtext(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.indigoAccent,
                    ),
                  ),
                )
              else
                FilledButton.tonal(
                  onPressed: () => _swap(id),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    minimumSize: const Size(0, 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Swap'),
                ),
            ],
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(44, 4, 8, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < exercise.howTo.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${i + 1}. ${exercise.howTo[i]}',
                        style: ReportThemeTokens.outfitSubtext(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: AppColors.indigoAccent.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: ReportThemeTokens.outfitSubtext(
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: AppColors.indigoAccent,
      ),
    ),
  );
}

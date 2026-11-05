import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/app_colors.dart';
import '../../data/datasources/nutrition_catalog.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/model/meal_entry.dart';
import '../../domain/model/meal_slot.dart';
import 'meal_option_selector.dart';

extension MealSlotCatalog on MealSlot {
  List<MealCategoryOptions> get catalog => switch (this) {
    MealSlot.breakfast => NutritionCatalog.breakfast,
    MealSlot.lunch => NutritionCatalog.lunch,
    MealSlot.dinner => NutritionCatalog.dinner,
    MealSlot.snack => NutritionCatalog.snack,
    MealSlot.beforeTraining => NutritionCatalog.beforeTraining,
    MealSlot.afterTraining => NutritionCatalog.afterTraining,
  };
}

/// The day's meals as a vertical timeline. Logged meals collapse to one line,
/// the active meal opens the existing meal editor, and a repeated meal can be
/// filled in one tap with "Your usual …".
class MealTimeline extends StatelessWidget {
  final DailyReport report;
  final MealSlot active;
  final Map<MealSlot, List<MealEntry>> usualMeals;
  final ValueChanged<MealSlot> onSelect;
  final void Function(MealSlot slot, List<MealEntry> entries) onEntriesChanged;

  const MealTimeline({
    super.key,
    required this.report,
    required this.active,
    required this.usualMeals,
    required this.onSelect,
    required this.onEntriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        // The vertical rail behind the dots.
        PositionedDirectional(
          start: 8,
          top: 14,
          bottom: 24,
          child: Container(
            width: 2,
            color: scheme.outline.withValues(alpha: .35),
          ),
        ),
        Column(
          children: [
            for (final slot in MealSlot.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(top: 15),
                      child: _Dot(
                        state: slot == active
                            ? _DotState.active
                            : slot.isLogged(report)
                            ? _DotState.done
                            : _DotState.todo,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: slot == active
                            ? _ActiveMeal(
                                key: ValueKey('${report.id}-${slot.name}'),
                                report: report,
                                slot: slot,
                                usual: usualMeals[slot],
                                onEntriesChanged: (e) =>
                                    onEntriesChanged(slot, e),
                              )
                            : _CollapsedMeal(
                                report: report,
                                slot: slot,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onSelect(slot);
                                },
                              ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

enum _DotState { done, active, todo }

class _Dot extends StatelessWidget {
  final _DotState state;
  const _Dot({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: switch (state) {
          _DotState.done => AppColors.completedGreen,
          _DotState.active => scheme.primary,
          _DotState.todo => scheme.surface,
        },
        border: state == _DotState.todo
            ? Border.all(color: scheme.onSurfaceVariant, width: 2)
            : null,
        boxShadow: state == _DotState.active
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .25),
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: state == _DotState.done
          ? const Icon(Icons.check_rounded, size: 12, color: Color(0xFF06150E))
          : null,
    );
  }
}

class _MealTitle extends StatelessWidget {
  final MealSlot slot;
  final double size;
  const _MealTitle({required this.slot, this.size = 14});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          slot.arabicName,
          style: GoogleFonts.cairo(
            fontSize: size,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        Text(
          slot.englishName.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _CollapsedMeal extends StatelessWidget {
  final DailyReport report;
  final MealSlot slot;
  final VoidCallback onTap;
  const _CollapsedMeal({
    required this.report,
    required this.slot,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final logged = slot.isLogged(report);
    final entries = slot.entriesOf(report);
    final summary = entries.isNotEmpty
        ? entries.map((e) => e.name).join(' · ')
        : slot.textOf(report).trim();

    return Opacity(
      opacity: logged ? 1 : .65,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outline.withValues(alpha: .35)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _MealTitle(slot: slot),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    logged ? summary : 'Tap to log',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: logged
                        ? GoogleFonts.cairo(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          )
                        : GoogleFonts.outfit(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
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

class _ActiveMeal extends StatelessWidget {
  final DailyReport report;
  final MealSlot slot;
  final List<MealEntry>? usual;
  final ValueChanged<List<MealEntry>> onEntriesChanged;

  const _ActiveMeal({
    super.key,
    required this.report,
    required this.slot,
    required this.usual,
    required this.onEntriesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = slot.entriesOf(report);
    final usual = this.usual;
    final showUsual =
        usual != null && usual.isNotEmpty && !_sameFoods(usual, entries);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: .5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _MealTitle(slot: slot, size: 17),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'NOW',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: scheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${entries.length} items',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (showUsual) ...[
            const SizedBox(height: 10),
            _UsualMealChip(
              slot: slot,
              entries: usual,
              onUse: () {
                HapticFeedback.mediumImpact();
                onEntriesChanged(List.of(usual));
              },
            ),
          ],
          const SizedBox(height: 6),
          MealOptionSelector(
            // Rebuild the editor when entries are replaced from outside,
            // e.g. by "Use" on the usual meal or "copy last report".
            key: ValueKey('${report.id}-${slot.name}-${_signature(entries)}'),
            label: slot.arabicName,
            initialValue: slot.textOf(report),
            initialEntries: entries,
            categories: slot.catalog,
            onChanged: (legacy) =>
                onEntriesChanged([MealEntry(name: legacy, category: 'Custom')]),
            onEntriesChanged: onEntriesChanged,
          ),
        ],
      ),
    );
  }

  static String _signature(List<MealEntry> entries) =>
      entries.map((e) => '${e.name}:${e.quantity}').join('|');

  static bool _sameFoods(List<MealEntry> a, List<MealEntry> b) {
    if (a.length != b.length) return false;
    final an = a.map((e) => e.name).toList()..sort();
    final bn = b.map((e) => e.name).toList()..sort();
    for (var i = 0; i < an.length; i++) {
      if (an[i] != bn[i]) return false;
    }
    return true;
  }
}

class _UsualMealChip extends StatelessWidget {
  final MealSlot slot;
  final List<MealEntry> entries;
  final VoidCallback onUse;
  const _UsualMealChip({
    required this.slot,
    required this.entries,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.primary.withValues(alpha: .45)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(Icons.bolt_rounded, size: 18, color: scheme.onPrimary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your usual ${slot.englishName.toLowerCase()}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
                Text(
                  entries.map((e) => e.name).join(' + '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onUse,
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Use',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

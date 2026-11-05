import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/athletic_ui.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/model/meal_entry.dart';
import '../../domain/model/meal_slot.dart';
import '../../domain/model/water_amount.dart';
import 'meal_timeline.dart';
import 'water_quick_add_card.dart';
import 'supplement_selector.dart';

/// A focused journal rather than a long scroll of generic form cards.
/// All changes still go through the existing DailyReportCubit callback.
class DailyReportForm extends StatefulWidget {
  final DailyReport report;
  final ValueChanged<DailyReport> onChanged;
  final List<String> trainingOptions;
  final Map<MealSlot, List<MealEntry>> usualMeals;
  final double waterTargetLiters;
  final ValueChanged<double> onWaterTargetChanged;

  const DailyReportForm({
    super.key,
    required this.report,
    required this.onChanged,
    required this.trainingOptions,
    this.usualMeals = const {},
    this.waterTargetLiters = 3.0,
    required this.onWaterTargetChanged,
  });

  @override
  State<DailyReportForm> createState() => _DailyReportFormState();
}

class _DailyReportFormState extends State<DailyReportForm> {
  late MealSlot _active;

  @override
  void initState() {
    super.initState();
    // Open on the first meal not logged yet, so the next tap is the right one.
    _active = MealSlot.values.firstWhere(
      (s) => !s.isLogged(widget.report),
      orElse: () => MealSlot.values.first,
    );
  }

  void _setMeal(MealSlot slot, List<MealEntry> entries) {
    widget.onChanged(slot.withEntries(widget.report, entries));
  }

  void _addWater(double liters) {
    final current = WaterAmount.parseLiters(widget.report.water) ?? 0;
    final next = (current + liters).clamp(0.0, 20.0);
    widget.onChanged(widget.report.copyWith(water: WaterAmount.format(next)));
  }

  Widget _field(
    String label,
    String value,
    ValueChanged<String> onChanged, {
    IconData? icon,
    int lines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        key: ValueKey(label),
        initialValue: value,
        maxLines: lines,
        style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
          prefixIcon: icon == null
              ? null
              : Icon(icon, size: 19, color: colors.primary),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AthleticSectionTitle(
          number: '01',
          title: 'Nutrition studio',
          description: 'سجّل الوجبات وعدّل الكميات من مكان واحد.',
        ),
        MealTimeline(
          report: report,
          active: _active,
          usualMeals: widget.usualMeals,
          onSelect: (slot) => setState(() => _active = slot),
          onEntriesChanged: _setMeal,
        ),
        const SizedBox(height: 32),
        const AthleticSectionTitle(
          number: '02',
          title: 'Hydration & training',
          description: 'المياه والنشاط اليومي.',
        ),
        WaterQuickAddCard(
          waterText: report.water,
          targetLiters: widget.waterTargetLiters,
          onAdd: _addWater,
          onSetText: (text) => widget.onChanged(report.copyWith(water: text)),
          onSetTarget: widget.onWaterTargetChanged,
        ),
        const SizedBox(height: 14),
        // Always shows the report's current training (which follows the
        // Workout tab). A value outside the plan list is still listed.
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'نوع التمرين',
              labelStyle: GoogleFonts.cairo(fontSize: 12),
              prefixIcon: Icon(
                Icons.fitness_center_outlined,
                color: scheme.primary,
              ),
              contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            ),
            isEmpty: report.training.trim().isEmpty,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: report.training.trim().isEmpty ? null : report.training,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  for (final e in {
                    ...widget.trainingOptions,
                    if (report.training.trim().isNotEmpty) report.training,
                  })
                    DropdownMenuItem(
                      value: e,
                      child: Text(e, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) =>
                    widget.onChanged(report.copyWith(training: v ?? '')),
              ),
            ),
          ),
        ),
        _field(
          'مدة الكارديو',
          report.cardio,
          (v) => widget.onChanged(report.copyWith(cardio: v)),
          icon: Icons.directions_run_outlined,
        ),
        const SizedBox(height: 22),
        const AthleticSectionTitle(
          number: '03',
          title: 'Recovery Notes',
          description: 'النوم والمكملات والملاحظات.',
        ),
        _field(
          'مدة النوم',
          report.sleepTime,
          (v) => widget.onChanged(report.copyWith(sleepTime: v)),
          icon: Icons.bedtime_outlined,
        ),
        SupplementSelector(
          initialValue: report.supplements,
          onChanged: (v) => widget.onChanged(report.copyWith(supplements: v)),
        ),
        const SizedBox(height: 12),
        _field(
          'ملاحظات عامة',
          report.notes ?? '',
          (v) => widget.onChanged(report.copyWith(notes: v)),
          icon: Icons.edit_note_outlined,
          lines: 3,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/athletic_ui.dart';
import '../../data/datasources/nutrition_catalog.dart';
import '../../domain/model/daily_report.dart';
import '../../domain/model/meal_entry.dart';
import 'meal_option_selector.dart';
import 'supplement_selector.dart';

/// A focused journal rather than a long scroll of generic form cards.
/// All changes still go through the existing DailyReportCubit callback.
class DailyReportForm extends StatefulWidget {
  final DailyReport report;
  final ValueChanged<DailyReport> onChanged;
  final List<String> trainingOptions;
  const DailyReportForm({super.key, required this.report, required this.onChanged, required this.trainingOptions});

  @override
  State<DailyReportForm> createState() => _DailyReportFormState();
}

class _DailyReportFormState extends State<DailyReportForm> {
  int selectedMeal = 0;

  static const _names = ['الإفطار', 'الغداء', 'العشاء', 'السناك', 'قبل التمرين', 'بعد التمرين'];
  static const _symbols = [Icons.wb_sunny_outlined, Icons.lunch_dining_outlined, Icons.nightlight_outlined, Icons.cookie_outlined, Icons.bolt_outlined, Icons.fitness_center_outlined];

  String _textFor(int index) {
    final r = widget.report;
    switch (index) {
      case 0: return r.breakfast;
      case 1: return r.lunch;
      case 2: return r.dinner;
      case 3: return r.snack;
      case 4: return r.beforeTraining;
      default: return r.afterTraining;
    }
  }

  List<MealEntry> _entriesFor(int index) {
    final r = widget.report;
    switch (index) {
      case 0: return r.breakfastEntries;
      case 1: return r.lunchEntries;
      case 2: return r.dinnerEntries;
      case 3: return r.snackEntries;
      case 4: return r.beforeTrainingEntries;
      default: return r.afterTrainingEntries;
    }
  }

  List<MealCategoryOptions> _catalogFor(int index) {
    switch (index) {
      case 0: return NutritionCatalog.breakfast;
      case 1: return NutritionCatalog.lunch;
      case 2: return NutritionCatalog.dinner;
      case 3: return NutritionCatalog.snack;
      case 4: return NutritionCatalog.beforeTraining;
      default: return NutritionCatalog.afterTraining;
    }
  }

  void _setMeal(List<MealEntry> entries) {
    final r = widget.report;
    final text = mealEntriesToLegacyText(entries);
    switch (selectedMeal) {
      case 0: widget.onChanged(r.copyWith(breakfast: text, breakfastEntries: entries)); return;
      case 1: widget.onChanged(r.copyWith(lunch: text, lunchEntries: entries)); return;
      case 2: widget.onChanged(r.copyWith(dinner: text, dinnerEntries: entries)); return;
      case 3: widget.onChanged(r.copyWith(snack: text, snackEntries: entries)); return;
      case 4: widget.onChanged(r.copyWith(beforeTraining: text, beforeTrainingEntries: entries)); return;
      case 5: widget.onChanged(r.copyWith(afterTraining: text, afterTrainingEntries: entries)); return;
    }
  }

  Widget _field(String label, String value, ValueChanged<String> onChanged, {IconData? icon, int lines = 1}) {
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
          labelStyle: GoogleFonts.cairo(fontSize: 12, color: colors.onSurfaceVariant),
          prefixIcon: icon == null ? null : Icon(icon, size: 19, color: colors.primary),
        ),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final report = widget.report;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const AthleticSectionTitle(number: '01', title: 'Nutrition studio', description: 'سجّل الوجبات وعدّل الكميات من مكان واحد.'),
      // A six-position meal rail; the editor only shows the active meal.
      SizedBox(height: 104, child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = index == selectedMeal;
          final completed = _textFor(index).trim().isNotEmpty || _entriesFor(index).isNotEmpty;
          return Semantics(
            selected: active,
            button: true,
            label: _names[index],
            child: InkWell(
              onTap: () => setState(() => selectedMeal = index),
              borderRadius: BorderRadius.circular(15),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 92,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: active ? scheme.primary : scheme.surface,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: active ? scheme.primary : scheme.outline.withValues(alpha: 0.3)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(_symbols[index], size: 22, color: active ? scheme.onPrimary : scheme.primary),
                  const Spacer(),
                  Text(_names[index], maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800, color: active ? scheme.onPrimary : scheme.onSurface)),
                  const SizedBox(height: 4),
                  Container(width: completed ? 32 : 12, height: 3, decoration: BoxDecoration(
                    color: active ? scheme.onPrimary : completed ? scheme.primary : scheme.outline,
                    borderRadius: BorderRadius.circular(4),
                  )),
                ]),
              ),
            ),
          );
        },
      )),
      const SizedBox(height: 18),
      Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(_names[selectedMeal], style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800))),
            Text('${_entriesFor(selectedMeal).length} عناصر', style: GoogleFonts.cairo(color: scheme.onSurfaceVariant, fontSize: 11)),
          ]),
          Divider(height: 27, color: scheme.outline.withValues(alpha: .35)),
          MealOptionSelector(
            key: ValueKey('${report.id}-$selectedMeal'),
            label: _names[selectedMeal],
            initialValue: _textFor(selectedMeal),
            initialEntries: _entriesFor(selectedMeal),
            categories: _catalogFor(selectedMeal),
            onChanged: (legacy) => _setMeal([MealEntry(name: legacy, category: 'Custom')]),
            onEntriesChanged: _setMeal,
          ),
        ]),
      ),
      const SizedBox(height: 32),
      const AthleticSectionTitle(number: '02', title: 'Hydration & training', description: 'المياه والنشاط اليومي.'),
      _field('كمية المياه *', report.water, (v) => widget.onChanged(report.copyWith(water: v)), icon: Icons.water_drop_outlined),
      // Existing training values remain the source of truth; no new plans.
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          key: ValueKey('training-${report.id}-${widget.trainingOptions.join('|')}'),
          initialValue: widget.trainingOptions.contains(report.training) ? report.training : null,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'نوع التمرين', labelStyle: GoogleFonts.cairo(fontSize: 12),
            prefixIcon: Icon(Icons.fitness_center_outlined, color: scheme.primary),
          ),
          items: widget.trainingOptions.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
          onChanged: (v) => widget.onChanged(report.copyWith(training: v ?? '')),
        ),
      ),
      _field('مدة الكارديو', report.cardio, (v) => widget.onChanged(report.copyWith(cardio: v)), icon: Icons.directions_run_outlined),
      const SizedBox(height: 22),
      const AthleticSectionTitle(number: '03', title: 'Recovery notes', description: 'النوم والمكملات والملاحظات.'),
      _field('مدة النوم', report.sleepTime, (v) => widget.onChanged(report.copyWith(sleepTime: v)), icon: Icons.bedtime_outlined),
      SupplementSelector(initialValue: report.supplements,
        onChanged: (v) => widget.onChanged(report.copyWith(supplements: v))),
      const SizedBox(height: 12),
      _field('ملاحظات عامة', report.notes ?? '', (v) => widget.onChanged(report.copyWith(notes: v)),
        icon: Icons.edit_note_outlined, lines: 3),
    ]);
  }
}

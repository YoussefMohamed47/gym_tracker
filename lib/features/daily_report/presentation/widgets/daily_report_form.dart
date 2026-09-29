import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/datasources/nutrition_catalog.dart';
import '../../domain/model/daily_report.dart';
import 'meal_option_selector.dart';
import 'supplement_selector.dart';

class DailyReportForm extends StatelessWidget {
  final DailyReport report;
  final Function(DailyReport) onChanged;

  const DailyReportForm({
    super.key,
    required this.report,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          context,
          'Meals & Nutrition',
          Icons.restaurant_menu,
          [
            MealOptionSelector(
              label: 'الإفطار (Breakfast)',
              categories: NutritionCatalog.breakfast,
              initialValue: report.breakfast,
              onChanged: (val) => onChanged(report.copyWith(breakfast: val)),
            ),
            MealOptionSelector(
              label: 'الغداء (Lunch)',
              categories: NutritionCatalog.lunch,
              initialValue: report.lunch,
              onChanged: (val) => onChanged(report.copyWith(lunch: val)),
            ),
            MealOptionSelector(
              label: 'العشاء (Dinner)',
              categories: NutritionCatalog.dinner,
              initialValue: report.dinner,
              onChanged: (val) => onChanged(report.copyWith(dinner: val)),
            ),
            MealOptionSelector(
              label: 'السناك (Snack)',
              categories: NutritionCatalog.snack,
              initialValue: report.snack,
              onChanged: (val) => onChanged(report.copyWith(snack: val)),
            ),
            _buildTextField(
              'Water Intake (كمية المياه) *',
              report.water,
              (val) => onChanged(report.copyWith(water: val)),
              isRequired: true,
            ),
          ],
          0,
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Training',
          Icons.fitness_center,
          [
            MealOptionSelector(
              label: 'قبل التمرين (Before Training)',
              categories: NutritionCatalog.beforeTraining,
              initialValue: report.beforeTraining,
              onChanged: (val) => onChanged(report.copyWith(beforeTraining: val)),
            ),
            MealOptionSelector(
              label: 'بعد التمرين (After Training)',
              categories: NutritionCatalog.afterTraining,
              initialValue: report.afterTraining,
              onChanged: (val) => onChanged(report.copyWith(afterTraining: val)),
            ),
            _buildTextField(
              'Training Name/Intensity (نوع وحجم التمرين)',
              report.training,
              (val) => onChanged(report.copyWith(training: val)),
              maxLines: 2,
            ),
            _buildTextField(
              'Cardio Duration (مدة الكارديو)',
              report.cardio,
              (val) => onChanged(report.copyWith(cardio: val)),
            ),
          ],
          1,
        ),
        const SizedBox(height: 24),
        _buildSection(
          context,
          'Others',
          Icons.more_horiz,
          [
            SupplementSelector(
              initialValue: report.supplements,
              onChanged: (val) => onChanged(report.copyWith(supplements: val)),
            ),
            _buildTextField(
              'Sleep Time (مدة النوم)',
              report.sleepTime,
              (val) => onChanged(report.copyWith(sleepTime: val)),
            ),
            _buildTextField(
              'Notes (ملاحظات عامة)',
              report.notes ?? '',
              (val) => onChanged(report.copyWith(notes: val)),
              maxLines: 4,
            ),
          ],
          2,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    )
        .animate(delay: (index * 150).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    int maxLines = 1,
    bool isRequired = false,
  }) {
    final isMissingRequired = isRequired && value.trim().isEmpty;

    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isMissingRequired
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: isMissingRequired
                ? Theme.of(context).colorScheme.error.withValues(alpha: 0.08)
                : Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: isMissingRequired
                  ? BorderSide(color: Theme.of(context).colorScheme.error)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: isMissingRequired
                  ? BorderSide(color: Theme.of(context).colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isMissingRequired
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          maxLines: maxLines,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

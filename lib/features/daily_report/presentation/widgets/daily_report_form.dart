import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/model/daily_report.dart';

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
            'Meals & Nutrition', Icons.restaurant_menu, [
          _buildTextField(
            'Breakfast',
            report.breakfast,
            (val) => onChanged(report.copyWith(breakfast: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'Lunch',
            report.lunch,
            (val) => onChanged(report.copyWith(lunch: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'Dinner',
            report.dinner,
            (val) => onChanged(report.copyWith(dinner: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'Snack',
            report.snack,
            (val) => onChanged(report.copyWith(snack: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'Water Intake',
            report.water,
            (val) => onChanged(report.copyWith(water: val)),
          ),
        ], 0),
        const SizedBox(height: 24),
        _buildSection(context,'Training', Icons.fitness_center, [
          _buildTextField(
            'Before Training',
            report.beforeTraining,
            (val) => onChanged(report.copyWith(beforeTraining: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'After Training',
            report.afterTraining,
            (val) => onChanged(report.copyWith(afterTraining: val)),
            maxLines: 3,
          ),
          _buildTextField(
            'Training Name/Intensity',
            report.training,
            (val) => onChanged(report.copyWith(training: val)),
            maxLines: 2,
          ),
          _buildTextField(
            'Cardio Duration',
            report.cardio,
            (val) => onChanged(report.copyWith(cardio: val)),
          ),
        ], 1),
        const SizedBox(height: 24),
        _buildSection(context,'Others', Icons.more_horiz, [
          _buildTextField(
            'Supplements / Vitamins',
            report.supplements,
            (val) => onChanged(report.copyWith(supplements: val)),
            maxLines: 2,
          ),
          _buildTextField(
            'Sleep Time',
            report.sleepTime,
            (val) => onChanged(report.copyWith(sleepTime: val)),
          ),
          _buildTextField(
            'Notes',
            report.notes ?? '',
            (val) => onChanged(report.copyWith(notes: val)),
            maxLines: 5,
          ),
        ], 2),
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
              Divider(height: 1, color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5)),
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
  }) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          initialValue: value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
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

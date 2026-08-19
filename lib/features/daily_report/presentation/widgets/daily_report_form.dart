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
        _buildSection('Meals & Nutrition', Icons.restaurant_menu, [
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
        _buildSection('Training', Icons.fitness_center, [
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
        _buildSection('Others', Icons.more_horiz, [
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
    String title,
    IconData icon,
    List<Widget> children,
    int index,
  ) {
    return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF1A46A0)),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A46A0),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A46A0), width: 2),
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        maxLines: maxLines,
        onChanged: onChanged,
      ),
    );
  }
}

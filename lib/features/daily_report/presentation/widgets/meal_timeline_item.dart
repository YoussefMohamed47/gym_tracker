import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../domain/model/meal_entry.dart';
import '../utils/meal_parser.dart';
import 'food_row.dart';

/// An editorial report line: discrete meal sections, not repeated boxed cards.
/// Structured entries are rendered directly; old strings are parsed only as a
/// legacy fallback so changed quantities always come from stored data.
class MealTimelineItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String content;
  final List<MealEntry> entries;
  final bool isLast;
  final bool isExportMode;
  const MealTimelineItem({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.entries = const [],
    this.isLast = false,
    this.isExportMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final foods = entries.isEmpty
      ? MealParser.parse(content)
      : entries.map((entry) => ParsedFoodItem(
          name: entry.note == null ? entry.name : '${entry.name} — ${entry.note}',
          quantity: entry.displayQuantity.isEmpty ? null : entry.displayQuantity,
        )).toList();
    final empty = foods.isEmpty;
    return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 34, child: Column(children: [
          Container(width: 30, height: 30, alignment: Alignment.center,
            decoration: BoxDecoration(color: empty ? ReportThemeTokens.elevatedCard : ReportThemeTokens.indigoAccent,
              shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: empty ? ReportThemeTokens.textMuted : Colors.black)),
          if (!isLast) Container(width: 1, height: foods.length * 30.0 + 18,
            color: ReportThemeTokens.borderMedium),
        ])),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: ReportThemeTokens.arabicHeader(fontSize: 15))),
            Text(empty ? '—' : '${foods.length}', style: GoogleFonts.outfit(
              color: empty ? ReportThemeTokens.textMuted : ReportThemeTokens.indigoAccent,
              fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 8),
          if (empty) Text('لم يتم التسجيل', style: ReportThemeTokens.arabicBody(fontSize: 11,
            color: ReportThemeTokens.textMuted))
          else ...foods.map((f) => FoodRow(item: f)),
          const SizedBox(height: 10),
          Container(height: 1, color: ReportThemeTokens.borderSubtle),
        ])),
      ],
    ));
  }
}

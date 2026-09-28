import 'package:flutter/material.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../utils/meal_parser.dart';
import 'quantity_chip.dart';

class FoodRow extends StatelessWidget {
  final ParsedFoodItem item;

  const FoodRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Small bullet dot
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: ReportThemeTokens.indigoAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),

          // Food Name
          Expanded(
            child: Text(
              item.name,
              style: ReportThemeTokens.arabicBody(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ReportThemeTokens.textPrimary,
              ),
            ),
          ),

          // Quantity Chip if available
          if (item.quantity != null && item.quantity!.isNotEmpty) ...[
            const SizedBox(width: 8),
            QuantityChip(text: item.quantity!),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact editorial bottom rail. No translucent floating pill or blur.
class FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const FloatingNavBar({super.key, required this.selectedIndex, required this.onDestinationSelected});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <(IconData, String, String)>[
      (Icons.grid_view_rounded, 'JOURNAL', '01'),
      (Icons.fitness_center_rounded, 'TRAINING', '02'),
    ];
    return SafeArea(top: false, child: Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      height: 72,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outline.withValues(alpha: .3)),
      ),
      child: Row(children: [
        for (var i = 0; i < items.length; i++)
          Expanded(child: Semantics(
            selected: selectedIndex == i,
            button: true,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onDestinationSelected(i);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(padding: const EdgeInsets.all(8), child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(width: 36, height: 40,
                    decoration: BoxDecoration(color: selectedIndex == i ? scheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10)),
                    child: Icon(items[i].$1, size: 20, color: selectedIndex == i ? scheme.onPrimary : scheme.onSurfaceVariant)),
                  const SizedBox(width: 9),
                  Flexible(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(items[i].$3, style: GoogleFonts.outfit(fontSize: 9, color: scheme.onSurfaceVariant)),
                    Text(items[i].$2, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 12,
                      fontWeight: FontWeight.w900, color: selectedIndex == i ? scheme.primary : scheme.onSurface)),
                  ])),
                ],
              )),
            ),
          )),
      ]),
    ));
  }
}

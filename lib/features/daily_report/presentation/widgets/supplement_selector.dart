import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SupplementSelector extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const SupplementSelector({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<SupplementSelector> createState() => _SupplementSelectorState();
}

class _SupplementSelectorState extends State<SupplementSelector> {
  bool _zandrosChecked = false;
  bool _totavitChecked = false;
  late final TextEditingController _customNotesController;

  @override
  void initState() {
    super.initState();
    _customNotesController = TextEditingController();
    _parseInitialValue();
  }

  void _parseInitialValue() {
    final text = widget.initialValue;
    if (text.isEmpty) return;

    if (text.toLowerCase().contains('zandros') || text.contains('زندروس')) {
      _zandrosChecked = true;
    }
    if (text.toLowerCase().contains('totavit') || text.contains('توتافيت')) {
      _totavitChecked = true;
    }

    String custom = text
        .replaceAll(RegExp(r'Zandros|زندروس', caseSensitive: false), '')
        .replaceAll(RegExp(r'Totavit|توتافيت', caseSensitive: false), '')
        .replaceAll('+', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();

    _customNotesController.text = custom;
  }

  @override
  void dispose() {
    _customNotesController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final selected = <String>[];
    if (_zandrosChecked) selected.add('Zandros');
    if (_totavitChecked) selected.add('Totavit');

    final customText = _customNotesController.text.trim();

    if (selected.isEmpty && customText.isEmpty) {
      widget.onChanged('');
      return;
    }

    final combinedSelected = selected.join(' + ');
    if (customText.isNotEmpty) {
      if (combinedSelected.isNotEmpty) {
        widget.onChanged('$combinedSelected ($customText)');
      } else {
        widget.onChanged(customText);
      }
    } else {
      widget.onChanged(combinedSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المكملات والفيتامينات (Supplements / Vitamins)',
              style: GoogleFonts.notoKufiArabic(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(
                      'Zandros (زندروس)',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: _zandrosChecked,
                    activeColor: colorScheme.primary,
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    onChanged: (val) {
                      setState(() {
                        _zandrosChecked = val ?? false;
                        _notifyChange();
                      });
                    },
                  ),
                  Divider(
                    height: 1,
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  CheckboxListTile(
                    title: Text(
                      'Totavit (توتافيت)',
                      style: GoogleFonts.notoKufiArabic(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: _totavitChecked,
                    activeColor: colorScheme.primary,
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    onChanged: (val) {
                      setState(() {
                        _totavitChecked = val ?? false;
                        _notifyChange();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _customNotesController,
              style: GoogleFonts.notoKufiArabic(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                labelText: 'مكملات أخرى / إضافات (اختياري)',
                labelStyle: GoogleFonts.notoKufiArabic(
                  fontSize: 11,
                  color: colorScheme.onSurfaceVariant,
                ),
                prefixIcon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                filled: true,
                fillColor: theme.cardColor,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => _notifyChange(),
            ),
          ],
        ),
      ),
    );
  }
}

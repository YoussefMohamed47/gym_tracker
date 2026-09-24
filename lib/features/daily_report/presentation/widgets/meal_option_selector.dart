import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/nutrition_catalog.dart';

class MealOptionSelector extends StatefulWidget {
  final String label;
  final List<MealCategoryOptions> categories;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const MealOptionSelector({
    super.key,
    required this.label,
    required this.categories,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<MealOptionSelector> createState() => _MealOptionSelectorState();
}

class _MealOptionSelectorState extends State<MealOptionSelector> {
  late final Map<String, String?> _selectedOptions;
  late final TextEditingController _customNotesController;
  late final TextEditingController _freeTextController;
  bool _isFreeTextMode = false;

  @override
  void initState() {
    super.initState();
    _selectedOptions = {};
    for (final cat in widget.categories) {
      _selectedOptions[cat.categoryName] = null;
    }

    _customNotesController = TextEditingController();
    _freeTextController = TextEditingController(text: widget.initialValue);

    _parseInitialValue();
  }

  void _parseInitialValue() {
    if (widget.initialValue.trim().isEmpty) return;

    final initialText = widget.initialValue;
    bool matchedAny = false;

    for (final cat in widget.categories) {
      for (final option in cat.options) {
        if (initialText.contains(option)) {
          _selectedOptions[cat.categoryName] = option;
          matchedAny = true;
          break;
        }
      }
    }

    if (!matchedAny) {
      _isFreeTextMode = true;
      _freeTextController.text = initialText;
    }
  }

  @override
  void dispose() {
    _customNotesController.dispose();
    _freeTextController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    if (_isFreeTextMode) {
      widget.onChanged(_freeTextController.text.trim());
      return;
    }

    final selected = widget.categories
        .map((cat) => _selectedOptions[cat.categoryName])
        .where((opt) => opt != null && opt.isNotEmpty)
        .cast<String>()
        .toList();

    final customNotes = _customNotesController.text.trim();

    if (selected.isEmpty && customNotes.isEmpty) {
      widget.onChanged('');
      return;
    }

    final String combinedSelected = selected.join(' + ');
    if (customNotes.isNotEmpty) {
      if (combinedSelected.isNotEmpty) {
        widget.onChanged('$combinedSelected ($customNotes)');
      } else {
        widget.onChanged(customNotes);
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: GoogleFonts.notoKufiArabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFreeTextMode = !_isFreeTextMode;
                      _notifyChange();
                    });
                  },
                  icon: Icon(
                    _isFreeTextMode
                        ? Icons.list_alt_rounded
                        : Icons.edit_note_rounded,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    _isFreeTextMode ? 'خيارات الخطة' : 'كتابة حرة',
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_isFreeTextMode) ...[
              TextFormField(
                controller: _freeTextController,
                maxLines: 2,
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب مكونات الوجبة هنا...',
                  hintStyle: GoogleFonts.notoKufiArabic(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                onChanged: (_) => _notifyChange(),
              ),
            ] else ...[
              for (final category in widget.categories) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedOptions[category.categoryName],
                    isExpanded: true,
                    menuMaxHeight: 220,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    style: GoogleFonts.notoKufiArabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    dropdownColor: theme.cardColor,
                    decoration: InputDecoration(
                      labelText: category.categoryName,
                      labelStyle: GoogleFonts.notoKufiArabic(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: theme.cardColor,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      suffixIcon: _selectedOptions[category.categoryName] != null
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                setState(() {
                                  _selectedOptions[category.categoryName] = null;
                                  _notifyChange();
                                });
                              },
                            )
                          : null,
                    ),
                    items: category.options.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: GoogleFonts.notoKufiArabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedOptions[category.categoryName] = newValue;
                        _notifyChange();
                      });
                    },
                  ),
                ),
              ],
              const SizedBox(height: 2),
              TextFormField(
                controller: _customNotesController,
                style: GoogleFonts.notoKufiArabic(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  labelText: 'إضافات / ملاحظات خاصة (اختياري)',
                  labelStyle: GoogleFonts.notoKufiArabic(
                    fontSize: 10,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  filled: true,
                  fillColor: theme.cardColor,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (_) => _notifyChange(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/datasources/nutrition_catalog.dart';
import '../../domain/model/meal_entry.dart';
import '../../../../core/widgets/athletic_ui.dart';

/// One focused meal workspace. No food selection is encoded as a UI string:
/// persisted entries have separate identity, quantity, unit and dietary notes.
class MealOptionSelector extends StatefulWidget {
  final String label;
  final List<MealCategoryOptions> categories;
  final String initialValue;
  final List<MealEntry> initialEntries;
  final ValueChanged<String> onChanged;
  final ValueChanged<List<MealEntry>>? onEntriesChanged;

  const MealOptionSelector({
    super.key,
    required this.label,
    required this.categories,
    required this.initialValue,
    required this.onChanged,
    this.initialEntries = const [],
    this.onEntriesChanged,
  });

  @override
  State<MealOptionSelector> createState() => _MealOptionSelectorState();
}

class _MealOptionSelectorState extends State<MealOptionSelector> {
  late List<MealEntry> _items;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  void _restore() {
    if (widget.initialEntries.isNotEmpty) {
      _items = List.of(widget.initialEntries);
    } else if (widget.initialValue.trim().isNotEmpty) {
      // Existing unstructured records are preserved exactly, not guessed apart.
      _items = [MealEntry(name: widget.initialValue, category: 'Legacy')];
    } else {
      _items = [];
    }
  }

  @override
  void didUpdateWidget(covariant MealOptionSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue &&
        mealEntriesToLegacyText(_items) != widget.initialValue) {
      _restore();
    }
  }

  void _commit(List<MealEntry> newItems) {
    setState(() => _items = List.unmodifiable(newItems));
    if (widget.onEntriesChanged != null) {
      widget.onEntriesChanged!(_items);
    } else {
      widget.onChanged(mealEntriesToLegacyText(_items));
    }
  }

  void _selectCategory(MealCategoryOptions category) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.categoryName, style: GoogleFonts.cairo(fontSize: 21, fontWeight: FontWeight.w800)),
                Text('اختار العنصر من الخطة الغذائية', style: GoogleFonts.cairo(fontSize: 12, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Flexible(child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: category.options.length,
                  separatorBuilder: (_, __) => Divider(color: scheme.outline.withValues(alpha: .3)),
                  itemBuilder: (_, index) {
                    final food = category.options[index];
                    final entry = FoodOptionParser.fromCatalog(food, category.categoryName);
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(entry.name, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: entry.note == null ? null : Text(entry.note!, style: GoogleFonts.cairo(fontSize: 11)),
                      trailing: Text(entry.displayQuantity.isEmpty ? 'إضافة' : entry.displayQuantity,
                        style: GoogleFonts.cairo(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.w800)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        // Same category replaces its previous planned choice,
                        // matching the original one-option-per-category behavior.
                        final list = _items.where((item) => item.category != category.categoryName).toList();
                        list.add(entry);
                        _commit(list);
                      },
                    );
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  static double? _parseNumber(String raw) {
    const digits = '٠١٢٣٤٥٦٧٨٩۰۱۲۳۴۵۶۷۸۹';
    final normalized = raw.trim().replaceAllMapped(RegExp(r'[٠-٩۰-۹]'),
      (match) => '${digits.indexOf(match.group(0)!) % 10}').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _editQuantity(int index) async {
    final item = _items[index];
    final controller = TextEditingController(text: item.quantity == null ? '' : item.quantity!.toStringAsFixed(item.quantity! % 1 == 0 ? 0 : 1));
    String unit = item.unit ?? 'جم';
    final result = await showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(builder: (context, update) {
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: EdgeInsets.fromLTRB(22, 8, 22, MediaQuery.viewInsetsOf(context).bottom + 30),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(item.name, style: GoogleFonts.cairo(fontSize: 19, fontWeight: FontWeight.w800)),
            if (item.note?.isNotEmpty == true) Text(item.note!, style: GoogleFonts.cairo(fontSize: 12, color: scheme.onSurfaceVariant)),
            const SizedBox(height: 22),
            Text('الكمية', style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: TextField(
                autofocus: true,
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹.,]'))],
                decoration: const InputDecoration(hintText: '0'),
              )),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: ['جم', 'مل', 'قطعة'].contains(unit) ? unit : 'جم',
                items: ['جم', 'مل', 'قطعة'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (selected) { if (selected != null) update(() => unit = selected); },
              ),
            ]),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () {
                final normalized = controller.text.trim();
                final n = _parseNumber(normalized);
                if (normalized.isNotEmpty && (n == null || !n.isFinite || n <= 0)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل كمية صحيحة أكبر من صفر')));
                  return;
                }
                Navigator.pop(context, MealEntry(
                  name: item.name, category: item.category, quantity: n,
                  unit: normalized.isEmpty ? null : unit,
                  note: item.note, catalogOption: item.catalogOption,
                ));
              },
              child: const Text('حفظ الكمية'),
            ),
          ]),
        );
      }),
    );
    controller.dispose();
    if (!mounted || result == null) return;
    final list = List<MealEntry>.of(_items);
    if (index >= list.length) return;
    list[index] = result;
    _commit(list);
  }

  Future<void> _addCustom() async {
    final nameController = TextEditingController();
    final qtyController = TextEditingController();
    final result = await showModalBottomSheet<MealEntry>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(22, 8, 22, MediaQuery.viewInsetsOf(context).bottom + 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('إضافة طعام مخصص', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 18),
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم الطعام')),
          const SizedBox(height: 12),
          TextField(controller: qtyController, keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9٠-٩۰-۹.,]'))], decoration: const InputDecoration(labelText: 'الكمية بالجرام (اختياري)')),
          const SizedBox(height: 18),
          FilledButton(onPressed: () {
            final name = nameController.text.trim();
            final raw = qtyController.text.trim();
            final amount = raw.isEmpty ? null : _parseNumber(raw);
            if (name.isEmpty || (raw.isNotEmpty && (amount == null || amount <= 0))) return;
            Navigator.pop(context, MealEntry(name: name, category: 'Custom', quantity: amount, unit: amount == null ? null : 'جم'));
          }, child: const Text('إضافة للوجبة')),
        ]),
      ),
    );
    nameController.dispose();
    qtyController.dispose();
    if (mounted && result != null) _commit([..._items, result]);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (_items.isEmpty)
        const AthleticEmpty(
          icon: Icons.ramen_dining_rounded,
          title: 'الوجبة لسه فاضية',
          subtitle: 'اختار عناصر من الخطة أو أضف طعام مخصص.',
        )
      else ...[
        for (var i = 0; i < _items.length; i++) ...[
          Material(
            color: i.isEven ? scheme.surfaceContainerHigh.withValues(alpha: 0.46) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(children: [
                Container(width: 3, height: 36, decoration: BoxDecoration(color: scheme.primary, borderRadius: BorderRadius.circular(8))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_items[i].name, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w700)),
                  if (_items[i].note?.isNotEmpty == true)
                    Text(_items[i].note!, style: GoogleFonts.cairo(fontSize: 10, color: scheme.onSurfaceVariant)),
                  Text(_items[i].category, style: GoogleFonts.cairo(fontSize: 10, color: scheme.onSurfaceVariant)),
                ])),
                TextButton(
                  onPressed: () => _editQuantity(i),
                  child: Text(_items[i].displayQuantity.isEmpty ? 'حدد الكمية' : _items[i].displayQuantity,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
                IconButton(tooltip: 'حذف', icon: Icon(Icons.close_rounded, size: 18, color: scheme.error),
                  onPressed: () => _commit([..._items]..removeAt(i))),
              ]),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ],
      const SizedBox(height: 14),
      Text('أضف من الخطة', style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w800, color: scheme.onSurfaceVariant)),
      const SizedBox(height: 10),
      Wrap(spacing: 7, runSpacing: 7, children: [
        for (final category in widget.categories)
          ActionChip(
            onPressed: () => _selectCategory(category),
            avatar: Icon(Icons.add_rounded, size: 16, color: scheme.primary),
            label: Text(category.categoryName, style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ActionChip(onPressed: _addCustom, avatar: const Icon(Icons.edit_note_rounded, size: 16),
          label: Text('طعام مخصص', style: GoogleFonts.cairo(fontSize: 11))),
      ]),
    ]);
  }
}

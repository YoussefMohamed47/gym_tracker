import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/theme_transition_controller.dart';
import '../../../../core/utils/widget_image_capture.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubit/daily_report_cubit.dart';
import '../cubit/daily_report_state.dart';
import '../widgets/daily_meals_report_card.dart';
import '../widgets/daily_report_form.dart';
import '../widgets/report_completion_header.dart';
import '../../../workout/domain/repositories/workout_catalog_repository.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});
  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final GlobalKey _themeButtonKey = GlobalKey();
  bool _preview = false;
  int _formVersion = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catalogRepo = di.sl<WorkoutCatalogRepository>();
    final trainingOptions = catalogRepo.getEightDayRotation().map((e) => e.title).toSet().toList();
    if (!trainingOptions.contains('Cardio')) trainingOptions.add('Cardio');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        automaticallyImplyLeading: false,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('THE DAILY EDIT', style: GoogleFonts.outfit(fontSize: 23, fontWeight: FontWeight.w900, letterSpacing: -0.7)),
          Text(DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: scheme.onSurfaceVariant)),
        ]),
        actions: [
          IconButton(tooltip: 'نسخ آخر تقرير', icon: const Icon(Icons.auto_fix_high_rounded),
            onPressed: () {
              context.read<DailyReportCubit>().copyFromYesterday();
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('تم نسخ آخر تقرير متاح')));
            }),
          IconButton(key: _themeButtonKey, tooltip: 'Change theme',
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: () => di.sl<ThemeTransitionController>().animateThemeToggle(
              context: context, buttonKey: _themeButtonKey,
              onToggle: () => context.read<ThemeCubit>().toggleTheme())),
          IconButton(tooltip: 'التقارير السابقة', icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRouter.history)),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<DailyReportCubit, DailyReportState>(
        listener: (context, state) {
          if (state is DailyReportSuccess) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(const SnackBar(duration: Duration(seconds: 2), content: Text('تم حفظ التقرير')));
            SharePlus.instance.share(ShareParams(files: [XFile(state.imagePath)], text: 'تقرير الوجبات اليومي عبر SAMAFIT'));
            context.read<DailyReportCubit>().resetForm();
          } else if (state is DailyReportError) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(duration: const Duration(seconds: 2), content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) => Stack(children: [
          Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 4, 20, 10), child: Row(children: [
              _modeButton(context, title: 'سجّل اليوم', icon: Icons.edit_note_rounded, selected: !_preview,
                onTap: () => setState(() => _preview = false)),
              const SizedBox(width: 10),
              _modeButton(context, title: 'معاينة التقرير', icon: Icons.receipt_long_outlined, selected: _preview,
                onTap: () => setState(() => _preview = true)),
            ])),
            Expanded(child: _preview
              ? DailyMealsReportCard(report: state.report, isExportMode: false)
              : SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 32),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    ReportCompletionHeader(report: state.report),
                    DailyReportForm(
                      key: ValueKey('${state.report.id}-$_formVersion'),
                      report: state.report,
                      trainingOptions: trainingOptions,
                      onChanged: (r) => context.read<DailyReportCubit>().updateField(
                        breakfast: r.breakfast, lunch: r.lunch, dinner: r.dinner, snack: r.snack,
                        beforeTraining: r.beforeTraining, afterTraining: r.afterTraining,
                        breakfastEntries: r.breakfastEntries, lunchEntries: r.lunchEntries,
                        dinnerEntries: r.dinnerEntries, snackEntries: r.snackEntries,
                        beforeTrainingEntries: r.beforeTrainingEntries, afterTrainingEntries: r.afterTrainingEntries,
                        water: r.water, training: r.training, cardio: r.cardio,
                        supplements: r.supplements, sleepTime: r.sleepTime, notes: r.notes,
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(height: 58, child: FilledButton.icon(
                      onPressed: state is DailyReportGeneratingImage || state.report.isEmpty ? null : () async {
                        HapticFeedback.mediumImpact();
                        if (state.report.water.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إدخال كمية المياه')));
                          return;
                        }
                        final bytes = await WidgetImageCapture.capture(context: context,
                          child: DailyMealsReportCard(report: state.report, isExportMode: true),
                          width: 390, pixelRatio: 3.0);
                        if (context.mounted) context.read<DailyReportCubit>().generateAndCacheImage(bytes);
                      },
                      icon: const Icon(Icons.arrow_outward_rounded), label: Text('حفظ ومشاركة التقرير', style: GoogleFonts.cairo(fontWeight: FontWeight.w800)),
                    )),
                    const SizedBox(height: 110),
                  ]),
                )),
          ]),
          if (state is DailyReportGeneratingImage)
            ColoredBox(color: Colors.black54,
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                CircularProgressIndicator(color: scheme.primary),
                const SizedBox(height: 18),
                Text('جاري تجهيز التقرير...', style: GoogleFonts.cairo(color: Colors.white)),
              ]))),
        ]),
      ),
    );
  }

  Widget _modeButton(BuildContext context, {required String title, required IconData icon,
      required bool selected, required VoidCallback onTap}) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(child: Material(
      color: selected ? scheme.primary : scheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(borderRadius: BorderRadius.circular(12), onTap: onTap,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6), child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 18, color: selected ? scheme.onPrimary : scheme.onSurfaceVariant),
            const SizedBox(width: 6), Flexible(child: Text(title, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w800,
                color: selected ? scheme.onPrimary : scheme.onSurface)))],
        )),
      ),
    ));
  }
}

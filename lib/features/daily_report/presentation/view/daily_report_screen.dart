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
import '../cubit/nutrition_insights_cubit.dart';
import '../../domain/models/nutrition_insights.dart';
import '../widgets/today_summary_card.dart';
import '../../../workout/domain/repositories/workout_catalog_repository.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});
  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final GlobalKey _themeButtonKey = GlobalKey();
  bool _preview = false;
  final int _formVersion = 0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catalogRepo = di.sl<WorkoutCatalogRepository>();
    final trainingOptions = catalogRepo
        .getEightDayRotation()
        .map((e) => e.title)
        .toSet()
        .toList();
    if (!trainingOptions.contains('Cardio')) trainingOptions.add('Cardio');

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 78,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE DAILY EDIT',
              style: GoogleFonts.outfit(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.7,
              ),
            ),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'نسخ آخر تقرير',
            icon: const Icon(Icons.auto_fix_high_rounded),
            onPressed: () {
              context.read<DailyReportCubit>().copyFromYesterday();
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    content: Text('تم نسخ آخر تقرير متاح'),
                  ),
                );
            },
          ),
          IconButton(
            key: _themeButtonKey,
            tooltip: 'Change theme',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () =>
                di.sl<ThemeTransitionController>().animateThemeToggle(
                  context: context,
                  buttonKey: _themeButtonKey,
                  onToggle: () => context.read<ThemeCubit>().toggleTheme(),
                ),
          ),
          IconButton(
            tooltip: 'التقارير السابقة',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRouter.history),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<DailyReportCubit, DailyReportState>(
        listener: (context, state) {
          if (state is DailyReportSuccess) {
            final shared = state.report;
            final cubit = context.read<DailyReportCubit>();
            context.read<NutritionInsightsCubit>().load();
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 4),
                  // A SnackBar with an action stays until dismissed unless
                  // told otherwise; this one should go away on its own.
                  persist: false,
                  content: const Text('تم حفظ التقرير'),
                  action: SnackBarAction(
                    label: 'تراجع',
                    // Bring the shared report back into the form to fix it.
                    onPressed: () => cubit.restoreReport(shared),
                  ),
                ),
              );
            SharePlus.instance.share(
              ShareParams(
                files: [XFile(state.imagePath)],
                text: 'تقرير الوجبات اليومي عبر SAMAFIT',
              ),
            );
            setState(() => _preview = false);
            cubit.resetForm();
          } else if (state is DailyReportError) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  content: Text('Error: ${state.message}'),
                ),
              );
          }
        },
        builder: (context, state) {
          final cubit = context.read<DailyReportCubit>();
          final busy = state is DailyReportGeneratingImage;
          return Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                    child: Row(
                      children: [
                        _modeButton(
                          context,
                          title: 'سجّل اليوم',
                          icon: Icons.edit_note_rounded,
                          selected: !_preview,
                          onTap: () => setState(() => _preview = false),
                        ),
                        const SizedBox(width: 10),
                        _modeButton(
                          context,
                          title: 'معاينة التقرير',
                          icon: Icons.receipt_long_outlined,
                          selected: _preview,
                          onTap: () => setState(() => _preview = true),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _preview
                        ? DailyMealsReportCard(
                            report: state.report,
                            showShareButton: false,
                          )
                        : SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                BlocBuilder<
                                  NutritionInsightsCubit,
                                  NutritionInsights
                                >(
                                  builder: (context, insights) =>
                                      TodaySummaryCard(
                                        report: state.report,
                                        insights: insights,
                                        waterTargetLiters:
                                            cubit.waterTargetLiters,
                                      ),
                                ),
                                const SizedBox(height: 26),
                                BlocBuilder<
                                  NutritionInsightsCubit,
                                  NutritionInsights
                                >(
                                  builder: (context, insights) =>
                                      DailyReportForm(
                                        key: ValueKey(
                                          '${state.report.id}-$_formVersion',
                                        ),
                                        report: state.report,
                                        trainingOptions: trainingOptions,
                                        usualMeals: insights.usualMeals,
                                        waterTargetLiters:
                                            cubit.waterTargetLiters,
                                        onWaterTargetChanged: (liters) async {
                                          await cubit.setWaterTargetLiters(
                                            liters,
                                          );
                                          if (mounted) setState(() {});
                                        },
                                        onChanged: (r) => cubit.updateField(
                                          breakfast: r.breakfast,
                                          lunch: r.lunch,
                                          dinner: r.dinner,
                                          snack: r.snack,
                                          beforeTraining: r.beforeTraining,
                                          afterTraining: r.afterTraining,
                                          breakfastEntries: r.breakfastEntries,
                                          lunchEntries: r.lunchEntries,
                                          dinnerEntries: r.dinnerEntries,
                                          snackEntries: r.snackEntries,
                                          beforeTrainingEntries:
                                              r.beforeTrainingEntries,
                                          afterTrainingEntries:
                                              r.afterTrainingEntries,
                                          water: r.water,
                                          training: r.training,
                                          cardio: r.cardio,
                                          supplements: r.supplements,
                                          sleepTime: r.sleepTime,
                                          notes: r.notes,
                                        ),
                                      ),
                                ),
                                const SizedBox(height: 24),
                                // In the form the action sits at the end, so it
                                // never covers what you are editing.
                                _primaryButton(context, state, busy),
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              // On the preview tab the share action is pinned above the nav
              // bar (the preview reserves space for it); hidden while typing.
              if (_preview && MediaQuery.viewInsetsOf(context).bottom == 0)
                Positioned(
                  left: 20,
                  right: 20,
                  // The bottom padding already includes the floating nav bar.
                  bottom: MediaQuery.paddingOf(context).bottom + 12,
                  child: _primaryButton(context, state, busy),
                ),
              if (busy)
                ColoredBox(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: scheme.primary),
                        const SizedBox(height: 18),
                        Text(
                          'جاري تجهيز التقرير...',
                          style: GoogleFonts.cairo(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _primaryButton(
    BuildContext context,
    DailyReportState state,
    bool busy,
  ) {
    return SizedBox(
      height: 54,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        onPressed: busy || state.report.isEmpty
            ? null
            : _preview
            ? () => _share(context, state)
            : () {
                HapticFeedback.selectionClick();
                FocusManager.instance.primaryFocus?.unfocus();
                setState(() => _preview = true);
              },
        icon: Icon(
          _preview ? Icons.ios_share_rounded : Icons.arrow_forward_rounded,
        ),
        label: Text(
          _preview ? 'حفظ ومشاركة التقرير' : 'Preview report',
          style: _preview
              ? GoogleFonts.cairo(fontWeight: FontWeight.w800)
              : GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15),
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, DailyReportState state) async {
    HapticFeedback.mediumImpact();
    if (state.report.water.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال كمية المياه')));
      setState(() => _preview = false);
      return;
    }
    final bytes = await WidgetImageCapture.capture(
      context: context,
      child: DailyMealsReportCard(report: state.report, isExportMode: true),
      width: 390,
      pixelRatio: 3.0,
    );
    if (context.mounted) {
      context.read<DailyReportCubit>().generateAndCacheImage(bytes);
    }
  }

  Widget _modeButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: selected ? scheme.primary : scheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

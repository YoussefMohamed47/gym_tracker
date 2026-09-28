import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/report_theme_tokens.dart';
import '../../../../core/theme/theme_transition_controller.dart';
import '../../../../core/utils/widget_image_capture.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../cubit/daily_report_cubit.dart';
import '../cubit/daily_report_state.dart';
import '../widgets/daily_meals_report_card.dart';
import '../widgets/daily_report_form.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final GlobalKey _themeButtonKey = GlobalKey();
  int _selectedViewIndex = 0; // 0 = Form, 1 = Live Report Card

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            key: _themeButtonKey,
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              di.sl<ThemeTransitionController>().animateThemeToggle(
                    context: context,
                    buttonKey: _themeButtonKey,
                    onToggle: () => context.read<ThemeCubit>().toggleTheme(),
                  );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.history);
            },
          ),
        ],
      ),
      body: BlocConsumer<DailyReportCubit, DailyReportState>(
        listener: (context, state) {
          if (state is DailyReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report saved to history!')),
            );
            SharePlus.instance.share(
              ShareParams(
                files: [XFile(state.imagePath)],
                text: 'تقرير الوجبات اليومي عبر SAMAFIT',
              ),
            );
            context.read<DailyReportCubit>().resetForm();
          } else if (state is DailyReportError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  // Mode Switcher Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment<int>(
                          value: 0,
                          label: Text('تعديل البيانات'),
                          icon: Icon(Icons.edit_note_rounded),
                        ),
                        ButtonSegment<int>(
                          value: 1,
                          label: Text('معاينة التقرير'),
                          icon: Icon(Icons.analytics_rounded),
                        ),
                      ],
                      selected: {_selectedViewIndex},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedViewIndex = newSelection.first;
                        });
                      },
                    ),
                  ),

                  // View Content
                  Expanded(
                    child: _selectedViewIndex == 0
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                DailyReportForm(
                                  key: ValueKey(state.report.id),
                                  report: state.report,
                                  onChanged: (updatedReport) {
                                    context.read<DailyReportCubit>().updateField(
                                          breakfast: updatedReport.breakfast,
                                          lunch: updatedReport.lunch,
                                          snack: updatedReport.snack,
                                          beforeTraining: updatedReport.beforeTraining,
                                          afterTraining: updatedReport.afterTraining,
                                          dinner: updatedReport.dinner,
                                          water: updatedReport.water,
                                          training: updatedReport.training,
                                          cardio: updatedReport.cardio,
                                          supplements: updatedReport.supplements,
                                          sleepTime: updatedReport.sleepTime,
                                          notes: updatedReport.notes,
                                        );
                                  },
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: (state is DailyReportGeneratingImage ||
                                          state.report.isEmpty)
                                      ? null
                                      : () async {
                                          final imageBytes =
                                              await WidgetImageCapture.capture(
                                            context: context,
                                            child: DailyMealsReportCard(
                                              report: state.report,
                                              isExportMode: true,
                                            ),
                                            width: 390,
                                            pixelRatio: 3.0,
                                          );
                                          if (context.mounted) {
                                            context
                                                .read<DailyReportCubit>()
                                                .generateAndCacheImage(imageBytes);
                                          }
                                        },
                                  icon: const Icon(Icons.auto_awesome_rounded),
                                  label: const Text('حفظ ومشاركة التقرير'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ReportThemeTokens.indigoAccent,
                                    minimumSize: const Size(double.infinity, 56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                          )
                        : DailyMealsReportCard(
                            report: state.report,
                            isExportMode: false,
                          ),
                  ),
                ],
              ),

              if (state is DailyReportGeneratingImage)
                Container(
                  color: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.6),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitFadingCircle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 50.0,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'جاري تجهيز التقرير...',
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
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
}

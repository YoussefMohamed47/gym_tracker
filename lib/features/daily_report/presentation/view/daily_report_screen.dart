import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/widget_image_capture.dart'; // ⚠️ CRITICAL: new import
import '../cubit/daily_report_cubit.dart';
import '../cubit/daily_report_state.dart';
import '../widgets/daily_report_form.dart';
import '../widgets/report_image_template.dart';
import 'package:share_plus/share_plus.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  // ⚠️ CRITICAL: ScreenshotController / screenshot package no longer needed
  // for this flow — removed to avoid the tight-constraints overflow.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
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
                text: 'My Daily Report',
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
              SingleChildScrollView(
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
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed:
                          (state is DailyReportGeneratingImage ||
                              state.report.isEmpty)
                          ? null
                          : () async {
                              final Uint8List imageBytes =
                                  await WidgetImageCapture.capture(
                                    context: context,
                                    child: ReportImageTemplate(
                                      report: state.report,
                                    ),
                                    width: 400,
                                    pixelRatio: 2.0,
                                  );
                              if (context.mounted) {
                                context
                                    .read<DailyReportCubit>()
                                    .generateAndCacheImage(imageBytes);
                              }
                            },
                      icon: const Icon(Icons.auto_awesome_rounded),
                      label: const Text('GENERATE & SHARE REPORT'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
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
                          'Generating your report...',
                          style: GoogleFonts.outfit(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
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

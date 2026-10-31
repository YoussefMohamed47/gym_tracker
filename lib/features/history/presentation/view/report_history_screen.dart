import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/daily_report/presentation/cubit/daily_report_cubit.dart';
import '../../../../features/daily_report/presentation/widgets/volume_line_chart.dart';
import '../../../../features/daily_report/presentation/widgets/meal_adherence_radar_chart.dart';
import '../cubit/history_cubit.dart';

class ReportHistoryScreen extends StatefulWidget {
  const ReportHistoryScreen({super.key});

  @override
  State<ReportHistoryScreen> createState() => _ReportHistoryScreenState();
}

class _ReportHistoryScreenState extends State<ReportHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report History'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reports'),
              Tab(text: 'Analytics'),
            ],
          ),
        ),
        body: BlocBuilder<HistoryCubit, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryLoaded) {
              Widget reportsList;
              if (state.reports.isEmpty) {
                reportsList = const Center(child: Text('No reports saved yet.'));
              } else {
                reportsList = ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report = state.reports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        color: Theme.of(context).cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            if (report.imagePath != null)
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRouter.fullScreenImage,
                                    arguments: {
                                      'imagePath': report.imagePath!,
                                      'title': report.dateTime != null
                                          ? DateFormat('MMM d, yyyy').format(report.dateTime!)
                                          : 'Report Image',
                                    },
                                  );
                                },
                                child: AspectRatio(
                                  aspectRatio: 16 / 10,
                                  child: Image.file(
                                    File(report.imagePath!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ListTile(
                              contentPadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
                              title: Text(
                                report.dateTime != null
                                    ? DateFormat('EEEE, MMM d').format(report.dateTime!)
                                    : 'Unknown Date',
                                style: const TextStyle(fontWeight: FontWeight.w900),
                              ),
                              subtitle: Text(
                                report.dateTime != null
                                    ? DateFormat('hh:mm a').format(report.dateTime!)
                                    : '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.settings_backup_restore_rounded),
                                    color: Theme.of(context).colorScheme.primary,
                                    onPressed: () {
                                      context.read<DailyReportCubit>().restoreReport(report);
                                      Navigator.pop(context);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded),
                                    color: Theme.of(context).colorScheme.error,
                                    onPressed: () {
                                      context.read<HistoryCubit>().deleteReport(report.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return TabBarView(
                children: [
                  reportsList,
                  _buildAnalyticsTab(state),
                ],
              );
            } else if (state is HistoryError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(HistoryLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '30-Day Training Volume',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.volumeReport != null)
            VolumeLineChart(report: state.volumeReport!)
          else
            const Center(child: Text('Volume data unavailable')),
          const SizedBox(height: 32),
          const Text(
            'Meal & Supplement Adherence',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.mealAdherence != null)
            MealAdherenceRadarChart(data: state.mealAdherence!)
          else
            const Center(child: Text('Adherence data unavailable')),
        ],
      ),
    );
  }
}

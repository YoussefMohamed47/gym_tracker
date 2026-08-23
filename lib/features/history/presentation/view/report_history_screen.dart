import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../features/daily_report/presentation/cubit/daily_report_cubit.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Report History'), centerTitle: true),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryLoaded) {
            if (state.reports.isEmpty) {
              return const Center(child: Text('No reports saved yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                final report = state.reports[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
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
                                    ? DateFormat(
                                        'MMM d, yyyy',
                                      ).format(report.dateTime!)
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
                              ? DateFormat(
                                  'EEEE, MMM d',
                                ).format(report.dateTime!)
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
                                context.read<DailyReportCubit>().restoreReport(
                                  report,
                                );
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () {
                                context.read<HistoryCubit>().deleteReport(
                                  report.id,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (state is HistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

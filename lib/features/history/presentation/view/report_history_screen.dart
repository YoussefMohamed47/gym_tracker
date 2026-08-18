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
      appBar: AppBar(
        title: const Text('Report History'),
        centerTitle: true,
      ),
      body: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryLoaded) {
            if (state.reports.isEmpty) {
              return const Center(child: Text('No reports saved yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.reports.length,
              itemBuilder: (context, index) {
                final report = state.reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
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
                            aspectRatio: 1000 / 700,
                            child: Image.file(
                              File(report.imagePath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ListTile(
                        title: Text(
                          report.dateTime != null
                              ? DateFormat('EEEE, MMM d, yyyy - hh:mm a')
                                  .format(report.dateTime!)
                              : 'Unknown Date',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.restore, color: Colors.blue),
                              onPressed: () {
                                context.read<DailyReportCubit>().restoreReport(report);
                                Navigator.pop(context);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<HistoryCubit>().deleteReport(report.id);
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

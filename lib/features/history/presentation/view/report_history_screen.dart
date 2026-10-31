import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/athletic_ui.dart';
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
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('THE ARCHIVE'),
        actions: [IconButton(tooltip: 'Refresh', onPressed: () => context.read<HistoryCubit>().loadHistory(),
          icon: const Icon(Icons.refresh_rounded)), const SizedBox(width: 12)]),
      body: BlocBuilder<HistoryCubit, HistoryState>(builder: (context, state) {
        if (state is HistoryLoading) return const Center(child: CircularProgressIndicator());
        if (state is HistoryError) return AthleticEmpty(icon: Icons.error_outline, title: 'تعذر تحميل التقارير', subtitle: state.message,
          action: TextButton(onPressed: () => context.read<HistoryCubit>().loadHistory(), child: const Text('إعادة المحاولة')));
        if (state is! HistoryLoaded) return const SizedBox.shrink();
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 18), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('YOUR RECORD.', style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w900,
                letterSpacing: -1.7, height: 1.1)),
              const SizedBox(height: 6),
              Text('${state.reports.length} SAVED REPORTS', style: GoogleFonts.outfit(color: colors.primary,
                fontSize: 12, letterSpacing: 1.6, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              Row(children: [
                _navTab(context, 0, 'REPORTS', Icons.grid_view_outlined),
                const SizedBox(width: 10),
                _navTab(context, 1, 'INSIGHTS', Icons.show_chart_rounded),
              ]),
            ],
          )),
          Expanded(child: _tab == 0 ? _gallery(state) : _insights(state)),
        ]);
      }),
    );
  }

  Widget _navTab(BuildContext context, int index, String text, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    final selected = _tab == index;
    return Expanded(child: Material(color: selected ? colors.primary : colors.surface,
      borderRadius: BorderRadius.circular(12), child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _tab = index),
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, size: 17, color: selected ? colors.onPrimary : colors.onSurfaceVariant),
            const SizedBox(width: 8), Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 12,
              color: selected ? colors.onPrimary : colors.onSurface))],
        )),
      ),
    ));
  }

  Widget _gallery(HistoryLoaded state) {
    final colors = Theme.of(context).colorScheme;
    if (state.reports.isEmpty) return const Center(child: AthleticEmpty(
      icon: Icons.auto_stories_outlined, title: 'مفيش تقارير محفوظة',
      subtitle: 'أول تقرير تحفظه هيظهر هنا.'));
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      itemCount: state.reports.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.68),
      itemBuilder: (context, index) {
        final report = state.reports[index];
        final date = report.dateTime;
        return Material(
          color: colors.surface, borderRadius: BorderRadius.circular(14), clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: InkWell(
              onTap: report.imagePath == null ? null : () => Navigator.pushNamed(context,
                AppRouter.fullScreenImage, arguments: {
                  'imagePath': report.imagePath!,
                  'title': date == null ? 'Report Image' : DateFormat('MMM d, yyyy').format(date),
                }),
              child: SizedBox(width: double.infinity, child: report.imagePath == null
                ? ColoredBox(color: colors.surfaceContainerHigh,
                    child: Center(child: Icon(Icons.description_outlined, size: 40, color: colors.primary)))
                : Image.file(File(report.imagePath!), fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(child: Icon(Icons.broken_image_outlined, color: colors.onSurfaceVariant)))),
            )),
            Padding(padding: const EdgeInsets.fromLTRB(12, 10, 5, 8), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(date == null ? 'Report' : DateFormat('MMM d, yyyy').format(date),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${(report.overallCompletionRatio * 100).round()}% LOGGED',
                  style: GoogleFonts.outfit(color: colors.primary, fontSize: 10, fontWeight: FontWeight.w800)),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(tooltip: 'استرجاع', visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.restore_rounded, color: colors.primary, size: 20),
                    onPressed: () { context.read<DailyReportCubit>().restoreReport(report); Navigator.pop(context); }),
                  IconButton(tooltip: 'حذف', visualDensity: VisualDensity.compact,
                    icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
                    onPressed: () => context.read<HistoryCubit>().deleteReport(report.id)),
                ]),
              ],
            )),
          ]),
        );
      },
    );
  }

  Widget _insights(HistoryLoaded state) {
    final colors = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 30), children: [
      const AthleticSectionTitle(number: '01', title: 'Strength over time', description: 'حجم التمرين خلال آخر ٣٠ يوم.'),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
        child: state.volumeReport == null
          ? const AthleticEmpty(icon: Icons.bar_chart_rounded, title: 'لا توجد بيانات', subtitle: 'سجّل تمارين لعرض تقدمك')
          : VolumeLineChart(report: state.volumeReport!)),
      const SizedBox(height: 28),
      const AthleticSectionTitle(number: '02', title: 'Your consistency', description: 'الالتزام بالوجبات والمكملات.'),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(16)),
        child: state.mealAdherence == null
          ? const AthleticEmpty(icon: Icons.donut_small_rounded, title: 'لا توجد بيانات', subtitle: 'احفظ تقرير يومي لعرض الالتزام')
          : MealAdherenceRadarChart(data: state.mealAdherence!)),
    ]);
  }
}

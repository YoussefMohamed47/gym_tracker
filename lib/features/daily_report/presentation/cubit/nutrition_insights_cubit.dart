import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/nutrition_insights.dart';
import '../../domain/usecases/get_nutrition_insights_usecase.dart';

/// Streak, weekly dots and usual meals for the Nutrition screen. Kept apart
/// from [DailyReportCubit] so the report's own states stay unchanged.
class NutritionInsightsCubit extends Cubit<NutritionInsights> {
  final GetNutritionInsightsUseCase _getInsights;

  NutritionInsightsCubit(this._getInsights) : super(NutritionInsights.empty) {
    load();
  }

  /// Reload after a report is shared, so the streak updates right away.
  Future<void> load() async {
    try {
      final insights = await _getInsights();
      if (!isClosed) emit(insights);
    } catch (e, st) {
      debugPrint('NutritionInsightsCubit: load failed: $e\n$st');
    }
  }
}

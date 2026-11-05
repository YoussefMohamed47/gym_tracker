import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gym_tracker_report/core/error/api_result.dart';
import 'package:gym_tracker_report/features/daily_report/data/datasources/daily_report_draft_store.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/daily_report.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_entry.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/meal_slot.dart';
import 'package:gym_tracker_report/features/daily_report/domain/model/water_amount.dart';
import 'package:gym_tracker_report/features/daily_report/domain/repository/daily_report_repository.dart';
import 'package:gym_tracker_report/features/daily_report/domain/usecases/get_nutrition_insights_usecase.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_cubit.dart';
import 'package:gym_tracker_report/features/daily_report/presentation/cubit/daily_report_state.dart';

class _MockRepo extends Mock implements DailyReportRepository {}

DailyReport _report(DateTime day, {List<MealEntry> lunch = const []}) =>
    DailyReport.empty().copyWith(
      id: day.toIso8601String(),
      dateTime: day,
      water: '3 لتر',
      lunchEntries: lunch,
    );

const _chicken = MealEntry(
  name: 'صدر دجاج مشوي',
  category: 'بروتين',
  quantity: 180,
  unit: 'جم',
);
const _rice = MealEntry(
  name: 'رز أبيض',
  category: 'نشويات',
  quantity: 150,
  unit: 'جم',
);

void main() {
  group('WaterAmount', () {
    test('reads liters, milliliters, glasses and Arabic digits', () {
      expect(WaterAmount.parseLiters('3'), 3);
      expect(WaterAmount.parseLiters('2.5 لتر'), 2.5);
      expect(WaterAmount.parseLiters('750 مل'), .75);
      expect(WaterAmount.parseLiters('1500'), 1.5);
      expect(WaterAmount.parseLiters('8 أكواب'), 2);
      expect(WaterAmount.parseLiters('٢٫٥ لتر'), 2.5);
      expect(WaterAmount.parseLiters(''), isNull);
      expect(WaterAmount.parseLiters('كتير'), isNull);
    });

    test('formats back to readable text', () {
      expect(WaterAmount.format(2), '2 لتر');
      expect(WaterAmount.format(2.25), '2.25 لتر');
    });
  });

  group('MealSlot', () {
    test('withEntries writes entries and keeps the legacy text in sync', () {
      final r = MealSlot.lunch.withEntries(DailyReport.empty(), [_chicken]);
      expect(r.lunchEntries, [_chicken]);
      expect(r.lunch, isNotEmpty);
      expect(MealSlot.lunch.isLogged(r), isTrue);
      expect(MealSlot.dinner.isLogged(r), isFalse);
    });
  });

  group('Training follows the Workout tab', () {
    test('syncTrainingFromWorkout sets the type and ignores empty values', () {
      final cubit = DailyReportCubit(_MockRepo());
      cubit.syncTrainingFromWorkout('Chest & Back');
      expect(cubit.state.report.training, 'Chest & Back');
      cubit.syncTrainingFromWorkout('Legs');
      expect(cubit.state.report.training, 'Legs');
      cubit.syncTrainingFromWorkout('');
      expect(cubit.state.report.training, 'Legs');
    });
  });

  group('DailyReportDraftStore + cubit', () {
    late Directory dir;
    late Box box;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('draft_test');
      Hive.init(dir.path);
      box = await Hive.openBox('prefs_test');
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test(
      'a half-filled day survives a restart, and sharing clears it',
      () async {
        final store = DailyReportDraftStore(box);
        final first = DailyReportCubit(_MockRepo(), draftStore: store);
        first.updateField(water: '1 لتر', lunchEntries: [_chicken]);
        await Future<void>.delayed(Duration.zero);
        await first.close();

        // "Restart": a new cubit picks the draft up.
        final second = DailyReportCubit(_MockRepo(), draftStore: store);
        expect(second.state, isA<DailyReportUpdating>());
        expect(second.state.report.water, '1 لتر');
        expect(second.state.report.lunchEntries, [_chicken]);

        second.resetForm();
        await Future<void>.delayed(Duration.zero);
        expect(store.loadTodayDraft(), isNull);
        await second.close();
      },
    );

    test("yesterday's draft is not restored", () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await DailyReportDraftStore(
        box,
        now: () => yesterday,
      ).saveDraft(DailyReport.empty().copyWith(water: '2'));
      expect(DailyReportDraftStore(box).loadTodayDraft(), isNull);
    });

    test('water target defaults to 3 L and can be changed', () async {
      final store = DailyReportDraftStore(box);
      expect(store.waterTargetLiters, 3.0);
      await store.setWaterTargetLiters(3.5);
      expect(store.waterTargetLiters, 3.5);
    });
  });

  group('GetNutritionInsightsUseCase', () {
    final now = DateTime(2026, 11, 5, 20);
    DateTime day(int ago) => DateTime(2026, 11, 5 - ago, 21);

    Future<dynamic> run(List<DailyReport> reports) {
      final repo = _MockRepo();
      when(
        () => repo.getReportHistory(),
      ).thenAnswer((_) async => ApiSuccess(reports));
      return GetNutritionInsightsUseCase(repo, now: () => now)();
    }

    test(
      'streak counts back from today and allows today to be pending',
      () async {
        final withToday = await run([
          _report(day(0)),
          _report(day(1)),
          _report(day(2)),
          _report(day(4)),
        ]);
        expect(withToday.streakDays, 3);
        expect(withToday.lastSevenDays, [
          false,
          false,
          true,
          false,
          true,
          true,
          true,
        ]);

        final todayPending = await run([_report(day(1)), _report(day(2))]);
        expect(todayPending.streakDays, 2);
      },
    );

    test(
      'usual meal needs at least two repeats and uses latest quantities',
      () async {
        final latestRice = _rice.copyWith(quantity: 200);
        final insights = await run([
          _report(day(1), lunch: [_chicken, latestRice]),
          _report(day(2), lunch: [_rice, _chicken]),
          _report(day(3), lunch: [_chicken]),
        ]);
        expect(insights.usualMeals[MealSlot.lunch], [_chicken, latestRice]);
        expect(insights.usualMeals.containsKey(MealSlot.dinner), isFalse);
      },
    );
  });
}

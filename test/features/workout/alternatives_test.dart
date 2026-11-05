import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_ce/hive.dart';
import 'package:gym_tracker_report/core/utils/app_theme.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/alternatives_library.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/custom_alternatives_store.dart';
import 'package:gym_tracker_report/features/workout/data/datasources/workout_catalog.dart';
import 'package:gym_tracker_report/features/workout/domain/entities/workout_type.dart';
import 'package:gym_tracker_report/features/workout/presentation/widgets/alternatives_sheet.dart';

const _planTypes = [
  WorkoutType.chestAndBack,
  WorkoutType.shoulderAndArms,
  WorkoutType.legs,
  WorkoutType.fullBody,
  WorkoutType.upperAndCalves,
];

/// In-memory store for widget tests: real Hive writes never finish inside the
/// widget tester's fake clock.
class _MemoryStore implements CustomAlternativesStore {
  final _data = <String, List<String>>{};

  @override
  List<String> forExercise(String plannedId) => _data[plannedId] ?? const [];

  @override
  Future<void> add(String plannedId, String exerciseId) async {
    final list = _data[plannedId] ?? <String>[];
    if (exerciseId == plannedId || list.contains(exerciseId)) return;
    _data[plannedId] = [...list, exerciseId];
  }

  @override
  Future<void> remove(String plannedId, String exerciseId) async {
    _data[plannedId]?.remove(exerciseId);
  }
}

void main() {
  group('AlternativesLibrary', () {
    test('every exercise in the 8-day plan has at least 3 alternatives', () {
      for (final type in _planTypes) {
        for (final slot in WorkoutCatalog.getWorkoutByType(type)!.exercises) {
          final alts = AlternativesLibrary.forExercise[slot.exerciseId];
          expect(alts, isNotNull, reason: '${slot.exerciseId} has no list');
          expect(
            alts!.length,
            greaterThanOrEqualTo(3),
            reason: slot.exerciseId,
          );
        }
      }
    });

    test('every new exercise has a real video, reps and how-to steps', () {
      for (final e in AlternativesLibrary.exercises) {
        expect(
          e.videoUrl,
          startsWith('https://www.youtube.com/'),
          reason: e.id,
        );
        expect(e.videoUrl, isNot(contains('search_query')), reason: e.id);
        expect(e.repRange, isNotNull, reason: e.id);
        expect(e.howTo.length, greaterThanOrEqualTo(3), reason: e.id);
      }
    });

    test('search stays within the same muscle group', () {
      final forChest = AlternativesSheet.search(
        'cable',
        sameMuscleAs: 'c_db_chest_press',
      );
      expect(forChest, isNotEmpty);
      for (final e in forChest) {
        expect(
          AlternativesSheet.musclesOf(e.id),
          contains('CHEST'),
          reason: e.name,
        );
      }
      final forCurl = AlternativesSheet.search(
        'curl',
        sameMuscleAs: 'c_db_bicep_curl',
      ).map((e) => e.name);
      expect(forCurl, contains('Bayesian Cable Curl'));
      expect(forCurl, isNot(contains('Lying Leg Curl Machine')));
    });

    test('every alternative is a real exercise, never "Unknown"', () {
      for (final entry in AlternativesLibrary.forExercise.entries) {
        for (final id in entry.value) {
          expect(
            WorkoutCatalog.getExerciseById(id).name,
            isNot('Unknown Exercise'),
            reason: '${entry.key} -> $id',
          );
          expect(id, isNot(entry.key));
        }
      }
    });

    test('search finds by name words and by muscle/equipment tags', () {
      final cableChest = AlternativesSheet.search('cable chest');
      expect(cableChest.map((e) => e.name), contains('Mid Cable Crossover'));
      expect(
        cableChest.every((e) => e.name.toLowerCase().contains('cable')),
        isTrue,
      );
      expect(
        AlternativesSheet.search('dumbbell hammer').map((e) => e.name),
        contains('DB Hammer Curl'),
      );
      expect(
        AlternativesSheet.search('hip thrust').map((e) => e.id),
        contains('alt_barbell_hip_thrust'),
      );
      expect(AlternativesSheet.search('   '), isEmpty);
      expect(
        WorkoutCatalog.searchableExercises.any(
          (e) => e.name.contains('Legacy'),
        ),
        isFalse,
      );
    });
  });

  group('CustomAlternativesStore and the Swap sheet', () {
    late Directory dir;
    late Box box;

    setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('alts_test');
      Hive.init(dir.path);
      box = await Hive.openBox('prefs_alts');
    });

    tearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('add, ignore duplicates and self, remove', () async {
      final store = CustomAlternativesStore(box);
      await store.add('c_db_chest_press', 'alt_push_up');
      await store.add('c_db_chest_press', 'alt_push_up');
      await store.add('c_db_chest_press', 'c_db_chest_press');
      expect(store.forExercise('c_db_chest_press'), ['alt_push_up']);
      expect(CustomAlternativesStore(box).forExercise('c_db_chest_press'), [
        'alt_push_up',
      ]);
      await store.remove('c_db_chest_press', 'alt_push_up');
      expect(store.forExercise('c_db_chest_press'), isEmpty);
    });

    testWidgets('search, + Add saves to the list, Swap picks it', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final store = _MemoryStore();
      String? picked;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => AlternativesSheet(
                      originalExerciseId: 'c_leg_press_machine',
                      currentPerformedId: 'c_leg_press_machine',
                      onSelect: (id) => picked = id,
                      store: store,
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Swap exercise'), findsOneWidget);
      expect(find.text('Hack Squat Machine'), findsOneWidget); // suggested

      await tester.enterText(find.byType(TextField), 'sissy');
      await tester.pump();
      expect(find.textContaining('No exercise matches'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'split squat');
      await tester.pump();
      expect(find.text('DB Bulgarian Split Squat'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'leg curl');
      await tester.pump();
      await tester.tap(find.text('+ Add').first);
      await tester.pump();
      final added = store.forExercise('c_leg_press_machine');
      expect(added, hasLength(1));

      // Clearing the search shows it under "Saved by you".
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();
      expect(find.text('SAVED BY YOU'), findsOneWidget);
      final addedName = WorkoutCatalog.getExerciseById(added.single).name;
      expect(find.text(addedName), findsOneWidget);

      await tester.tap(find.text('Swap').first);
      await tester.pumpAndSettle();
      expect(picked, added.single);

      final error = tester.takeException();
      expect(
        error == null || error.toString().contains('GoogleFonts'),
        isTrue,
        reason: '$error',
      );
    });
  });
}

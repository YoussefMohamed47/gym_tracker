import 'package:equatable/equatable.dart';
import 'meal_entry.dart';

class DailyReport extends Equatable {
  final String id;
  final String breakfast;
  final String lunch;
  final String snack;
  final String beforeTraining;
  final String afterTraining;
  final String dinner;
  final String water;
  final String training;
  final String cardio;
  final String supplements;
  final String sleepTime;
  final String? notes;
  final DateTime? dateTime;
  final String? imagePath;
  final List<MealEntry> breakfastEntries;
  final List<MealEntry> lunchEntries;
  final List<MealEntry> dinnerEntries;
  final List<MealEntry> snackEntries;
  final List<MealEntry> beforeTrainingEntries;
  final List<MealEntry> afterTrainingEntries;

  const DailyReport({
    required this.id,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    required this.beforeTraining,
    required this.afterTraining,
    required this.dinner,
    required this.water,
    required this.training,
    required this.cardio,
    required this.supplements,
    required this.sleepTime,
    this.notes,
    this.dateTime,
    this.imagePath,
    this.breakfastEntries = const [],
    this.lunchEntries = const [],
    this.dinnerEntries = const [],
    this.snackEntries = const [],
    this.beforeTrainingEntries = const [],
    this.afterTrainingEntries = const [],
  });

  bool get isEmpty =>
      breakfast.isEmpty && breakfastEntries.isEmpty &&
      lunch.isEmpty && lunchEntries.isEmpty &&
      snack.isEmpty && snackEntries.isEmpty &&
      beforeTraining.isEmpty && beforeTrainingEntries.isEmpty &&
      afterTraining.isEmpty && afterTrainingEntries.isEmpty &&
      dinner.isEmpty && dinnerEntries.isEmpty &&
      water.isEmpty &&
      training.isEmpty &&
      cardio.isEmpty &&
      supplements.isEmpty &&
      sleepTime.isEmpty &&
      (notes?.isEmpty ?? true);

  double get mealsCompletionRatio {
    int filled = 0;
    if (breakfast.trim().isNotEmpty || breakfastEntries.isNotEmpty) filled++;
    if (lunch.trim().isNotEmpty || lunchEntries.isNotEmpty) filled++;
    if (dinner.trim().isNotEmpty || dinnerEntries.isNotEmpty) filled++;
    if (snack.trim().isNotEmpty || snackEntries.isNotEmpty) filled++;
    return filled / 4.0;
  }

  double get overallCompletionRatio {
    int total = 5;
    int filled = 0;
    if (breakfast.trim().isNotEmpty || breakfastEntries.isNotEmpty || lunch.trim().isNotEmpty || lunchEntries.isNotEmpty || dinner.trim().isNotEmpty || dinnerEntries.isNotEmpty) filled++;
    if (water.trim().isNotEmpty) filled++;
    if (sleepTime.trim().isNotEmpty) filled++;
    if (training.trim().isNotEmpty) filled++;
    if (supplements.trim().isNotEmpty) filled++;
    return filled / total.toDouble();
  }

  factory DailyReport.empty() => DailyReport(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    breakfast: '',
    lunch: '',
    snack: '',
    beforeTraining: '',
    afterTraining: '',
    dinner: '',
    water: '',
    training: '',
    cardio: '',
    supplements: '',
    sleepTime: '',
    notes: '',
  );

  DailyReport copyWith({
    String? id,
    String? breakfast,
    String? lunch,
    String? snack,
    String? beforeTraining,
    String? afterTraining,
    String? dinner,
    String? water,
    String? training,
    String? cardio,
    String? supplements,
    String? sleepTime,
    String? notes,
    DateTime? dateTime,
    String? imagePath,
    List<MealEntry>? breakfastEntries,
    List<MealEntry>? lunchEntries,
    List<MealEntry>? dinnerEntries,
    List<MealEntry>? snackEntries,
    List<MealEntry>? beforeTrainingEntries,
    List<MealEntry>? afterTrainingEntries,
  }) {
    final bEntries = breakfastEntries ?? this.breakfastEntries;
    final lEntries = lunchEntries ?? this.lunchEntries;
    final sEntries = snackEntries ?? this.snackEntries;
    final btEntries = beforeTrainingEntries ?? this.beforeTrainingEntries;
    final atEntries = afterTrainingEntries ?? this.afterTrainingEntries;
    final dEntries = dinnerEntries ?? this.dinnerEntries;

    final bText = breakfast ?? (breakfastEntries != null ? mealEntriesToLegacyText(bEntries) : this.breakfast);
    final lText = lunch ?? (lunchEntries != null ? mealEntriesToLegacyText(lEntries) : this.lunch);
    final sText = snack ?? (snackEntries != null ? mealEntriesToLegacyText(sEntries) : this.snack);
    final btText = beforeTraining ?? (beforeTrainingEntries != null ? mealEntriesToLegacyText(btEntries) : this.beforeTraining);
    final atText = afterTraining ?? (afterTrainingEntries != null ? mealEntriesToLegacyText(atEntries) : this.afterTraining);
    final dText = dinner ?? (dinnerEntries != null ? mealEntriesToLegacyText(dEntries) : this.dinner);

    return DailyReport(
      id: id ?? this.id,
      breakfast: bText,
      lunch: lText,
      snack: sText,
      beforeTraining: btText,
      afterTraining: atText,
      dinner: dText,
      water: water ?? this.water,
      training: training ?? this.training,
      cardio: cardio ?? this.cardio,
      supplements: supplements ?? this.supplements,
      sleepTime: sleepTime ?? this.sleepTime,
      notes: notes ?? this.notes,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
      breakfastEntries: bEntries,
      lunchEntries: lEntries,
      dinnerEntries: dEntries,
      snackEntries: sEntries,
      beforeTrainingEntries: btEntries,
      afterTrainingEntries: atEntries,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'breakfast': breakfast,
      'lunch': lunch,
      'snack': snack,
      'beforeTraining': beforeTraining,
      'afterTraining': afterTraining,
      'dinner': dinner,
      'water': water,
      'training': training,
      'cardio': cardio,
      'supplements': supplements,
      'sleepTime': sleepTime,
      'notes': notes,
      'dateTime': dateTime?.toIso8601String(),
      'imagePath': imagePath,
      'breakfastEntries': breakfastEntries.map((e) => e.toJson()).toList(),
      'lunchEntries': lunchEntries.map((e) => e.toJson()).toList(),
      'dinnerEntries': dinnerEntries.map((e) => e.toJson()).toList(),
      'snackEntries': snackEntries.map((e) => e.toJson()).toList(),
      'beforeTrainingEntries': beforeTrainingEntries.map((e) => e.toJson()).toList(),
      'afterTrainingEntries': afterTrainingEntries.map((e) => e.toJson()).toList(),
    };
  }

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      id: json['id'] as String,
      breakfast: json['breakfast'] as String,
      lunch: json['lunch'] as String,
      snack: json['snack'] as String,
      beforeTraining: json['beforeTraining'] as String,
      afterTraining: json['afterTraining'] as String,
      dinner: json['dinner'] as String,
      water: json['water'] as String,
      training: json['training'] as String,
      cardio: json['cardio'] as String,
      supplements: json['supplements'] as String,
      sleepTime: json['sleepTime'] as String,
      notes: json['notes'] as String?,
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'] as String)
          : null,
      imagePath: json['imagePath'] as String?,
      breakfastEntries: _entriesFromJson(json['breakfastEntries']),
      lunchEntries: _entriesFromJson(json['lunchEntries']),
      dinnerEntries: _entriesFromJson(json['dinnerEntries']),
      snackEntries: _entriesFromJson(json['snackEntries']),
      beforeTrainingEntries: _entriesFromJson(json['beforeTrainingEntries']),
      afterTrainingEntries: _entriesFromJson(json['afterTrainingEntries']),
    );
  }

  static List<MealEntry> _entriesFromJson(dynamic raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((value) => MealEntry.fromJson(Map<String, dynamic>.from(value))).toList();
  }

  @override
  List<Object?> get props => [
    id,
    breakfast,
    lunch,
    snack,
    beforeTraining,
    afterTraining,
    dinner,
    water,
    training,
    cardio,
    supplements,
    sleepTime,
    notes,
    dateTime,
    imagePath,
    breakfastEntries, lunchEntries, dinnerEntries, snackEntries,
    beforeTrainingEntries, afterTrainingEntries,
  ];
}

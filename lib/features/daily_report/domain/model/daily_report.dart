import 'package:equatable/equatable.dart';

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
  });

  bool get isEmpty =>
      breakfast.isEmpty &&
      lunch.isEmpty &&
      snack.isEmpty &&
      beforeTraining.isEmpty &&
      afterTraining.isEmpty &&
      dinner.isEmpty &&
      water.isEmpty &&
      training.isEmpty &&
      cardio.isEmpty &&
      supplements.isEmpty &&
      sleepTime.isEmpty &&
      (notes?.isEmpty ?? true);

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
  }) {
    return DailyReport(
      id: id ?? this.id,
      breakfast: breakfast ?? this.breakfast,
      lunch: lunch ?? this.lunch,
      snack: snack ?? this.snack,
      beforeTraining: beforeTraining ?? this.beforeTraining,
      afterTraining: afterTraining ?? this.afterTraining,
      dinner: dinner ?? this.dinner,
      water: water ?? this.water,
      training: training ?? this.training,
      cardio: cardio ?? this.cardio,
      supplements: supplements ?? this.supplements,
      sleepTime: sleepTime ?? this.sleepTime,
      notes: notes ?? this.notes,
      dateTime: dateTime ?? this.dateTime,
      imagePath: imagePath ?? this.imagePath,
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
      dateTime: json['dateTime'] != null ? DateTime.parse(json['dateTime'] as String) : null,
      imagePath: json['imagePath'] as String?,
    );
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
      ];
}

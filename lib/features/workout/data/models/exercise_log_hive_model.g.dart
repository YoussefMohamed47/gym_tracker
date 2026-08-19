// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_log_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseLogHiveModelAdapter extends TypeAdapter<ExerciseLogHiveModel> {
  @override
  final typeId = 2;

  @override
  ExerciseLogHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseLogHiveModel(
      plannedExerciseId: fields[0] as String,
      performedExerciseId: fields[1] as String,
      sets: (fields[2] as List).cast<ExerciseSetLogHiveModel>(),
      weightKg: (fields[3] as num?)?.toDouble(),
      isPerformed: fields[4] as bool,
      imagePath: fields[5] as String?,
      timestamp: fields[6] as DateTime,
      displayUnit: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseLogHiveModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.plannedExerciseId)
      ..writeByte(1)
      ..write(obj.performedExerciseId)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.weightKg)
      ..writeByte(4)
      ..write(obj.isPerformed)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.timestamp)
      ..writeByte(7)
      ..write(obj.displayUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseLogHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

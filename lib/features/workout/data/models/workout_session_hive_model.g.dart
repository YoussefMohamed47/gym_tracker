// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_session_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutSessionHiveModelAdapter
    extends TypeAdapter<WorkoutSessionHiveModel> {
  @override
  final typeId = 1;

  @override
  WorkoutSessionHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSessionHiveModel(
      dateKey: fields[0] as String,
      workoutType: fields[1] as String,
      exerciseLogs: (fields[2] as List).cast<ExerciseLogHiveModel>(),
      displayUnit: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSessionHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.dateKey)
      ..writeByte(1)
      ..write(obj.workoutType)
      ..writeByte(2)
      ..write(obj.exerciseLogs)
      ..writeByte(3)
      ..write(obj.displayUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSessionHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

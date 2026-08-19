// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set_log_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSetLogHiveModelAdapter
    extends TypeAdapter<ExerciseSetLogHiveModel> {
  @override
  final typeId = 3;

  @override
  ExerciseSetLogHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSetLogHiveModel(
      setIndex: (fields[0] as num).toInt(),
      weightKg: (fields[1] as num).toDouble(),
      isPerformed: fields[2] as bool,
      actualReps: (fields[3] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSetLogHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.setIndex)
      ..writeByte(1)
      ..write(obj.weightKg)
      ..writeByte(2)
      ..write(obj.isPerformed)
      ..writeByte(3)
      ..write(obj.actualReps);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetLogHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

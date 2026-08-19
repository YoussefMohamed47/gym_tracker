// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_report_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyReportHiveModelAdapter extends TypeAdapter<DailyReportHiveModel> {
  @override
  final typeId = 0;

  @override
  DailyReportHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyReportHiveModel(
      id: fields[0] as String,
      breakfast: fields[1] as String,
      lunch: fields[2] as String,
      snack: fields[3] as String,
      beforeTraining: fields[4] as String,
      afterTraining: fields[5] as String,
      dinner: fields[6] as String,
      water: fields[7] as String,
      training: fields[8] as String,
      cardio: fields[9] as String,
      supplements: fields[10] as String,
      sleepTime: fields[11] as String,
      notes: fields[12] as String?,
      dateTime: fields[13] as DateTime?,
      imagePath: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyReportHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.breakfast)
      ..writeByte(2)
      ..write(obj.lunch)
      ..writeByte(3)
      ..write(obj.snack)
      ..writeByte(4)
      ..write(obj.beforeTraining)
      ..writeByte(5)
      ..write(obj.afterTraining)
      ..writeByte(6)
      ..write(obj.dinner)
      ..writeByte(7)
      ..write(obj.water)
      ..writeByte(8)
      ..write(obj.training)
      ..writeByte(9)
      ..write(obj.cardio)
      ..writeByte(10)
      ..write(obj.supplements)
      ..writeByte(11)
      ..write(obj.sleepTime)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.dateTime)
      ..writeByte(14)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyReportHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

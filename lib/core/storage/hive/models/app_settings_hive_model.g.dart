// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsHiveModelAdapter extends TypeAdapter<AppSettingsHiveModel> {
  @override
  final typeId = 4;

  @override
  AppSettingsHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettingsHiveModel(weightUnit: fields[0] as String);
  }

  @override
  void write(BinaryWriter writer, AppSettingsHiveModel obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.weightUnit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

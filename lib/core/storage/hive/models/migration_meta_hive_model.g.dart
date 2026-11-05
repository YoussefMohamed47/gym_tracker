// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration_meta_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MigrationMetaHiveModelAdapter
    extends TypeAdapter<MigrationMetaHiveModel> {
  @override
  final typeId = 5;

  @override
  MigrationMetaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MigrationMetaHiveModel(
      state: (fields[0] as num).toInt(),
      lastAttempt: fields[1] as DateTime?,
      unresolvedCount: (fields[2] as num).toInt(),
      version: (fields[3] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, MigrationMetaHiveModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.state)
      ..writeByte(1)
      ..write(obj.lastAttempt)
      ..writeByte(2)
      ..write(obj.unresolvedCount)
      ..writeByte(3)
      ..write(obj.version);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MigrationMetaHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

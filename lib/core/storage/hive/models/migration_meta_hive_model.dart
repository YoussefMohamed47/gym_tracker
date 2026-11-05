import 'package:hive_ce/hive.dart';

part 'migration_meta_hive_model.g.dart';

@HiveType(typeId: 5)
class MigrationMetaHiveModel extends HiveObject {
  @HiveField(0)
  final int state;

  @HiveField(1)
  final DateTime? lastAttempt;

  @HiveField(2)
  final int unresolvedCount;

  @HiveField(3)
  final int version;

  MigrationMetaHiveModel({
    required this.state,
    this.lastAttempt,
    required this.unresolvedCount,
    required this.version,
  });
}

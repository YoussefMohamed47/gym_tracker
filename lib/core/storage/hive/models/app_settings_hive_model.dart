import 'package:hive_ce/hive.dart';

part 'app_settings_hive_model.g.dart';

@HiveType(typeId: 4)
class AppSettingsHiveModel extends HiveObject {
  @HiveField(0)
  final String weightUnit;

  AppSettingsHiveModel({required this.weightUnit});
}

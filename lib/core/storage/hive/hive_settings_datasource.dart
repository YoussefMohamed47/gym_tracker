import 'package:hive_ce/hive.dart';
import 'models/app_settings_hive_model.dart';
import '../../../core/utils/weight_converter.dart';

abstract class SettingsLocalDataSource {
  Future<WeightUnit> getWeightUnit();
  Future<void> setWeightUnit(WeightUnit unit);
}

class HiveSettingsLocalDataSource implements SettingsLocalDataSource {
  final Box<AppSettingsHiveModel> _box;

  HiveSettingsLocalDataSource(this._box);

  @override
  Future<WeightUnit> getWeightUnit() async {
    final settings = _box.get('current');
    if (settings == null) return WeightUnit.kg;
    return WeightUnit.values.firstWhere(
      (e) => e.name == settings.weightUnit,
      orElse: () => WeightUnit.kg,
    );
  }

  @override
  Future<void> setWeightUnit(WeightUnit unit) async {
    await _box.put('current', AppSettingsHiveModel(weightUnit: unit.name));
  }
}

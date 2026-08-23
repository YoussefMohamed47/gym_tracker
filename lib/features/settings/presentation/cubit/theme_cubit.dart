import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final Box _prefsBox;

  ThemeCubit(this._prefsBox) : super(_loadThemeMode(_prefsBox));

  static ThemeMode _loadThemeMode(Box box) {
    final modeString = box.get('theme_mode', defaultValue: 'system');
    return ThemeMode.values.firstWhere(
      (m) => m.name == modeString,
      orElse: () => ThemeMode.system,
    );
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    _prefsBox.put('theme_mode', newMode.name);
    emit(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    _prefsBox.put('theme_mode', mode.name);
    emit(mode);
  }
}

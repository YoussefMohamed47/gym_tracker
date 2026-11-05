import 'package:hive_ce/hive.dart';
import '../../../hive_registrar.g.dart';

class HiveRegistrar {
  static void registerAdapters() {
    try {
      Hive.registerAdapters();
    } catch (_) {
      // Ignore already registered errors
    }
  }
}

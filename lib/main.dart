import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/storage/migration/legacy_persistence_migrator.dart';
import 'core/storage/hive/widgets/storage_error_screen.dart';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await di.init();

    // Run migration
    final migrator = di.sl<LegacyPersistenceMigrator>();
    await migrator.migrate();

    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: StorageErrorScreen(
          onRetry: () async {
            await Hive.close();
            await di.sl.reset();
            main();
          },
          onReset: () async {
            await Hive.close();
            await Hive.deleteFromDisk();
            await di.sl.reset();
            main();
          },
          errorMessage: e.toString(),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A46A0)),
        useMaterial3: true,
        textTheme: GoogleFonts.notoKufiArabicTextTheme(),
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}

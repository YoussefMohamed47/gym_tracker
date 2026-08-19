class HiveBoxes {
  static const String dailyReports = 'gym_tracker_daily_reports';
  static const String workoutSessions = 'gym_tracker_workout_sessions';
  static const String settings = 'gym_tracker_settings';
  static const String migrationMeta = 'gym_tracker_migration_meta';

  static List<String> get all => [
    dailyReports,
    workoutSessions,
    settings,
    migrationMeta,
  ];
}

enum MigrationStatus {
  notStarted,
  inProgress,
  completed,
  completedWithWarnings,
  failed,
}

class MigrationResult {
  final MigrationStatus status;
  final int successfulCount;
  final int failedCount;
  final String? errorMessage;

  const MigrationResult({
    required this.status,
    this.successfulCount = 0,
    this.failedCount = 0,
    this.errorMessage,
  });

  bool get isSuccess =>
      status == MigrationStatus.completed ||
      status == MigrationStatus.completedWithWarnings;
}

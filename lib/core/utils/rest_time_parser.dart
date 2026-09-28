class RestTimeParser {
  /// Converts a prescribed rest string (e.g. '2-3m', '1-2m', '1m', '90s') into seconds.
  /// Defaults to 90 seconds if format is empty or unrecognized.
  static int parseInSeconds(String? prescribedRest) {
    if (prescribedRest == null || prescribedRest.trim().isEmpty) {
      return 90;
    }

    final text = prescribedRest.trim().toLowerCase();

    // Check for minutes pattern, e.g. '2-3m', '2-3 min', '1m', '1 min', '2.5m'
    if (text.contains('m') || text.contains('min')) {
      final rangeMatch = RegExp(r'(\d+(?:\.\d+)?)\s*-\s*(\d+(?:\.\d+)?)').firstMatch(text);
      if (rangeMatch != null) {
        final lower = double.tryParse(rangeMatch.group(1)!) ?? 2.0;
        return (lower * 60).round();
      }

      final singleMatch = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
      if (singleMatch != null) {
        final minutes = double.tryParse(singleMatch.group(1)!) ?? 1.5;
        return (minutes * 60).round();
      }
    }

    // Check for seconds pattern, e.g. '90s', '45 sec', '60'
    final secondsMatch = RegExp(r'(\d+)').firstMatch(text);
    if (secondsMatch != null) {
      final val = int.tryParse(secondsMatch.group(1)!) ?? 90;
      return val;
    }

    return 90;
  }

  /// Formats seconds into a human readable display string (e.g. 120 -> "2 Minutes")
  static String formatDisplay(int seconds) {
    if (seconds <= 0) return '0 Seconds';
    final mins = seconds ~/ 60;
    final secs = seconds % 60;

    if (secs == 0) {
      return mins == 1 ? '1 Minute' : '$mins Minutes';
    } else if (mins == 0) {
      return '$secs Seconds';
    } else {
      final formattedSecs = secs.toString().padLeft(2, '0');
      return '$mins:$formattedSecs Min';
    }
  }
}

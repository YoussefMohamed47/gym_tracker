/// "1 set", "3 sets": [count] with the singular or plural word.
String countOf(int count, String singular, [String? plural]) =>
    '$count ${count == 1 ? singular : (plural ?? '${singular}s')}';

int dayColorIndex(String label, int fallback) {
  final number = int.tryParse(RegExp(r'\d+').firstMatch(label)?.group(0) ?? '');
  return number != null && number > 0 ? number - 1 : fallback;
}

Map<String, T> sortTripDays<T>(Map<String, T> days) {
  final entries = days.entries.toList()
    ..sort((a, b) {
      final comparison = dayColorIndex(
        a.key,
        1000000,
      ).compareTo(dayColorIndex(b.key, 1000000));
      return comparison != 0 ? comparison : a.key.compareTo(b.key);
    });
  return Map.fromEntries(entries);
}

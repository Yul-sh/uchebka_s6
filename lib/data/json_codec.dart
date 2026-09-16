int jsonInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

List<int> jsonIntList(dynamic value) {
  if (value is! List) return const [];
  return [for (final item in value) jsonInt(item)];
}

DateTime? jsonDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

String jsonString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}

int jsonNestedId(dynamic value, [String key = 'id']) {
  if (value is Map) return jsonInt(value[key]);
  return jsonInt(value);
}

List<int> jsonNestedIds(dynamic value) {
  if (value is! List) return const [];
  return [for (final item in value) jsonNestedId(item)];
}

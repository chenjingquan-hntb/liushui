class EntryModel {
  final String id;
  final String date;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String rawText;
  final List<String> images;
  final String? locationStr;
  final bool isArchived;

  const EntryModel({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.rawText,
    this.images = const [],
    this.locationStr,
    this.isArchived = true,
  });
}

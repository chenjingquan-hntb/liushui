import 'category_mapper.dart';

class BillMatch {
  final String rawSegment;
  final double parsedValue;
  final String unit;
  final String category;
  final int startIndex;
  final int endIndex;
  final double confidence;

  const BillMatch({
    required this.rawSegment,
    required this.parsedValue,
    required this.unit,
    required this.category,
    required this.startIndex,
    required this.endIndex,
    required this.confidence,
  });
}

class BillRule {
  final String name;
  final RegExp pattern;
  final String defaultCategory;
  final double baseConfidence;
  final bool useCategoryMapper;

  const BillRule({
    required this.name,
    required this.pattern,
    required this.defaultCategory,
    required this.baseConfidence,
    this.useCategoryMapper = false,
  });

  List<BillMatch> apply(String text) {
    final matches = pattern.allMatches(text);
    return matches.map((m) {
      final raw = m.group(0)!;
      final amountStr = m.namedGroup('amount')!;
      final unit = m.namedGroup('unit') ?? '元';

      String category = defaultCategory;
      if (useCategoryMapper) {
        category = CategoryMapper.infer(raw);
      }

      return BillMatch(
        rawSegment: raw,
        parsedValue: double.parse(amountStr),
        unit: unit,
        category: category,
        startIndex: m.start,
        endIndex: m.end,
        confidence: baseConfidence,
      );
    }).toList();
  }
}

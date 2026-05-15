class ExtractedBillModel {
  final String? id;
  final String rawSegment;
  final double parsedValue;
  final String unit;
  final String category;
  final double confidence;
  final bool isConfirmed;

  const ExtractedBillModel({
    this.id,
    required this.rawSegment,
    required this.parsedValue,
    this.unit = '元',
    this.category = '其他',
    this.confidence = 0.5,
    this.isConfirmed = false,
  });

  bool get isExpense => category != '收入';
  bool get isIncome => category == '收入';

  ExtractedBillModel copyWith({
    String? id,
    String? rawSegment,
    double? parsedValue,
    String? unit,
    String? category,
    double? confidence,
    bool? isConfirmed,
  }) {
    return ExtractedBillModel(
      id: id ?? this.id,
      rawSegment: rawSegment ?? this.rawSegment,
      parsedValue: parsedValue ?? this.parsedValue,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      confidence: confidence ?? this.confidence,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }
}

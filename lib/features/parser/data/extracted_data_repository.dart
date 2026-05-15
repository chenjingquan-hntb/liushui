import 'package:uuid/uuid.dart';
import '../../../shared/database/app_database.dart';
import '../../../shared/models/extracted_data.dart';

class ExtractedDataRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  ExtractedDataRepository(this._db);

  Future<void> saveBills(
      String entryId, List<ExtractedBillModel> bills) async {
    if (bills.isEmpty) return;

    final companions = bills.map((b) => ExtractedDataCompanion.insert(
          id: b.id ?? _uuid.v4(),
          entryId: entryId,
          type: 'bill',
          rawSegment: b.rawSegment,
          parsedValue: b.parsedValue,
          unit: Value(b.unit),
          category: Value(b.category),
          confidence: Value(b.confidence),
          isConfirmed: Value(b.isConfirmed),
          createdAt: DateTime.now(),
        ));

    await _db.insertExtractedDataList(companions.toList());
  }
}

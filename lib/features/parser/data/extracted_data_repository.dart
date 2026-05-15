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

    final items = bills.map((b) => {
          'id': b.id ?? _uuid.v4(),
          'entry_id': entryId,
          'type': 'bill',
          'raw_segment': b.rawSegment,
          'parsed_value': b.parsedValue,
          'unit': b.unit,
          'category': b.category,
          'confidence': b.confidence,
          'is_confirmed': b.isConfirmed ? 1 : 0,
          'created_at': DateTime.now().toIso8601String(),
        }).toList();

    await _db.insertExtractedDataList(items);
  }
}

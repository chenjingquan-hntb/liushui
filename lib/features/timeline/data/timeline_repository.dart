import '../../../shared/database/app_database.dart';
import '../domain/timeline_service.dart';

class TimelineRepository {
  final AppDatabase _db;

  TimelineRepository(this._db);

  Stream<List<Entry>> watchAllEntries() => _db.watchAllEntries();

  Future<Map<String, List<ExtractedDatum>>> getBillsGrouped(
      List<String> entryIds) {
    return _db.getBillsGroupedByEntry(entryIds);
  }
}

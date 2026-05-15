import '../../../shared/database/app_database.dart';

class TimelineRepository {
  final AppDatabase _db;

  TimelineRepository(this._db);

  Future<List<Map<String, dynamic>>> getAllEntries() => _db.getAllEntries();

  Future<Map<String, List<Map<String, dynamic>>>> getBillsGrouped(
      List<String> entryIds) {
    return _db.getBillsGroupedByEntry(entryIds);
  }
}

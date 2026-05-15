import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static AppDatabase? _instance;
  late final Database _db;

  AppDatabase._();

  static Future<AppDatabase> create() async {
    final instance = AppDatabase._();
    instance._db = await _initDatabase();
    _instance = instance;
    return instance;
  }

  static AppDatabase? get instance => _instance;

  Database get db => _db;

  static Future<Database> _initDatabase() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final path = p.join(dbFolder.path, 'flowlog.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            raw_text TEXT NOT NULL,
            images_json TEXT NOT NULL DEFAULT '[]',
            location_str TEXT,
            is_archived INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await db.execute('''
          CREATE TABLE extracted_data (
            id TEXT PRIMARY KEY,
            entry_id TEXT NOT NULL,
            type TEXT NOT NULL,
            raw_segment TEXT NOT NULL,
            parsed_value REAL NOT NULL,
            unit TEXT NOT NULL DEFAULT '元',
            category TEXT NOT NULL DEFAULT '其他',
            confidence REAL NOT NULL DEFAULT 0.5,
            is_confirmed INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            FOREIGN KEY (entry_id) REFERENCES entries(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE drafts (
            id TEXT PRIMARY KEY,
            raw_text TEXT NOT NULL,
            images_json TEXT NOT NULL DEFAULT '[]',
            updated_at TEXT NOT NULL
          )
        ''');
        await db.execute(
            'CREATE INDEX idx_entries_date ON entries(date)');
        await db.execute(
            'CREATE INDEX idx_extracted_entry ON extracted_data(entry_id)');
      },
    );
  }

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }

  // --- Entry queries ---

  Future<List<Map<String, dynamic>>> getAllEntries() async {
    return _db.query('entries',
        where: 'is_archived = 1 AND is_deleted = 0',
        orderBy: 'date DESC');
  }

  Stream<List<Map<String, dynamic>>> watchAllEntries() {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _queryAndListen(
      controller,
      'entries',
      where: 'is_archived = 1 AND is_deleted = 0',
      orderBy: 'date DESC',
    );
    return controller.stream;
  }

  Future<Map<String, dynamic>?> getEntry(String id) async {
    final results = await _db.query('entries', where: 'id = ?', whereArgs: [id]);
    return results.isEmpty ? null : results.first;
  }

  Future<String> insertEntry({
    required String id,
    required String date,
    required String createdAt,
    required String updatedAt,
    required String rawText,
    String imagesJson = '[]',
    String? locationStr,
    int isArchived = 1,
  }) async {
    await _db.insert('entries', {
      'id': id,
      'date': date,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'raw_text': rawText,
      'images_json': imagesJson,
      'location_str': locationStr,
      'is_archived': isArchived,
      'is_deleted': 0,
    });
    return id;
  }

  Future<void> updateEntryText(String id, String rawText) async {
    await _db.update('entries', {
      'raw_text': rawText,
      'updated_at': DateTime.now().toIso8601String(),
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteEntry(String id) async {
    return _db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Draft queries ---

  Future<Map<String, dynamic>?> getCurrentDraft() async {
    final results = await _db.query('drafts', where: 'id = ?', whereArgs: ['current']);
    return results.isEmpty ? null : results.first;
  }

  Stream<Map<String, dynamic>?> watchCurrentDraft() {
    final controller = StreamController<Map<String, dynamic>?>.broadcast();
    _queryDraftAndListen(controller);
    return controller.stream;
  }

  Future<void> upsertDraft({
    required String id,
    required String rawText,
    String imagesJson = '[]',
    required String updatedAt,
  }) async {
    await _db.insert('drafts', {
      'id': id,
      'raw_text': rawText,
      'images_json': imagesJson,
      'updated_at': updatedAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteDraft() async {
    return _db.delete('drafts', where: 'id = ?', whereArgs: ['current']);
  }

  // --- ExtractedData queries ---

  Future<List<Map<String, dynamic>>> getExtractedByEntry(String entryId) async {
    return _db.query('extracted_data', where: 'entry_id = ?', whereArgs: [entryId]);
  }

  Stream<List<Map<String, dynamic>>> watchExtractedByEntry(String entryId) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    _queryAndListen(controller, 'extracted_data',
        where: 'entry_id = ?', whereArgs: [entryId]);
    return controller.stream;
  }

  Future<void> insertExtractedData({
    required String id,
    required String entryId,
    required String type,
    required String rawSegment,
    required double parsedValue,
    required String unit,
    required String category,
    required double confidence,
    required int isConfirmed,
  }) async {
    await _db.insert('extracted_data', {
      'id': id,
      'entry_id': entryId,
      'type': type,
      'raw_segment': rawSegment,
      'parsed_value': parsedValue,
      'unit': unit,
      'category': category,
      'confidence': confidence,
      'is_confirmed': isConfirmed,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> insertExtractedDataList(
      List<Map<String, dynamic>> items) async {
    final batch = _db.batch();
    for (final item in items) {
      batch.insert('extracted_data', item);
    }
    await batch.commit(noResult: true);
  }

  Future<void> confirmExtracted(String id, int confirmed) async {
    await _db.update('extracted_data', {
      'is_confirmed': confirmed,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateExtractedCategory(String id, String category) async {
    await _db.update('extracted_data', {
      'category': category,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, List<Map<String, dynamic>>>> getBillsGroupedByEntry(
      List<String> entryIds) async {
    if (entryIds.isEmpty) return {};
    final placeholders = entryIds.map((_) => '?').join(',');
    final results = await _db.rawQuery('''
      SELECT * FROM extracted_data
      WHERE entry_id IN ($placeholders) AND is_confirmed = 1
    ''', entryIds);
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final r in results) {
      final eid = r['entry_id'] as String;
      grouped.putIfAbsent(eid, () => []).add(r);
    }
    return grouped;
  }

  Future<double> getDailyExpense(String date) async {
    final result = await _db.rawQuery('''
      SELECT COALESCE(SUM(ed.parsed_value), 0) as total
      FROM extracted_data ed
      INNER JOIN entries e ON ed.entry_id = e.id
      WHERE e.date = ? AND e.is_archived = 1
        AND ed.is_confirmed = 1
        AND ed.type = 'bill'
        AND ed.category != '收入'
    ''', [date]);
    final total = result.first['total'];
    return total is double ? total : (total as num).toDouble();
  }

  // --- Internal helpers ---

  void _queryAndListen(
    StreamController<List<Map<String, dynamic>>> controller,
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) {
    _queryAndEmit(controller, table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<void> _queryAndEmit(
    StreamController<List<Map<String, dynamic>>> controller,
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final results = await _db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy);
    controller.add(results);
  }

  void _queryDraftAndListen(
      StreamController<Map<String, dynamic>?> controller) async {
    final result = await getCurrentDraft();
    controller.add(result);
  }
}

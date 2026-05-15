import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/entries_table.dart';
import 'tables/extracted_data_table.dart';
import 'tables/drafts_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Entries, ExtractedData, Drafts],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
      );

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'flowlog.db'));
      return NativeDatabase.createInBackground(file);
    });
  }

  // --- Entry DAO methods ---

  Future<List<Entry>> getAllEntries() {
    return (select(entries)
          ..where((t) => t.isArchived.equals(true) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Stream<List<Entry>> watchAllEntries() {
    return (select(entries)
          ..where((t) => t.isArchived.equals(true) & t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Stream<List<Entry>> watchEntriesByDate(String date) {
    return (select(entries)
          ..where((t) => t.date.equals(date) & t.isArchived.equals(true)))
        .watch();
  }

  Future<Entry?> getEntry(String id) {
    return (select(entries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertEntry(EntriesCompanion entry) {
    return into(entries).insert(entry);
  }

  Future<void> updateEntryText(String id, String rawText) {
    return (update(entries)..where((t) => t.id.equals(id))).write(
      EntriesCompanion(
        rawText: Value(rawText),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> deleteEntry(String id) {
    return (delete(entries)..where((t) => t.id.equals(id))).go();
  }

  // --- Draft DAO methods ---

  Future<Draft?> getCurrentDraft() {
    return (select(drafts)..where((t) => t.id.equals('current')))
        .getSingleOrNull();
  }

  Stream<Draft?> watchCurrentDraft() {
    return (select(drafts)..where((t) => t.id.equals('current')))
        .watchSingleOrNull();
  }

  Future<void> upsertDraft(DraftsCompanion draft) {
    return into(drafts).insertOnConflictUpdate(draft);
  }

  Future<int> deleteDraft() {
    return (delete(drafts)..where((t) => t.id.equals('current'))).go();
  }

  // --- ExtractedData DAO methods ---

  Future<List<ExtractedDatum>> getExtractedByEntry(String entryId) {
    return (select(extractedData)
          ..where((t) => t.entryId.equals(entryId)))
        .get();
  }

  Stream<List<ExtractedDatum>> watchExtractedByEntry(String entryId) {
    return (select(extractedData)
          ..where((t) => t.entryId.equals(entryId)))
        .watch();
  }

  Future<void> insertExtractedData(ExtractedDataCompanion data) {
    return into(extractedData).insert(data);
  }

  Future<void> insertExtractedDataList(
      List<ExtractedDataCompanion> items) async {
    await batch((b) {
      b.insertAll(extractedData, items);
    });
  }

  Future<void> confirmExtracted(String id, bool confirmed) {
    return (update(extractedData)..where((t) => t.id.equals(id))).write(
      ExtractedDataCompanion(isConfirmed: Value(confirmed)),
    );
  }

  Future<void> updateExtractedCategory(String id, String category) {
    return (update(extractedData)..where((t) => t.id.equals(id))).write(
      ExtractedDataCompanion(category: Value(category)),
    );
  }

  Future<Map<String, List<ExtractedDatum>>> getBillsGroupedByEntry(
      List<String> entryIds) async {
    if (entryIds.isEmpty) return {};
    final query = select(extractedData)
      ..where((t) => t.entryId.isIn(entryIds) & t.isConfirmed.equals(true));
    final results = await query.get();
    final grouped = <String, List<ExtractedDatum>>{};
    for (final r in results) {
      grouped.putIfAbsent(r.entryId, () => []).add(r);
    }
    return grouped;
  }

  Future<double> getDailyExpense(String date) async {
    final query = selectOnly(extractedData)
      ..addColumns([extractedData.parsedValue.sum()])
      ..where(extractedData.entryId.isIn(
        selectOnly(entries)
          ..addColumns([entries.id])
          ..where(entries.date.equals(date) & entries.isArchived.equals(true)),
      ) & extractedData.isConfirmed.equals(true) &
          extractedData.type.equals('bill') &
          extractedData.category.isNotValue('收入'));
    final row = await query.getSingle();
    return row.read(extractedData.parsedValue.sum()) ?? 0.0;
  }
}

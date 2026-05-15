import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/nlp_engine.dart';
import '../../../../shared/database/database_providers.dart';
import '../../../../shared/models/extracted_data.dart';

final nlpEngineProvider = Provider.autoDispose<NlpEngine>((ref) {
  return NlpEngine();
});

final pendingBillsProvider =
    AutoDisposeNotifierProvider<PendingBillsNotifier, List<ExtractedBillModel>>(
  PendingBillsNotifier.new,
);

class PendingBillsNotifier
    extends AutoDisposeNotifier<List<ExtractedBillModel>> {
  @override
  List<ExtractedBillModel> build() => [];

  void setBills(List<ExtractedBillModel> bills) {
    state = bills;
  }

  Future<void> confirmBill(String entryId, int index) async {
    final dbAsync = ref.read(appDatabaseProvider);
    final db = dbAsync.valueOrNull;
    if (db == null) return;

    final bill = state[index].copyWith(isConfirmed: true);
    final newList = [...state];
    newList[index] = bill;
    state = newList;

    final id = const Uuid().v4();
    await db.insertExtractedData(
      id: id,
      entryId: entryId,
      type: 'bill',
      rawSegment: bill.rawSegment,
      parsedValue: bill.parsedValue,
      unit: bill.unit,
      category: bill.category,
      confidence: bill.confidence,
      isConfirmed: 1,
    );
  }

  Future<void> rejectBill(String entryId, int index) async {
    final dbAsync = ref.read(appDatabaseProvider);
    final db = dbAsync.valueOrNull;
    if (db == null) return;

    final bill = state[index];
    final newList = [...state];
    newList.removeAt(index);
    state = newList;

    final id = const Uuid().v4();
    await db.insertExtractedData(
      id: id,
      entryId: entryId,
      type: 'bill',
      rawSegment: bill.rawSegment,
      parsedValue: bill.parsedValue,
      unit: bill.unit,
      category: bill.category,
      confidence: bill.confidence,
      isConfirmed: 0,
    );
  }

  Future<void> updateCategory(int index, String category) async {
    final bill = state[index].copyWith(category: category);
    final newList = [...state];
    newList[index] = bill;
    state = newList;
  }

  void clear() {
    state = [];
  }
}

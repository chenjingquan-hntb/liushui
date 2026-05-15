import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/database/database_providers.dart';
import '../../domain/timeline_service.dart';

final timelineDayGroupsProvider = StreamProvider<List<DayGroup>>((ref) {
  final db = ref.watch(appDatabaseProvider);

  return db.watchAllEntries().asyncMap((entries) async {
    if (entries.isEmpty) return [];

    final entryIds = entries.map((e) => e.id).toList();
    final billsByEntryId = await db.getBillsGroupedByEntry(entryIds);

    return TimelineService.groupByDate(entries, billsByEntryId);
  });
});

final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDateNotifier, DateTime>(
  SelectedDateNotifier.new,
);

class SelectedDateNotifier extends AutoDisposeNotifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void select(DateTime date) {
    state = date;
  }

  void goToToday() {
    state = DateTime.now();
  }
}

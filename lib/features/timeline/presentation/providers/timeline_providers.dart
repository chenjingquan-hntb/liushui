import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/database/database_providers.dart';
import '../../domain/timeline_service.dart';

final timelineDayGroupsProvider = StreamProvider<List<DayGroup>>((ref) {
  final dbAsync = ref.watch(appDatabaseProvider);

  return dbAsync.when(
    data: (db) async* {
      final entries = await db.getAllEntries();
      if (entries.isEmpty) {
        yield [];
        return;
      }
      final entryIds = entries.map((e) => e['id'] as String).toList();
      final billsByEntryId = await db.getBillsGroupedByEntry(entryIds);
      yield TimelineService.groupByDate(entries, billsByEntryId);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
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

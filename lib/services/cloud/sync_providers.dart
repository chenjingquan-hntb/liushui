import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_service.dart';
import 'noop_sync_service.dart';

final syncServiceProvider = Provider.autoDispose<SyncService>((ref) {
  return NoopSyncService();
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final sync = ref.watch(syncServiceProvider);
  return sync.syncStatus;
});

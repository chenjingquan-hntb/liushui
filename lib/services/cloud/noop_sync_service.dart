import 'dart:async';
import 'sync_service.dart';

class NoopSyncService implements SyncService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> push() async {}

  @override
  Future<void> pull() async {}

  @override
  Future<void> fullSync() async {}

  @override
  Stream<SyncStatus> get syncStatus => Stream.value(SyncStatus.offline);

  @override
  bool get isEnabled => false;
}

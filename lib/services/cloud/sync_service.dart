enum SyncStatus { idle, syncing, error, offline }

/// 云端同步抽象接口
/// v0.1 使用 NoopSyncService，v0.3+ 实现 SupabaseSyncService
abstract class SyncService {
  Future<void> initialize();
  Future<void> push();
  Future<void> pull();
  Future<void> fullSync();
  Stream<SyncStatus> get syncStatus;
  bool get isEnabled;
}

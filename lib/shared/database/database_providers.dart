import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final appDatabaseProvider = FutureProvider.autoDispose<AppDatabase>((ref) async {
  final db = await AppDatabase.create();
  ref.onDispose(() => db.close());
  return db;
});

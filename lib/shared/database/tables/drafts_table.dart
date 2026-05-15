import 'package:drift/drift.dart';

class Drafts extends Table {
  TextColumn get id => text()();
  TextColumn get rawText => text()();
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

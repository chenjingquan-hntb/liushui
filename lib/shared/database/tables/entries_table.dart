import 'package:drift/drift.dart';

class Entries extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get rawText => text()();
  TextColumn get imagesJson => text().withDefault(const Constant('[]'))();
  TextColumn get locationStr => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

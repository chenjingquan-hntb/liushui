import 'package:drift/drift.dart';

class ExtractedData extends Table {
  TextColumn get id => text()();
  TextColumn get entryId => text()();
  TextColumn get type => text()();
  TextColumn get rawSegment => text()();
  RealColumn get parsedValue => real()();
  TextColumn get unit => text().withDefault(const Constant('元'))();
  TextColumn get category => text().withDefault(const Constant('其他'))();
  RealColumn get confidence => real().withDefault(const Constant(0.5))();
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

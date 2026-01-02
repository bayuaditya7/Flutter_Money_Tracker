import 'package:drift/drift.dart';
//bayu
@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();

  //relasi dg category
  IntColumn get category_id => integer()();

  // Periode budget (bisa monthly, weekly, custom range)
  DateTimeColumn get period_start => dateTime()();
  DateTimeColumn get period_end => dateTime()();

  // Nilai budget (pakai int supaya konsisten dengan transaksi.amount)
  IntColumn get amount => integer()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  // Optional (direkomendasikan): cegah dobel budget kategori pada periode yang sama
  @override
  List<String> get customConstraints => [
        'UNIQUE(category_id, period_start, period_end)'
      ];
}
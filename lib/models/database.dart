import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Category>> getAllCategoryRepo(int type) async {
    return await (select(
      categories,
    )..where((tbl) => tbl.type.equals(type))).get();
  }

  Future updateCategoryRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  Future deleteCatagoryRepo(int id) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  //Dimas (CRUD Transaction) list list dengan category
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
    DateTime date,
  ) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id)),
    ])..where(transactions.transaction_date.equals(date)));
    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
          row.readTable(transactions),
          row.readTable(categories),
        );
      }).toList();
    });
  }

  //Dimas Update transaction database
  Future updateTransactionRepo(
    int id,
    int amount,
    int categoryId,
    DateTime transaction_date,
    String nameDetail,
  ) async {
    return (update(transactions)..where((tbl) => tbl.id.equals(id))).write(
      TransactionsCompanion(
        name: Value(nameDetail),
        amount: Value(amount),
        category_id: Value(categoryId),
        transaction_date: Value(transaction_date),
      ),
    );
  }
    Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sq;ite'));
    return NativeDatabase(file);
  });
}

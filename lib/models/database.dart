import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:money_tracker/models/category.dart';
import 'package:money_tracker/models/transaction.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:money_tracker/models/budget.dart';
import 'package:money_tracker/models/budget_usage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, Budgets])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  //migration
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(budgets);
      }
    },
  );

  //repo category
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

  //repo transaction
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

  //repo budget
  Future<Budget> insertBudgetRepo({
    required int categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int amount,
  }) async {
    final now = DateTime.now();
    return await into(budgets).insertReturning(
      BudgetsCompanion.insert(
        category_id: categoryId,
        period_start: periodStart,
        period_end: periodEnd,
        amount: amount,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> updateBudgetRepo({
    required int id,
    required int categoryId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int amount,
  }) async {
    final now = DateTime.now();
    return await (update(budgets)..where((t) => t.id.equals(id))).write(
      BudgetsCompanion(
        category_id: Value(categoryId),
        period_start: Value(periodStart),
        period_end: Value(periodEnd),
        amount: Value(amount),
        updatedAt: Value(now),
      ),
    );
  }

  Future<int> deleteBudgetRepo(int id) async {
    return await (delete(budgets)..where((t) => t.id.equals(id))).go();
  }

  /// Ambil budgets dalam periode tertentu (contoh: 1 bulan),
  /// join category untuk tampil nama kategori.
  Stream<List<BudgetUsage>> watchBudgetUsageByPeriod({
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    // SUM transaksi per kategori dalam rentang waktu budget
    final spentSum = transactions.amount.sum();

    final query =
        select(budgets).join([
          innerJoin(categories, categories.id.equalsExp(budgets.category_id)),

          // transaksi boleh kosong (jadi tetap tampil budget walau belum ada transaksi)
          leftOuterJoin(
            transactions,
            transactions.category_id.equalsExp(budgets.category_id) &
                transactions.transaction_date.isBiggerOrEqualValue(
                  periodStart,
                ) &
                transactions.transaction_date.isSmallerOrEqualValue(periodEnd),
          ),
        ])..where(
          budgets.period_start.isBiggerOrEqualValue(periodStart) &
              budgets.period_end.isSmallerOrEqualValue(periodEnd) &
              categories.type.equals(2),
        ); // hanya kategori expense

    query
      ..addColumns([spentSum])
      ..groupBy([budgets.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final budgetRow = row.readTable(budgets);
        final categoryRow = row.readTable(categories);
        final spent = row.read(spentSum) ?? 0;

        return BudgetUsage(
          budget: budgetRow,
          category: categoryRow,
          spent: spent,
        );
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    // FIX: tadinya 'db.sq;ite'
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase(file);
  });
}

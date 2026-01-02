import 'package:money_tracker/models/database.dart';
//bayu
class BudgetUsage {
  final Budget budget;
  final Category category;

  //menentukan total pengeluaran dalam periode berdasarkan category expanse
  final int spent;

  BudgetUsage({
    required this.budget,
    required this.category,
    required this.spent,
  });

  int get remaining => budget.amount - spent;

  double get usagePercent {
    if (budget.amount <= 0) return spent > 0 ? 100.0 : 0.0;
    final pct = (spent / budget.amount) * 100.0;
    if (pct.isNaN || pct.isInfinite) return 0.0;
    return pct;
  }
}
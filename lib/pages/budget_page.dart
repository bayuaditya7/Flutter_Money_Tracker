import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/budget_usage.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final AppDb database = AppDb();

  late DateTime periodStart;
  late DateTime periodEnd;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    periodStart = DateTime(now.year, now.month, 1);
    periodEnd = DateTime(now.year, now.month + 1, 0); // last day of month
  }

  String get periodLabel =>
      "${DateFormat('MMM yyyy', 'id').format(periodStart)}";

  Future<void> pickMonth() async {
    // simple: pakai datePicker lalu normalize ke month
    final picked = await showDatePicker(
      context: context,
      initialDate: periodStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2099),
    );

    if (picked == null) return;

    setState(() {
      periodStart = DateTime(picked.year, picked.month, 1);
      periodEnd = DateTime(picked.year, picked.month + 1, 0);
    });
  }

  void openBudgetDialog({BudgetUsage? existing}) async {
    final amountController = TextEditingController(
      text: existing?.budget.amount.toString() ?? '',
    );

    Category? selectedCategory;

    // load expense categories
    final expenseCategories = await database.getAllCategoryRepo(2);
    if (expenseCategories.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Kategori expense kosong'),
          content: Text('Tambah kategori expense dulu di menu Categories.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            )
          ],
        ),
      );
      return;
    }

    selectedCategory = existing?.category ?? expenseCategories.first;

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(existing == null ? 'Add Budget' : 'Edit Budget'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton<Category>(
                  value: selectedCategory,
                  isExpanded: true,
                  items: expenseCategories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (v) {
                    selectedCategory = v;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Budget amount',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Periode: ${DateFormat('yyyy-MM-dd').format(periodStart)} s/d ${DateFormat('yyyy-MM-dd').format(periodEnd)}',
                    style: GoogleFonts.montserrat(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = int.tryParse(amountController.text) ?? 0;
                if (amount <= 0) return;

                if (existing == null) {
                  await database.insertBudgetRepo(
                    categoryId: selectedCategory!.id,
                    periodStart: periodStart,
                    periodEnd: periodEnd,
                    amount: amount,
                  );
                } else {
                  await database.updateBudgetRepo(
                    id: existing.budget.id,
                    categoryId: selectedCategory!.id,
                    periodStart: periodStart,
                    periodEnd: periodEnd,
                    amount: amount,
                  );
                }

                if (!mounted) return;
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = database.watchBudgetUsageByPeriod(
      periodStart: periodStart,
      periodEnd: periodEnd,
    );

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budget - $periodLabel',
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: pickMonth,
                      icon: const Icon(Icons.calendar_month),
                    ),
                    IconButton(
                      onPressed: () => openBudgetDialog(existing: null),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<BudgetUsage>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada budget untuk periode ini.',
                      style: GoogleFonts.montserrat(),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final item = data[i];
                    final pct = item.usagePercent;
                    final progress = (pct / 100).clamp(0.0, 1.0);

                    final over = item.spent > item.budget.amount;
                    final barColor = over ? Colors.red : Colors.green;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Card(
                        elevation: 6,
                        child: ListTile(
                          title: Text(item.category.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Budget: Rp. ${item.budget.amount} | Spent: Rp. ${item.spent} | Remaining: Rp. ${item.remaining}',
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress,
                                color: barColor,
                                backgroundColor: Colors.grey[300],
                                minHeight: 8,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Usage: ${pct.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: over ? Colors.red : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => openBudgetDialog(existing: item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  await database.deleteBudgetRepo(item.budget.id);
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
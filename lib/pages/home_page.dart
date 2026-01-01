import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
import 'package:money_tracker/pages/transaction_page.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //memanggil database
  final AppDb database = AppDb();

  //Dimas (buat formater currency)
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Dimas (StreamBuilder dipindahkan ke sini agar bisa mengupdate Total Income/Expense)
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                // Inisialisasi variabel total
                int incomeTotal = 0;
                int expenseTotal = 0;

                // Ngitung total jika data tersedia
                if (snapshot.hasData) {
                  for (var element in snapshot.data!) {
                    if (element.category.type == 1) {
                      // Tipe 1 = Income
                      incomeTotal += element.transaction.amount;
                    } else if (element.category.type == 2) {
                      // Tipe 2 = Expense
                      expenseTotal += element.transaction.amount;
                    }
                  }
                }

                // pas loading, tetap tampilkan UI tapi dengan data kosong
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ini total income & expense
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade800,
                              Colors.blue.shade500,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.4),
                              blurRadius: 15,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Pemasukan (Pakai fungsi biar tidak double ketik)
                            _buildSummaryItem(
                              title: "Pemasukan",
                              amount: incomeTotal,
                              icon: Icons.arrow_downward,
                            ),

                            // Garis pemisah
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white30,
                            ),
                            SizedBox(width: 20),

                            // Pengeluaran
                            _buildSummaryItem(
                              title: "Pengeluaran",
                              amount: expenseTotal,
                              icon: Icons.arrow_upward,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- JUDUL DAFTAR ---
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        "Riwayat Transaksi",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // LIST TRANSACTION
                    // if-else biasa karena snapshot sudah diambil di atas
                    if (snapshot.hasData && snapshot.data!.isNotEmpty)
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          bool isExpense =
                              snapshot.data![index].category.type == 2;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                leading: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isExpense
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isExpense ? Icons.upload : Icons.download,
                                    color: isExpense
                                        ? Colors.red
                                        : Colors.green,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  formatter.format(
                                    snapshot.data![index].transaction.amount,
                                  ),
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  "${snapshot.data![index].category.name} (${snapshot.data![index].transaction.name})",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.edit,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage(
                                                      transactionWithCategory:
                                                          snapshot.data![index],
                                                    ),
                                              ),
                                            )
                                            .then((_) => setState(() {}));
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[300],
                                        size: 20,
                                      ),
                                      onPressed: () async {
                                        await database.deleteTransactionRepo(
                                          snapshot.data![index].transaction.id,
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Center(
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            Icon(
                              Icons.assignment_outlined,
                              color: Colors.grey[300],
                              size: 80,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Belum ada transaksi',
                              style: GoogleFonts.montserrat(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 80),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required int amount,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 18),
              SizedBox(width: 4),
              Text(
                title,
                style: GoogleFonts.montserrat(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Text(
            formatter.format(amount),
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

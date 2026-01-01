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
    decimalDigits: 0
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
                    children: [
                      // ini total income & expense
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // income ROW
                              Row(
                                children: [
                                  Container(
                                    child: Icon(Icons.download,
                                        color: Colors.green),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Income",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        formatter.format(incomeTotal),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // expense ROW
                              Row(
                                children: [
                                  Container(
                                    child:
                                        Icon(Icons.upload, color: Colors.red),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Expense",
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        formatter.format(expenseTotal),
                                        style: GoogleFonts.montserrat(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      
                      //TRANSACTION
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Transaction",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // LIST TRANSACTION
                      // if-else biasa karena snapshot sudah diambil di atas
                      if (snapshot.hasData && snapshot.data!.length > 0)
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Card(
                                elevation: 10,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database
                                                .deleteTransactionRepo(
                                                    snapshot.data![index]
                                                        .transaction.id);
                                            setState(() {});
                                          }),
                                      SizedBox(width: 10),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () async {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  TransactionPage(
                                                transactionWithCategory:
                                                    snapshot.data![index],
                                              ),
                                            ),
                                          );
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    formatter.format(snapshot.data![index].transaction.amount),
                                  ),
                                  subtitle: Text(
                                    snapshot.data![index].category.name +
                                        "(" +
                                        snapshot.data![index].transaction.name +
                                        ")",
                                  ),
                                  leading: Container(
                                    child: (snapshot.data![index].category
                                                .type ==
                                            2)
                                        ? Icon(
                                            Icons.upload,
                                            color: Colors.red,
                                          )
                                        : Icon(Icons.download,
                                            color: Colors.green),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Text('Tidak ada transaksi yang ditemukan'),
                          ),
                        ),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}
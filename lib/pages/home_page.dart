import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //memanggil database
  final AppDb database = AppDb();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Icon(Icons.download, color: Colors.green),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Income",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Rp. 3.000.000",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Icon(Icons.upload, color: Colors.red),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Expense",
                              style: GoogleFonts.montserrat(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              "Rp. 3.000.000",
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

            //Dimas
            StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
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
                                    Icon(Icons.delete),
                                    SizedBox(width: 10),
                                    Icon(Icons.edit),
                                  ],
                                ),
                                title: Text("Rp. 20.000"),
                                subtitle: Text("Makan Siang"),
                                leading: Container(
                                  child: Icon(Icons.upload, color: Colors.red),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Text('Tidak ada transaksi yang ditemukan'),
                      );
                    }
                  } else {
                    return Center(
                      child: Text('Tidak ada transaksi yang ditemukan'),
                    );
                  }
                }
              },
            ),
            //Dimas end
          ],
        ),
      ),
    );
  }
}

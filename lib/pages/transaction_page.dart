import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/models/database.dart';
import 'package:money_tracker/models/transaction_with_category.dart';
//import api duitku
import 'package:url_launcher/url_launcher.dart'; 
import 'package:money_tracker/services/duitku_service.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionWithCategory;
  const TransactionPage({Key? key, required this.transactionWithCategory})
    : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final AppDb database = AppDb();
  bool isExpense = true;
  // Tambahkan instance service
  final DuitkuService duitkuService = DuitkuService();
  bool isPaymentLoading = false;

  late int type;
  List<String> list = ['Makan dan Jajan', 'Transportasi', 'Nonton Film'];
  late String dropDownValue = list.first;
  TextEditingController amountController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  //Dimas (detail databasenya kita pakai (name))
  TextEditingController detailController = TextEditingController();
  Category? selectedCategory;
  //Dimas end

  Future insert(
    int amount,
    DateTime date,
    String nameDetail,
    int categoryId,
  ) async {
    //Dimas (ada insert ke database)
    DateTime now = DateTime.now();
    final row = await database
        .into(database.transactions)
        .insertReturning(
          TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            transaction_date: date,
            amount: amount,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(
    int transactionId,
    int amount,
    int categoryId,
    DateTime transaction_date,
    String nameDetail,
  ) async {
    return await database.updateTransactionRepo(
      transactionId,
      amount,
      categoryId,
      transaction_date,
      nameDetail,
    );
  }

  //method payment duitku
  final Map<String, String> paymentMethods = {
    'VC': 'Kartu Kredit (Visa/Master)',
    'BC': 'BCA Virtual Account',
    'M2': 'Mandiri Virtual Account',
    'SP': 'ShopeePay / QRIS', 
  };

  String selectedPaymentCode = 'VC';

  //method handle pembayaran API duiku
Future<void> _processPayment() async {
    setState(() => isPaymentLoading = true);

    try {
      String uniqueEmail = "test_${DateTime.now().millisecondsSinceEpoch}@mail.com";
      
      // Panggil Service dengan parameter paymentMethod
      String paymentUrl = await duitkuService.createPayment(
        amount: int.parse(amountController.text),
        productDetail: detailController.text.isEmpty ? "Transaksi" : detailController.text,
        email: uniqueEmail,
        phoneNumber: "08123456789",
        paymentMethod: selectedPaymentCode,
      );
    } catch (e) {
    } finally {
      setState(() => isPaymentLoading = false);
    }


    String uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    String uniqueEmail = "user_$uniqueId@mail.com";

    // Panggil service Duitku
    String? paymentUrl = await duitkuService.createPayment(
      amount: int.parse(amountController.text),
      productDetail: detailController.text.isEmpty ? "Transaksi" : detailController.text,
      email: uniqueEmail,
      phoneNumber: "08123456789",
      paymentMethod: selectedPaymentCode,
    );

    setState(() {
      isPaymentLoading = false;
    });

    if (paymentUrl != null) {
      // Buka halaman pembayaran Duitku
      final Uri url = Uri.parse(paymentUrl);
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka halaman pembayaran")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal membuat transaksi pembayaran")),
      );
    }
  }
  //Dimas end

  @override
  void initState() {
    if (widget.transactionWithCategory != null) {
      updateTransactionView(widget.transactionWithCategory!);
    } else {
      type = 2;
    }
    super.initState();
  }

  //Dimas (updateTransactionView)
  void updateTransactionView(TransactionWithCategory transactionWithCategory) {
    amountController.text = transactionWithCategory.transaction.amount
        .toString();
    detailController.text = transactionWithCategory.transaction.name;
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(transactionWithCategory.transaction.transaction_date);
    type = transactionWithCategory.category.type;
    (type == 2) ? isExpense = true : isExpense = false;
    selectedCategory = transactionWithCategory.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          widget.transactionWithCategory == null
              ? "Tambah Transaksi"
              : "Edit Transaksi",
          style: GoogleFonts.montserrat(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpense = true;
                          type = 2;
                          selectedCategory = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isExpense ? Colors.red : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Pengeluaran",
                            style: GoogleFonts.montserrat(
                              color: isExpense ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpense = false;
                          type = 1;
                          selectedCategory = null;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isExpense ? Colors.blue : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "Pemasukan",
                            style: GoogleFonts.montserrat(
                              color: !isExpense ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              //Dimas (input amount)
              Text(
                "Jumlah (Rp)",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "0",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),

              SizedBox(height: 20),
              //Dimas (input category)
              Text(
                "Kategori",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    selectedCategory = (selectedCategory == null)
                        ? snapshot.data!.first
                        : selectedCategory;
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Category>(
                          value: selectedCategory,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down),
                          items: snapshot.data!.map((Category item) {
                            return DropdownMenuItem<Category>(
                              value: item,
                              child: Text(
                                item.name,
                                style: GoogleFonts.montserrat(),
                              ),
                            );
                          }).toList(),
                          onChanged: (Category? value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    );
                  } else {
                    return Text(
                      "Tidak ada kategori",
                      style: GoogleFonts.montserrat(color: Colors.red),
                    );
                  }
                },
              ),

              SizedBox(height: 20),
              //Dimas (input date)
              Text(
                "Tanggal",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: dateController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2099),
                  );
                  if (pickedDate != null) {
                    dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(pickedDate);
                  }
                },
              ),
              //Dimas (input detail)
              SizedBox(height: 20),
              Text(
                "Catatan Tambahan",
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: detailController,
                decoration: InputDecoration(
                  hintText: "Contoh: Makan Siang",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.description),
                ),
              ),

              SizedBox(height: 40),

              if (isExpense) ...[
                Text(
                  "Metode Pembayaran",
                  style: GoogleFonts.montserrat(
                    fontSize: 14, 
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPaymentCode,
                      isExpanded: true,
                      items: paymentMethods.entries.map((entry) {
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Row(
                            children: [
                              Icon(Icons.payment, color: Colors.blue, size: 20),
                              SizedBox(width: 10),
                              Text(entry.value, style: GoogleFonts.montserrat()),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPaymentCode = value!;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
              
              //Dimas (button bayar duitku)
                if (isExpense) ...[
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isPaymentLoading ? null : _processPayment,
                    icon: isPaymentLoading 
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                        : Icon(Icons.payment, color: Colors.green),
                    label: Text(
                      "Bayar via Duitku",
                      style: GoogleFonts.montserrat(
                        color: Colors.green,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16), // Jarak antar tombol
              ],

              //Dimas (save button)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (selectedCategory == null) return;

                    if (widget.transactionWithCategory == null) {
                      await insert(
                        int.parse(amountController.text),
                        DateTime.parse(dateController.text),
                        detailController.text,
                        selectedCategory!.id,
                      );
                    } else {
                      await update(
                        widget.transactionWithCategory!.transaction.id,
                        int.parse(amountController.text),
                        selectedCategory!.id,
                        DateTime.parse(dateController.text),
                        detailController.text,
                      );
                    }
                    Navigator.pop(context, true);
                  },
                  child: Text(
                    "Simpan Transaksi",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

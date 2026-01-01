import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/models/database.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  bool isExpense = true;
  int type = 2;
  final AppDb database = AppDb();
  TextEditingController categoryNameController = TextEditingController();

  Future insert(String name, int type) async {
    DateTime now = DateTime.now();
    final row = await database
        .into(database.categories)
        .insertReturning(
          CategoriesCompanion.insert(
            name: name,
            type: type,
            createdAt: now,
            updatedAt: now,
          ),
        );
    print('masuk:' + row.toString());
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  Future update(int categoryId, String newName) async {
    return await database.updateCategoryRepo(categoryId, newName);
  }

void openDialog(Category? category) {
    if (category != null) {
      categoryNameController.text = category.name;
    } else {
      categoryNameController.clear();
    }
showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Text(
            (category == null) ? "Tambah Kategori" : "Edit Kategori",
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.blue,
            ),
          ),
                 content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: categoryNameController,
                  decoration: InputDecoration(
                    labelText: "Nama Kategori",
                    hintText: "Contoh: Jajan, Gaji, dll",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: Icon(Icons.category, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpense ? Colors.red : Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      if (categoryNameController.text.isNotEmpty) {
                        if (category == null) {
                          insert(categoryNameController.text, isExpense ? 2 : 1);
                        } else {
                          update(category.id, categoryNameController.text);
                        }
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                        setState(() {});
                        categoryNameController.clear();
                      }
                    },
                    child: Text(
                      "Simpan",
                      style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

@override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
     child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Tombol Expense
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = true;
                                type = 2;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isExpense ? Colors.red : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                border: Border.all(color: isExpense ? Colors.red : Colors.grey[300]!)
                              ),
                              child: Center(
                                child: Text(
                                  "Pengeluaran",
                                  style: GoogleFonts.montserrat(
                                    color: isExpense ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Tombol Income
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpense = false;
                                type = 1;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !isExpense ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border.all(color: !isExpense ? Colors.blue : Colors.grey[300]!)
                              ),
                              child: Center(
                                child: Text(
                                  "Pemasukan",
                                  style: GoogleFonts.montserrat(
                                    color: !isExpense ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),
                  IconButton(
                    onPressed: () {
                      openDialog(null);
                    },
                    icon: Icon(Icons.add_circle, size: 36),
                    color: isExpense ? Colors.red : Colors.blue,
                    tooltip: "Tambah Kategori",
                  ),
                ],
              ),
              
              SizedBox(height: 20),

              // --- LIST KATEGORI ---
              FutureBuilder<List<Category>>(
                future: getAllCategory(type),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    if (snapshot.hasData && snapshot.data!.length > 0) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                leading: Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isExpense) 
                                      ? Colors.red.withOpacity(0.1) 
                                      : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    (isExpense) ? Icons.upload : Icons.download,
                                    color: (isExpense) ? Colors.red : Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  snapshot.data![index].name,
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.grey[400], size: 20),
                                      onPressed: () {
                                        openDialog(snapshot.data![index]);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red[300], size: 20),
                                      onPressed: () {
                                        database.deleteCatagoryRepo(snapshot.data![index].id);
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
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            Icon(Icons.category_outlined, size: 60, color: Colors.grey[300]),
                            SizedBox(height: 10),
                            Text(
                              "Belum ada kategori",
                              style: GoogleFonts.montserrat(color: Colors.grey[400]),
                            ),
                            TextButton(
                              onPressed: () => openDialog(null),
                              child: Text("Tap untuk tambah", style: GoogleFonts.montserrat(color: isExpense ? Colors.red : Colors.blue)),
                            )
                          ],
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
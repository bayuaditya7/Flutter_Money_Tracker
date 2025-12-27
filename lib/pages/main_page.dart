import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/category_page.dart';
import 'package:money_tracker/pages/transaction_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late DateTime selectedDate;
  late List<Widget> _children;
  late int currentIndex;

  //Dimas
  @override
  void initState() {
    // TODO: implement initState
    updateView(0, DateTime.now());
    super.initState();
  }
  //Dimas end

  //Dimas (update view)
  void updateView(int index, DateTime? date) {
    setState(() {
      if (date != null) {
        selectedDate = DateTime.parse(DateFormat('yyyy-MM-dd').format(date));
      }

      currentIndex = index;
      _children = [
        HomePage(selectedDate: selectedDate),
        CategoryPage(),
      ];
    });
  }
  //Dimas end

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0)
          ? CalendarAppBar(
              accent: Colors.green,
              backButton: false,
              locale: 'id',
              onDateChanged: (value) {
                //Dimas start(update view)
                setState(() {
                //print('SELECTED DATE ' + value.toString());
                selectedDate = value;
                updateView(0, selectedDate);
                });
                //Dimas end
              },
              firstDate: DateTime.now().subtract(Duration(days: 140)),
              lastDate: DateTime.now(),
            )
          : PreferredSize(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 36,
                    horizontal: 16,
                  ),
                  child: Text(
                    'Categories',
                    style: GoogleFonts.montserrat(fontSize: 20),
                  ),
                ),
              ),
              preferredSize: Size.fromHeight(100),
            ),
      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(builder: (context) => TransactionPage(transactionWithCategory: null,)),
                )
                .then((value) {
                  setState(() {});
                });
          },
          backgroundColor: Colors.lightGreen,
          child: Icon(Icons.add),
        ),
      ),
      body: _children[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: IconButton(
                onPressed: () {
                  updateView(0, DateTime.now());
                },
                icon: const Icon(Icons.home),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: IconButton(
                onPressed: () {
                  updateView(1, null);
                },
                icon: const Icon(Icons.list),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tracker/pages/home_page.dart';
import 'package:money_tracker/pages/category_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Widget> _children = [HomePage(), CategoryPage()];
  int currentIndex = 0;

  void onTapTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (currentIndex == 0) ? CalendarAppBar(
        accent: Colors.green,
        backButton: false,
        locale: 'id',
        onDateChanged: (value) => print(value),
        firstDate: DateTime.now().subtract(Duration(days: 140)),
        lastDate: DateTime.now(),
      )
      : PreferredSize(
        child: Container(child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
          child: Text('Categories',
          style: GoogleFonts.montserrat(fontSize: 20),),
        )),
        preferredSize: Size.fromHeight(100),
      ),
      floatingActionButton: Visibility(
        visible: (currentIndex == 0) ? true : false,
        child: FloatingActionButton(
          onPressed: () {},
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
              child: IconButton(onPressed: () {
                onTapTapped(0);
              }, icon: const Icon(Icons.home)),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: IconButton(onPressed: () {
                onTapTapped(1);
              }, icon: const Icon(Icons.list)),
            ),
          ],
        ),
      ),
    );
  }
}

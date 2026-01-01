import 'package:flutter/material.dart';
import 'package:money_tracker/pages/main_page.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue[700],
          secondary: Colors.blueAccent,
        ),
        scaffoldBackgroundColor: Colors.grey[50],
        fontFamily: 'Montserrat',
      ),
    );
  }
}
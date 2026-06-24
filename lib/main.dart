import 'package:flutter/material.dart';
import 'package:jtrips_app/base/Botton_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Flutter Demo",
        theme: ThemeData(),
        home: BottonNavBar(),
      );
  }
}



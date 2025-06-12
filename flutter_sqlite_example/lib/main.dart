import 'package:flutter/material.dart';
import 'package:flutter_sqlite_example/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sqlite',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomePage(),
    );
  }
}

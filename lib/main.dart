import 'package:flutter/material.dart';
import 'package:pagination_interface_demo/screens/demo.screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaginationDemoScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pagination_interface_demo/demo/stateful.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: StatelessWidgetPagination(),
    );
  }
}

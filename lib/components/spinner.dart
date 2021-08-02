import 'package:flutter/material.dart';

class Spinner extends StatelessWidget {
  final String? label;
  Spinner({this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(
              color: Colors.grey,
            ),
          ),
          if (label != null) Text(label!),
        ],
      ),
    );
  }
}

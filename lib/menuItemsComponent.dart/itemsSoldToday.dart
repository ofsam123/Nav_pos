import 'package:flutter/material.dart';

class itemSoldToday extends StatefulWidget {
  const itemSoldToday({super.key});

  @override
  State<itemSoldToday> createState() => _itemSoldTodayState();
}

class _itemSoldTodayState extends State<itemSoldToday> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Items Sold Today",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

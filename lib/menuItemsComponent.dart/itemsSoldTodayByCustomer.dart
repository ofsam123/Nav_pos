import 'package:flutter/material.dart';

class ItemsSoldTodayByCustomer extends StatefulWidget {
  const ItemsSoldTodayByCustomer({super.key});

  @override
  State<ItemsSoldTodayByCustomer> createState() =>
      _ItemsSoldTodayByCustomerState();
}

class _ItemsSoldTodayByCustomerState extends State<ItemsSoldTodayByCustomer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Customer Items Sold",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

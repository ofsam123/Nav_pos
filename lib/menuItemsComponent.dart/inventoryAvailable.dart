import 'package:flutter/material.dart';

class AvailableInventory extends StatefulWidget {
  const AvailableInventory({super.key});

  @override
  State<AvailableInventory> createState() => _AvailableInventoryState();
}

class _AvailableInventoryState extends State<AvailableInventory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Available Inventory",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

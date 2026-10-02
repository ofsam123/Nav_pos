import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:nav_pos/scanQr.dart';
import 'package:nav_pos/sideMenu.dart';
import 'package:nav_pos/statictis.dart';
import 'package:nav_pos/trackVisitation.dart';
import 'package:nav_pos/userProfile.dart';

import 'customerShops.dart';
import 'dashboardPage.dart';

class MyNevBar extends StatefulWidget {
  @override
  _MyNevBarState createState() => _MyNevBarState();
}

class _MyNevBarState extends State<MyNevBar> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    statics(),
    ScanQr(),
    dashboardPage(),
    trackVisitation(),
    sideMenuPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart),
            label: "Statictics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code),
            label: "Scan Qr",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Items",
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.wallet),
          //   label: "Wallet",
          // ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Visitation",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: "Menu",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

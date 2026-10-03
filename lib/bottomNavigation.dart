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
import 'theme/app_theme.dart';

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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1D4A).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: [
                for (int i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavItem(
                      item: _items[i],
                      selected: i == _selectedIndex,
                      onTap: () => _onItemTapped(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static const _items = [
    _NavItemData(Icons.home_outlined, Icons.home_rounded, "Home"),
    _NavItemData(Icons.qr_code_scanner_rounded, Icons.qr_code_scanner_rounded,
        "Scan"),
    _NavItemData(
        Icons.inventory_2_outlined, Icons.inventory_2_rounded, "Items"),
    _NavItemData(
        Icons.location_on_outlined, Icons.location_on_rounded, "Visits"),
    _NavItemData(Icons.menu_rounded, Icons.menu_rounded, "Menu"),
  ];
}

class _NavItemData {
  const _NavItemData(this.icon, this.selectedIcon, this.label);

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavItemData item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(selected ? item.selectedIcon : item.icon,
                    color: color, size: 26),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

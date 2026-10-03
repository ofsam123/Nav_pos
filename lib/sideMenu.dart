import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ReturnOrderLogic.dart';
import 'Staticticsdetail.dart/TotalItemRecieved.dart';
import 'Staticticsdetail.dart/TotalItemsSold.dart';
import 'Staticticsdetail.dart/salesOrderOpen.dart';
import 'Staticticsdetail.dart/transferToRecieve.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class sideMenuPage extends StatefulWidget {
  const sideMenuPage({super.key});

  @override
  State<sideMenuPage> createState() => _sideMenuPageState();
}

class _sideMenuPageState extends State<sideMenuPage> {
  final Helper helper = new Helper();
  String _userName = "";
  String _resCenter = "";
  String _locationCode = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _userName = prefs.getString('User_Name') ?? '';
      _resCenter = prefs.getString('userResCenter') ?? '';
      _locationCode = prefs.getString('Location_Code') ?? '';
    });
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _buildProfileCard() {
    final location = displayValue(_locationCode, fallback: '');
    final center = displayValue(_resCenter, fallback: '');
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              initialsOf(_userName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayValue(_userName, fallback: 'Signed in'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  location.isEmpty
                      ? "Sales Rep"
                      : "Sales Rep  •  Location $location",
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 15,
                  ),
                ),
                if (center.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      "Responsibility center: $center",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuGroup(List<Widget> tiles) {
    final children = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      if (i > 0) children.add(const Divider(indent: 16, endIndent: 16));
      children.add(tiles[i]);
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(children: children),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color color,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 22, 6, 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          letterSpacing: 1.0,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
          children: [
            _buildProfileCard(),
            _sectionLabel("Sales"),
            _menuGroup([
              _menuTile(
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
                title: "Sales orders",
                onTap: () => _open(salesOrder(resCenter: _resCenter)),
              ),
              _menuTile(
                icon: Icons.shopping_cart_rounded,
                color: AppColors.success,
                title: "Items sold today",
                onTap: () => _open(totalItemsSold(resCenter: _resCenter)),
              ),
              _menuTile(
                icon: Icons.inventory_2_outlined,
                color: AppColors.purple,
                title: "Items received",
                onTap: () => _open(
                    totalItemsRevived(responsibilityCenter: _resCenter)),
              ),
            ]),
            _sectionLabel("Transfers"),
            _menuGroup([
              _menuTile(
                icon: Icons.swap_horiz_rounded,
                color: AppColors.primaryLight,
                title: "Transfers to receive",
                onTap: () =>
                    _open(TransferToRecieve(responsCenter: _resCenter)),
              ),
              _menuTile(
                icon: Icons.undo_rounded,
                color: AppColors.warning,
                title: "Return orders",
                onTap: () => _open(ReturnOrderLogic(rc: _resCenter)),
              ),
            ]),
            _sectionLabel("App"),
            _menuGroup([
              _menuTile(
                icon: Icons.info_outline_rounded,
                color: AppColors.primary,
                title: "About Nav POS",
                trailing: const Text(
                  "v1.0",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: "Nav POS",
                  applicationVersion: "v1.0",
                  applicationLegalese: "Powered by Synergy Center",
                ),
              ),
            ]),
            const SizedBox(height: 18),
            _menuGroup([
              InkWell(
                onTap: () {
                  logoutAlert(context);
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.logout_rounded,
                            color: AppColors.danger, size: 26),
                      ),
                      const SizedBox(width: 18),
                      const Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  logoutAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            icon: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.danger, size: 28),
            ),
            title: const Text("Log out?"),
            content: const Text(
              "Do you want to logout ?",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 15),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        helper.logoutFunc(context);
                      },
                      child: const Text("Logout"),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}

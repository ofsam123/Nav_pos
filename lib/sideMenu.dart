import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';

// import 'menuItemsComponent.dart/inventoryAvailable.dart';
// import 'menuItemsComponent.dart/itemsSoldToday.dart';
// import 'menuItemsComponent.dart/itemsSoldTodayByCustomer.dart';
// import 'menuItemsComponent.dart/salesOrde.dart';

class sideMenuPage extends StatefulWidget {
  const sideMenuPage({super.key});

  @override
  State<sideMenuPage> createState() => _sideMenuPageState();
}

class _sideMenuPageState extends State<sideMenuPage> {
  final Helper helper = new Helper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Menu",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: ListView(
          children: [
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: ((context) => SalesOrder())));
            //   },
            //   child: Card(
            //     color: Colors.white,
            //     //                           <-- Card widget
            //     child: ListTile(
            //       leading: Icon(Icons.list_alt),
            //       title: Text("Sales Order"),
            //       subtitle: Text(
            //         "create a new sales order for items",
            //         style: TextStyle(color: Colors.grey),
            //       ),
            //       trailing: Icon(Icons.arrow_forward_ios),
            //     ),
            //   ),
            // ),

            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(context,
            //         MaterialPageRoute(builder: ((context) => itemSoldToday())));
            //   },
            //   child: Card(
            //     color: Colors.white,
            //     //                           <-- Card widget
            //     child: ListTile(
            //       leading: Icon(Icons.sell),
            //       title: Text("Item Sold Today"),
            //       trailing: Icon(Icons.arrow_forward_ios),
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: ((context) => ItemsSoldTodayByCustomer())));
            //   },
            //   child: Card(
            //     color: Colors.white,
            //     //                           <-- Card widget
            //     child: ListTile(
            //       leading: Icon(Icons.sell_outlined),
            //       title: Text("Item Sold Today - Customer"),
            //       trailing: Icon(Icons.arrow_forward_ios),
            //     ),
            //   ),
            // ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //             builder: ((context) => AvailableInventory())));
            //   },
            //   child: Card(
            //     color: Colors.white,
            //     //                           <-- Card widget
            //     child: ListTile(
            //       leading: Icon(Icons.inventory),
            //       title: Text("Inventory Available"),
            //       subtitle: Text(
            //         "create a new sales order for items",
            //         style: TextStyle(color: Colors.grey),
            //       ),
            //       trailing: Icon(Icons.arrow_forward_ios),
            //     ),
            //   ),
            // ),

            GestureDetector(
              onTap: () {
                logoutAlert(context);
              },
              child: Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  title: Text(
                    "        LOG0UT",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(
                    Icons.logout_sharp,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
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
            //title: Text("Do you want to logout ?"),
            content: Text("Do you want to logout ?"),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    helper.logoutFunc(context);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

              /*TextButton(
                child: textNormal("Logout", Colors.red, largeText),
                onPressed: () {
                  Navigator.of(context).pop();
                  logoutFunc(context);
                },
              )*/
            ],
          );
        });
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/Models/transferLineModel.dart';
import 'package:nav_pos/ReturnOrder2page.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:nav_pos/statictis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'API.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class ReturnOrderLogic extends StatefulWidget {
  ReturnOrderLogic({super.key, required this.rc});

  String? rc;

  @override
  State<ReturnOrderLogic> createState() => _ReturnOrderLogicState();
}

class _ReturnOrderLogicState extends State<ReturnOrderLogic> {
  final Helper helper = new Helper();

  late Future<List<transferLineModel>> _func;

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Sales_Resp_Ctr_Filter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  List<String> hiddenItems = [];
  DateTime now = DateTime.now();

  String transferToo = "";
  String UserName = "";
  String reQty = "";
  String reSold = "";
  String reItemsNo = "";
  String Noss = "";
  String THNo = "";
  String POS_Statuss = "";
  String Qrd = "";
  String ITMZ = "";
  String US = "";

  List<String> matchingItemNos = [];
  List<int> subtractedQuantities = [];
  List<String> qtyReceivedList = [];
  List<String> qtySoldList = [];
  List<String> unmatchedItemNos = [];

  int totalItems = 0;

  @override
  void initState() {
    // _func = _THETransferLine();
    QRecieve11();
    super.initState();
    _getUserData();

    totalItems = matchingItemNos.length + unmatchedItemNos.length;

    // _getTransferHeader();

    Timer(Duration(seconds: 2), () {
      // _getTransferHeader();

      setState(() {});
    });
  }
// Declare totalItems here

  void deleteItem(int index) {
    setState(() {
      // Remove the item from the respective lists

      if (index < matchingItemNos.length) {
        matchingItemNos.removeAt(index);
        subtractedQuantities.removeAt(index);
      } else {
        int unmatchedIndex = index - matchingItemNos.length;
        if (unmatchedIndex < unmatchedItemNos.length) {
          unmatchedItemNos.removeAt(unmatchedIndex);
        }
      }
    });
  }

  // Map to store grouped items with combined return quantity
  Map<String, int> groupedItems = {};
  // ... other methods
  void calculateSubtractedQuantities() {
    subtractedQuantities.clear();
    matchingItemNos.clear();
    groupedItems.clear(); // Clear the grouped items

    if (reItemsNo.isNotEmpty && Noss.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> nosList = Noss.split(', ');
      List<String> qtySoldList = reSold.split(', '); // Fetch qtySold values

      for (String itemNo in itemsNoList) {
        int qtyReceived = int.tryParse(getQtyReceived(itemNo)) ?? 0;
        int qtySoldIndex = nosList.indexOf(itemNo);

        if (qtySoldIndex != -1 && qtySoldIndex < qtySoldList.length) {
          int qtySold = int.tryParse(qtySoldList[qtySoldIndex]) ?? 0;
          int subtractedQty = qtyReceived - qtySold;

          // Group the items by Item No and combine the Return Quantity
          //  int subtractedQty = qtyReceived - qtySold;
          if (groupedItems.containsKey(itemNo)) {
            groupedItems[itemNo] = (groupedItems[itemNo] ?? 0) +
                subtractedQty; // Add a null check here
          } else {
            groupedItems[itemNo] = subtractedQty;
          }
        } else {
          // Item is unmatched, add it to unmatchedItemNos
          unmatchedItemNos.add(itemNo);
        }
      }

      // Extract grouped items back to lists
      for (var item in groupedItems.entries) {
        matchingItemNos.add(item.key);
        subtractedQuantities.add(item.value);
      }
    }
  }

  void findAndHideRepeatingItems(List<transferLineModel> items) {
    Set<String> seenItems = Set<String>();
    List<String> repeatingItems = [];

    // Check for repeating items in matchingItemNos
    for (String itemNo in matchingItemNos) {
      if (seenItems.contains(itemNo)) {
        repeatingItems.add(itemNo);
      } else {
        seenItems.add(itemNo);
      }
    }

    // Check for repeating items in unmatchedItemNos
    for (String itemNo in unmatchedItemNos) {
      if (seenItems.contains(itemNo)) {
        repeatingItems.add(itemNo);
      } else {
        seenItems.add(itemNo);
      }
    }

    // Hide repeating items
    hiddenItems.addAll(repeatingItems);
    setState(() {});
  }

  void deleteItem1(int index) {
    String currentItemNo;

    if (index < matchingItemNos.length) {
      // Display matched item
      currentItemNo = matchingItemNos[index];
    } else {
      // Display unmatched item
      int unmatchedIndex = index - matchingItemNos.length;
      currentItemNo = unmatchedItemNos[unmatchedIndex];
    }

    // Check if ITMZ contains currentItemNo
    if (ITMZ.contains(currentItemNo)) {
      setState(() {
        // Remove the item from the corresponding list
        if (index < matchingItemNos.length) {
          matchingItemNos.removeAt(index);
        } else {
          unmatchedItemNos.removeAt(index - matchingItemNos.length);
        }
      });
    }
  }

  Map<String, String> transferFromCodes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Daily Return Items"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
                tooltip: 'History',
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => nonReturnedItemHistory(
                                rc: widget.rc.toString(),
                              )));
                },
                icon: const Icon(Icons.history_rounded)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Container(
            //   child: ListView.builder(
            //       shrinkWrap: true,
            //       physics: NeverScrollableScrollPhysics(),
            //       itemCount: matchingItemNos.length + unmatchedItemNos.length,
            //       itemBuilder: (BuildContext context, int index) {
            //         if (matchingItemNos.isEmpty && unmatchedItemNos.isEmpty) {
            //           // Display a message when the list is empty
            //           return ListTile(
            //             title: Text('No items to be Return'),
            //           );
            //         }

            //         Widget deleteButton = IconButton(
            //           icon: Icon(Icons.delete, color: Colors.red),
            //           onPressed: () {
            //             deleteItem(index);
            //           },
            //         );

            //         String currentItemNo;
            //         String transferFromCode;
            //         if (index < matchingItemNos.length) {
            //           // Display matched item
            //           currentItemNo = matchingItemNos[index];
            //           transferFromCode =
            //               transferFromCodes[currentItemNo] ?? 'Not available';
            //           return ListTile(
            //             title: Text(
            //               'Item No: $currentItemNo',
            //               style: TextStyle(
            //                 fontSize: 16.0,
            //                 fontWeight: FontWeight.bold,
            //                 // color: getItemColor(matchingItemNos[index])
            //               ),
            //             ),
            //             subtitle: Text(
            //               'Return Quantity: ${subtractedQuantities[index]}',
            //               style: TextStyle(fontSize: 14.0),
            //             ),
            //             trailing: deleteButton,
            //           );
            //         } else {
            //           // Display unmatched item
            //           int unmatchedIndex = index - matchingItemNos.length;
            //           currentItemNo = unmatchedItemNos[unmatchedIndex];
            //           return ListTile(
            //             title: Text(
            //               ' Item No: $currentItemNo',
            //               style: TextStyle(
            //                 fontSize: 16.0,
            //                 fontWeight: FontWeight.bold,
            //                 // color: getItemColor(unmatchedItemNos[unmatchedIndex]),
            //               ),
            //             ),
            //             subtitle: Text(
            //               'Return Quantity: ${getQtyReceived(unmatchedItemNos[unmatchedIndex])}',
            //               style: TextStyle(fontSize: 14.0),
            //             ),
            //             trailing: deleteButton,
            //           );
            //         }
            //       }),
            // ),
            if (matchingItemNos.isEmpty && unmatchedItemNos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyState(
                  icon: Icons.assignment_return_outlined,
                  title: 'No items to return',
                  message: 'Items due for return today will appear here.',
                ),
              )
            else ...[
              const SmallCapsLabel('Items to return'),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: matchingItemNos.length + unmatchedItemNos.length,
                itemBuilder: (BuildContext context, int index) {
                  if (matchingItemNos.isEmpty && unmatchedItemNos.isEmpty) {
                    // Display a message when the list is empty
                    return const EmptyState(
                      icon: Icons.assignment_return_outlined,
                      title: 'No items to return',
                    );
                  }

                  Widget deleteButton = IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.danger),
                    onPressed: () {
                      deleteItem(index);
                    },
                  );

                  String currentItemNo;

                  if (index < matchingItemNos.length) {
                    // Display matched item
                    currentItemNo = matchingItemNos[index];
                  } else {
                    // Display unmatched item
                    int unmatchedIndex = index - matchingItemNos.length;
                    currentItemNo = unmatchedItemNos[unmatchedIndex];
                  }

                  bool shouldHideItem = ITMZ.contains(currentItemNo);

                  return shouldHideItem
                      ? Container()
                      : _ReturnItemCard(
                          title: 'Item No: $currentItemNo',
                          subtitle: index < matchingItemNos.length
                              ? 'Return Quantity: ${subtractedQuantities[index]}'
                              : 'Return Quantity: ${getQtyReceived(unmatchedItemNos[index - matchingItemNos.length])}',
                          trailing: deleteButton,
                        );
                },
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar:
          (matchingItemNos.isNotEmpty || unmatchedItemNos.isNotEmpty)
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _getTransferHeader(
                            transferFromCodes[transferFromCodes] ?? "KT");
                        // sendReturnItems();
                        // Call the function when the button is pressed
                      },
                      icon: const Icon(Icons.assignment_return_outlined),
                      label: const Text('Return Items'),
                    ),
                  ),
                )
              : null, // Set to null when the list is empty
    );
  }

  String matchingItemNo = "";

  void compareAndDisplayAppBarValue() {
    if (reItemsNo.isNotEmpty && Noss.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> nosList = Noss.split(', ');

      for (String itemNo in itemsNoList) {
        if (nosList.contains(itemNo)) {
          setState(() {
            matchingItemNo = itemNo;
          });
          break;
        }
      }
    }
  }

  Future<void> QRecieve() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    // AppLoadingDialog progressDialog =
    //     AppLoadingDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "Loading ...",
    // );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          //  "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/QuantityReceivedAPI?" +
          //       "\$filter=Transfer_to_Code eq '${widget.rc}' and Receipt_Date eq ${now.year}-10-26"),

          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq '${widget.rc}' and Receipt_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    // progressDialog.hide();

    if (response.statusCode == 200) {
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      List<int> quantities = [];
      List<String> itemNos = [];

      String transferto =
          responseJson["value"][0]["Transfer_from_Code"].toString();

      String Qrd = responseJson["value"][0]["Receipt_Date"].toString();

      // helper.alertDialogNoTitle(resCenter, context);

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Received"].toString()) ?? 0;
        quantities.add(quantity);
      }
      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
        String transferFromCode = item["Transfer_from_Code"].toString();
        transferFromCodes[itemNo] = transferFromCode;
        itemNos.add(itemNo);
      }

      String itemNosString = itemNos.join(', ');
      String quantitiesString = quantities.join(', ');

      setState(() {
        reQty = quantitiesString;
        reItemsNo = itemNosString;
        transferToo = transferto;
      });
      compareAndDisplayAppBarValue();

      calculateSubtractedQuantities();
      fetchQtyReceivedValues();
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Error submiting Try again Later', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  // ... (rest of your code remains the same)

  Future<void> _getTransferHeader(String transferFromCode) async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .post(Uri.parse(ApiUrl.TransferHeaderAPI),
            headers: {
              'Content': 'application/x-www-form-urlencoded',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$basicAuth',
              "Access-Control-Allow-Origin": "*",
            },
            body: jsonEncode(<String, String>{
              //"userTypeId": "c2900cf4-d6a1-4115-b2e6-d051844b418f"//
              "Transfer_from_Code": widget.rc.toString(),
              // "Transfer_from_Code": "SAL2",
              "Transfer_to_Code": transferFromCode,
              // "Transfer_to_Code": "KT",
              "Posting_Date": "${now.year}-${now.month}-${now.day}",
              "Assigned_User_ID": UserName.toString(),
              "In_Transit_Code": "OUT- LOG",
              "POS_Status": "Returned",
            }))
        .catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 201) {
      progressDialog.hide();

      String No = responseJson["No"].toString();
      String POS_Status = responseJson["POS_Status"].toString();

      helper.alertDialogNoTitle(No, context);
      // sendReturnItems();
      //   Timer(Duration(seconds: 1), () {

      //   setState(() {});
      // });
      setState(() {
        THNo = No.toString();
        POS_Statuss = POS_Status.toString();
        sendReturnItems();
      });

      // String role1 = responseJson["roles"].toString();
      // String active      = responseJson["active"] .toString();
      // progressDialog.hide();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString('User_ID_2', User_ID_2);
      prefs.setString('No', No);
      progressDialog.hide();

      // helper.flushBar2("Success", " Successful", context);
    } else {
      progressDialog.hide();
      // helper.flushBar2("Error", response.body, context);

      helper.alertDialogNoTitle(response.body, context);
    }
  }

  // ... (Rest of your code remains the same)

  Future<void> _getTransferLine(String itemNo, int quantity) async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .post(Uri.parse(ApiUrl.TransferLineAPI),
            headers: {
              'Content': 'application/x-www-form-urlencoded',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$basicAuth',
              "Access-Control-Allow-Origin": "*",
            },
            body: jsonEncode(<String, dynamic>{
              // "Document_No": "5073",
              "Document_No": THNo.toString(),
              "Item_No": itemNo, // Use the itemNo parameter here
              "Quantity": quantity,
              // "POS_Status": POS_Statuss.toString()
              // Use the quantity parameter here as an int
            }))
        .catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 201) {
      progressDialog.hide();
    } else {
      progressDialog.hide();
      // helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> QSold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/QuantitySoldAPI?" +
              "\$filter=Location eq '${widget.rc}' and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();

    if (response.statusCode == 200) {
      progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      List<int> quantities1 = [];
      List<String> NoS = [];

      for (var item in responseJson["value"]) {
        int quantity1 = int.tryParse(item["Qty_Sold"].toString()) ?? 0;
        quantities1.add(quantity1);
      }
      for (var item in responseJson["value"]) {
        String itemNo = item["No"].toString();
        NoS.add(itemNo);
      }

      String NosString = NoS.join(', ');
      String quantitiesString1 = quantities1.join(', ');

      //helper.alertDialogNoTitle(response.body, cont)

      setState(() {
        reSold = quantitiesString1;
        Noss = NosString;
      });
      compareAndDisplayAppBarValue();

      calculateSubtractedQuantities();
      fetchQtyReceivedValues();
      fetchQtySoldValues(); // Fetch Qty_Sold values
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", 'Try Again later', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  void fetchQtyReceivedValues() {
    qtyReceivedList.clear();

    if (reItemsNo.isNotEmpty && Noss.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> nosList = Noss.split(', ');

      for (String itemNo in itemsNoList) {
        if (nosList.contains(itemNo)) {
          int index = nosList.indexOf(itemNo);
          qtyReceivedList.add(reQty.split(', ')[index]);
        }
      }
    }
  }

  void fetchQtySoldValues() {
    qtySoldList.clear();

    if (reItemsNo.isNotEmpty && Noss.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> nosList = Noss.split(', ');

      for (String itemNo in itemsNoList) {
        if (nosList.contains(itemNo)) {
          int index = nosList.indexOf(itemNo);
          qtySoldList.add(reSold.split(', ')[index]);
        }
      }
    }
  }

  String getQtyReceived(String itemNo) {
    if (reItemsNo.isNotEmpty && reQty.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> qtyList = reQty.split(', ');

      int index = itemsNoList.indexOf(itemNo);
      if (index >= 0 && index < qtyList.length) {
        return qtyList[index];
      }
    }
    return "N/A";
  }

  void sendReturnItems() async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(
      context: context,
      barrierDimisable: true,
    );

    progressDialog.show(
      message: "Returning Items...",
    );

    for (int i = 0; i < matchingItemNos.length; i++) {
      await _getTransferLine(matchingItemNos[i], subtractedQuantities[i]);
    }

    for (String itemNo in unmatchedItemNos) {
      String qtyReceived = getQtyReceived(itemNo);
      int quantity = int.tryParse(qtyReceived) ?? 0;
      await _getTransferLine(itemNo, quantity);
    }

    progressDialog.hide();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Items returned successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                // Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyNevBar()));
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> QRecieve11() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(ApiUrl.TransferLineAPI),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    if (response.statusCode == 200) {
      progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      List<String> itemNos = [];
      List<String> UID = [];

      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
        String assignedUserId = item["Assigned_User_ID"].toString();
        String receipt_Date = item["Receipt_Date"].toString();

        String Completely_Shipped = item["Completely_Shipped"].toString();

        if (assignedUserId == UserName &&
                receipt_Date == "${now.year}-${now.month}-${now.day}" &&
                Completely_Shipped == "false" ||
            Completely_Shipped == "true") {
          itemNos.add(itemNo);
        }
      }

      String itemNosString = itemNos.join(', ');

      setState(() {
        ITMZ = itemNosString;
        QRecieve();
        QSold();
      });
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", 'Error submitting. Try again Later', context);
    }
  }
}

class _ReturnItemCard extends StatelessWidget {
  const _ReturnItemCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: AppColors.textMuted, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nav_pos/API.dart';
import 'package:nav_pos/Models/quanRecieveModel.dart';
import 'package:nav_pos/Models/transferLineModel.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:http/http.dart' as http;

import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class nonReturnedItemHistory extends StatefulWidget {
  nonReturnedItemHistory({super.key, required this.rc});

  String? rc;

  @override
  State<nonReturnedItemHistory> createState() => _nonReturnedItemHistoryState();
}

class _nonReturnedItemHistoryState extends State<nonReturnedItemHistory> {
  final Helper helper = new Helper();

  late Future<List<transferLineModel>> _func;

  late Future<List<quanRecModel>> _func2;

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
  String ITMZz = "";
  String US = "";

  List<String> matchingItemNos = [];
  List<int> subtractedQuantities = [];
  List<String> qtyReceivedList = [];
  List<String> qtySoldList = [];
  List<String> unmatchedItemNos = [];

  int totalItems = 0;

  @override
  void initState() {
    _func = _THETransferLine();
    //  _func = _getItems1();
    QRecieve11();

    QRecieve22();
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

  DateTime today = DateTime.now();

  DateTime threeDaysAgo = DateTime.now().subtract(Duration(days: 3));

  Map<String, String> transferFromCodes =
      {}; // Initialize an empty map to hold Transfer_from_Code data
  Future<void> removeItemAfterBuild(int index) async {
    await Future.delayed(Duration.zero);
    setState(() {
      if (index < matchingItemNos.length) {
        matchingItemNos.removeAt(index);
      } else {
        unmatchedItemNos.removeAt(index - matchingItemNos.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Items To be Returned"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (matchingItemNos.isEmpty && unmatchedItemNos.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: EmptyState(
                  icon: Icons.assignment_return_outlined,
                  title: 'No items to return',
                  message: 'Items pending return will appear here.',
                ),
              )
            else ...[
              const SmallCapsLabel('Pending returns'),
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
                      removeItemAfterBuild(index);
                    },
                  );

                  String currentItemNo;
                  String transferFromCode;

                  if (index < matchingItemNos.length) {
                    // Display matched item
                    currentItemNo = matchingItemNos[index];
                  } else {
                    // Display unmatched item
                    int unmatchedIndex = index - matchingItemNos.length;
                    currentItemNo = unmatchedItemNos[unmatchedIndex];
                  }

                  bool shouldRemoveItem = ITMZz.contains(currentItemNo) ||
                      ITMZ.contains(currentItemNo);
                  transferFromCode =
                      transferFromCodes[currentItemNo] ?? 'Not available';

                  if (shouldRemoveItem) {
                    deleteItem1(index);
                    return Container();
                  }

                  return _ReturnItemCard(
                    title: 'Item No: $currentItemNo',
                    subtitle: [
                      'From: $transferFromCode',
                      index < matchingItemNos.length
                          ? 'Return Quantity: ${subtractedQuantities[index]}'
                          : 'Return Quantity: ${getQtyReceived(unmatchedItemNos[index - matchingItemNos.length])}',
                    ].join('  •  '),
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq '${widget.rc}'"),
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

      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
        String transferFromCode = item["Transfer_from_Code"].toString();
        transferFromCodes[itemNo] =
            transferFromCode; // Associate Transfer_from_Code with each item number
      }

      List<int> quantities = [];
      List<String> itemNos = [];
      List<String> transferTo2 = [];

      // String transferto =
      //     responseJson["value"][0]["Transfer_from_Code"].toString();

      String Qrd = responseJson["value"][0]["Receipt_Date"].toString();

      // helper.alertDialogNoTitle(resCenter, context);

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Received"].toString()) ?? 0;
        quantities.add(quantity);
      }
      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
        itemNos.add(itemNo);
      }

      for (var item in responseJson["value"]) {
        String transferTu = item["Transfer_from_Code"].toString();
        transferTo2.add(transferTu);
      }

      String itemNosString = itemNos.join(', ');
      String quantitiesString = quantities.join(', ');

      String transferTo2String = transferTo2.join(', ');

      setState(() {
        reQty = quantitiesString;
        reItemsNo = itemNosString;
        transferToo = transferTo2String;
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
              "Transfer_from_Code": widget.rc.toString(),

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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantitySoldAPI?" +
              "\$filter=Location eq '${widget.rc}'"),
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

  Future<List<transferLineModel>> _THETransferLine() async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "loading ...",
    );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    try {
      final response = await http.get(
        Uri.parse(ApiUrl.TransferLineAPI),
        headers: {
          'Content': 'application/x-www-form-urlencoded',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$basicAuth',
          "Access-Control-Allow-Origin": "*",
        },
      );

      if (response.statusCode == 200) {
        progressDialog.hide();
        final responseJson = jsonDecode(response.body);
        List responseList = json.decode(response.body)["value"];

        List<String> itemNos =
            responseList.map((item) => item["Item_No"].toString()).toList();

        String itemsString = itemNos.join(', ');

        // helper.alertDialogNoTitle(itemsString, context);
        // ITMZ = itemNos;

        return responseList
            .map((job) => transferLineModel.fromJson(job))
            .toList();
      } else {
        progressDialog.hide();
        helper.alertDialogTitle('${Helper.errorMessageOops}',
            '${Helper.errorMessageSomethingWentWrong}', context);
        // Add a return statement here
        return <transferLineModel>[];
      }
    } catch (error) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
      throw error;
    }
  }

  Future<void> QRecieve22() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?\$filter=Transfer_from_Code eq '${widget.rc}'"),
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

    if (response.statusCode == 200) {
      // progressDialog.hide();
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      String itemNoList = ''; // String to accumulate Item_No values

      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
        String assignedUserId = item["Assigned_User_ID"].toString();
        String receipt_Date = item["Receipt_Date"].toString();
        String Completely_Shipped = item["Completely_Shipped"].toString();

        itemNoList += '$itemNo\n'; // Accumulate Item_No values with new lines
      }

      setState(() {
        ITMZz = itemNoList;
      });

      // Display all Item_No values in an AlertDialog
      // helper.alertDialogNoTitle(itemNoList, context);
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Error submitting. Try again Later', context);
    }
  }

  // ... (rest of your code remains the same)

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

        //   if (assignedUserId == "REP" &&
        //       receipt_Date == "${now.year}-${now.month}-${now.day}") {
        //     itemNos.add(itemNo);
        //   }
        // }
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
        // _func2 = _getquant();
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


  // Future<List<quanRecModel>> _getquant() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String resCenter = prefs.getString('Sales_Resp_Ctr_Filter') ?? '';
  //   String basicAuth = 'Basic ' +
  //       base64Encode(
  //           utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

  //   final response = await http.get(
  //     Uri.parse(
  //         "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
  //             "\$filter=Transfer_to_Code eq '${widget.rc}'"),
  //     headers: {
  //       'Content': 'application/x-www-form-urlencoded',
  //       'Content-Type': 'application/json',
  //       'Accept': 'application/json',
  //       'Authorization': '$basicAuth',
  //       "Access-Control-Allow-Origin": "*",
  //     },
  //   ).catchError((err) {
  //     helper.alertDialogTitle('${Helper.errorMessageOops}',
  //         '${Helper.errorMessageSomethingWentWrong}', context);
  //   });

  //   if (response.statusCode == 200) {
  //     final responseJson = jsonDecode(response.body);
  //     String apiResponse = responseJson["value"].toString();
  //     List responseList = json.decode(response.body)["value"];

  //     // Calculate the sum of quantities for each unique Item_No

  //     return responseList.map((job) => quanRecModel.fromJson(job)).toList();
  //   } else {
  //     helper.alertDialogNoTitle(response.body, context);
  //     throw Exception('Failed to load post');
  //   }
  // }



  // FutureBuilder(
            //   future: _func2,
            //   builder: (context, data) {
            //     if (data.hasError) {
            //       return Center(
            //           child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Text("Oops!! 😔"),
            //           Text("Failed later"),
            //         ],
            //       ));
            //     } else if (data.hasData) {
            //       var items = data.data as List<quanRecModel>;
            //       if (items.isEmpty) {
            //         // Display an alert dialog when the list is empty
            //         return Center(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("No Items to be return Today"),
            //             ],
            //           ),
            //         );
            //       }
            //       return ListView.builder(
            //           itemCount: items == null ? 0 : items.length,
            //           physics: ClampingScrollPhysics(),
            //           shrinkWrap: true,
            //           scrollDirection: Axis.vertical,
            //           itemBuilder: (context, index) {
            //             return Padding(
            //               padding: const EdgeInsets.all(2),
            //               child: GestureDetector(
            //                 onTap: () {},
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     color: Colors.white,
            //                     borderRadius: BorderRadius.circular(10),
            //                   ),
            //                   width: MediaQuery.of(context).size.width / 1.1,
            //                   child: Padding(
            //                       padding: const EdgeInsets.only(
            //                           right: 10.0, top: 5),
            //                       child: Column(
            //                         children: [
            //                           Padding(
            //                             padding: const EdgeInsets.only(
            //                                 left: 20, right: 20, top: 05),
            //                             child: Column(
            //                               mainAxisAlignment:
            //                                   MainAxisAlignment.start,
            //                               crossAxisAlignment:
            //                                   CrossAxisAlignment.start,
            //                               children: [
            //                                 Text(
            //                                   items[index].Item_No.toString(),
            //                                   style:
            //                                       TextStyle(color: Colors.grey),
            //                                 ),
            //                                 Container(
            //                                   height: 80,
            //                                   decoration: BoxDecoration(
            //                                       borderRadius:
            //                                           BorderRadius.circular(15),
            //                                       color: Colors.white),
            //                                   child: Column(
            //                                     mainAxisAlignment:
            //                                         MainAxisAlignment.center,
            //                                     crossAxisAlignment:
            //                                         CrossAxisAlignment.start,
            //                                     children: [
            //                                       Row(
            //                                         children: [
            //                                           Padding(
            //                                             padding:
            //                                                 const EdgeInsets
            //                                                     .only(left: 0),
            //                                             child: Text(
            //                                               "QTY" +
            //                                                   items[index]
            //                                                       .Qty_Received
            //                                                       .toString(),
            //                                               style: TextStyle(
            //                                                   fontWeight:
            //                                                       FontWeight
            //                                                           .bold),
            //                                             ),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                       SizedBox(
            //                                         height: 10,
            //                                       ),
            //                                       Row(
            //                                         children: [
            //                                           Padding(
            //                                             padding:
            //                                                 const EdgeInsets
            //                                                     .only(left: 0),
            //                                             child: Text(
            //                                               "SFC " +
            //                                                   items[index]
            //                                                       .Transfer_from_Code
            //                                                       .toString(),
            //                                               style: TextStyle(
            //                                                   fontSize: 15,
            //                                                   color:
            //                                                       Colors.green,
            //                                                   fontWeight:
            //                                                       FontWeight
            //                                                           .bold),
            //                                             ),
            //                                           ),
            //                                           Spacer(),
            //                                           Padding(
            //                                             padding:
            //                                                 const EdgeInsets
            //                                                     .only(
            //                                                     right: 8.0),
            //                                             child: Text(
            //                                               items[index]
            //                                                   .Receipt_Date
            //                                                   .toString(),
            //                                               style: TextStyle(
            //                                                   color:
            //                                                       Colors.grey,
            //                                                   fontWeight:
            //                                                       FontWeight
            //                                                           .bold),
            //                                             ),
            //                                           ),
            //                                         ],
            //                                       ),
            //                                     ],
            //                                   ),
            //                                 ),
            //                               ],
            //                             ),
            //                           ),
            //                           Divider()
            //                         ],
            //                       )),
            //                 ),
            //               ),
            //             );
            //           });
            //     } else {
            //       return Center(
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Container(
            //                 height: 140,
            //                 child: Image.asset("assets/images/loading.gif"))
            //           ],
            //         ),
            //       );
            //     }
            //   },
            // ),
         
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/statictis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'API.dart';

class ReturnOrderLogic extends StatefulWidget {
  ReturnOrderLogic({required String responsibilityCenter});

  String? responsibilityCenter;

  @override
  State<ReturnOrderLogic> createState() => _ReturnOrderLogicState();
}

class _ReturnOrderLogicState extends State<ReturnOrderLogic> {
  final Helper helper = new Helper();

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Sales_Resp_Ctr_Filter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  DateTime now = DateTime.now();
  String transferToo = "";
  String UserName = "";
  String reQty = "";
  String reSold = "";
  String reItemsNo = "";
  String Noss = "";
  String THNo = "";
  List<String> matchingItemNos = [];
  List<int> subtractedQuantities = [];
  List<String> qtyReceivedList = [];
  List<String> qtySoldList = [];
  List<String> unmatchedItemNos = [];

  @override
  void initState() {
    super.initState();
    _getUserData();
    QRecieve();
    QSold();
    // _getTransferHeader();

    Timer(Duration(seconds: 1), () {
      // _getTransferHeader();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Return Items"),
        actions: [],
      ),
      body: Column(
        children: [
          // Display matched and unmatched ItemNos and quantities
          ListView.builder(
            shrinkWrap: true,
            itemCount:
                (matchingItemNos.isNotEmpty ? matchingItemNos.length : 1) +
                    (unmatchedItemNos.isNotEmpty ? unmatchedItemNos.length : 1),
            itemBuilder: (BuildContext context, int index) {
              if (matchingItemNos.isEmpty && unmatchedItemNos.isEmpty) {
                // Display a message when the list is empty
                return ListTile(
                  title: Text('No items to return'),
                  // subtitle: Text('Add items to the return list.'),
                );
              }

              if (index <
                  (matchingItemNos.isNotEmpty ? matchingItemNos.length : 1)) {
                // Display matched item
                return ListTile(
                  title: Text(
                    'Item No: ${matchingItemNos[index]}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Return Quantity: ${subtractedQuantities[index]}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                );
              } else {
                // Display unmatched item
                int unmatchedIndex = index -
                    (matchingItemNos.isNotEmpty ? matchingItemNos.length : 1);
                return ListTile(
                  title: Text(
                    ' Item No: ${unmatchedItemNos[unmatchedIndex]}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Return Quantity: ${getQtyReceived(unmatchedItemNos[unmatchedIndex])}',
                    style: TextStyle(fontSize: 14.0),
                  ),
                );
              }
            },
          )
        ],
      ),
      floatingActionButton:
          (matchingItemNos.isNotEmpty || unmatchedItemNos.isNotEmpty)
              ? FloatingActionButton.extended(
                  onPressed: () {
                    _getTransferHeader();
                    // sendReturnItems(); // Call the function when the button is pressed
                  },
                  backgroundColor: Colors.black,
                  label: Text(
                    'Return Items',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : null, // Set to null when the list is empty
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    // SimpleFontelicoProgressDialog progressDialog =
    //     SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "Loading ...",
    // );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq '${widget.responsibilityCenter}' and Receipt_Date eq ${now.year}-${now.month}-${now.day}"),
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

      // helper.alertDialogNoTitle(resCenter, context);

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Received"].toString()) ?? 0;
        quantities.add(quantity);
      }
      for (var item in responseJson["value"]) {
        String itemNo = item["Item_No"].toString();
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

  Future<void> _getTransferHeader() async {
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
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
              "Transfer_from_Code": widget.responsibilityCenter.toString(),
              "Transfer_to_Code": transferToo.toString(),

              // "Transfer_to_Code": "KT",
              "Posting_Date": "${now.year}-${now.month}-07",
              "Assigned_User_ID": UserName.toString(),
              "In_Transit_Code": "OUT- LOG",
              "POS_Status": "Shipped",
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
      //   Timer(Duration(seconds: 1), () {

      //   setState(() {});
      // });
      setState(() {
        THNo = No.toString();
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
      helper.flushBar2("Error", 'Try again Later ', context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  // ... (Rest of your code remains the same)

  Future<void> _getTransferLine(String itemNo, int quantity) async {
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
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
      // await Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => statics()));

      // helper.alertDialogNoTitle(response.body, context);

      // helper.flushBar2("Successful", "Items Returned Successfully", contextR;
    } else {
      progressDialog.hide();
      // helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }
// //
  // ... (Rest of your code remains the same)

  Future<void> QSold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantitySoldAPI?" +
              "\$filter=Location eq '${widget.responsibilityCenter}' and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
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

  // ... (Rest of your code remains the same)

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

  void calculateSubtractedQuantities() {
    subtractedQuantities.clear();
    matchingItemNos.clear();

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
          subtractedQuantities.add(subtractedQty);

          matchingItemNos.add(itemNo);
        } else {
          // Item is unmatched, add it to unmatchedItemNos
          unmatchedItemNos.add(itemNo);
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
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(
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

    // Show a success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Items returned successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}

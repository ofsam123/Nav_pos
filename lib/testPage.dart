import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nav_pos/apiHelper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'API.dart';

class QuantityPage extends StatefulWidget {
  @override
  _QuantityPageState createState() => _QuantityPageState();
}

class _QuantityPageState extends State<QuantityPage> {
  int totalQuantityReceived = 0;
  int totalQuantitySold = 0;
  int difference = 0; // The difference between received and sold
  final Helper helper = new Helper();

  Future<void> QRecieve() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq 'SAL1' and Receipt_Date eq 2023-09-07"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      int total = 0;

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Received"].toString()) ?? 0;
        total += quantity;
      }

      setState(() {
        totalQuantityReceived = total;
        calculateDifference();
      });
    } else {
      helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> QSold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantitySoldAPI?" +
              "\$filter=Location eq 'SAL1' and Posting_Date eq 2023-09-07"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);

      int total = 0;

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Sold"].toString()) ?? 0;
        total += quantity;
      }

      setState(() {
        totalQuantitySold = total;
        calculateDifference();
      });
    } else {
      helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }

  void calculateDifference() {
    setState(() {
      difference = totalQuantityReceived - totalQuantitySold;
    });
  }

  @override
  void initState() {
    super.initState();
    QRecieve();
    QSold();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quantity Difference'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Difference (Received - Sold):',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              difference.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

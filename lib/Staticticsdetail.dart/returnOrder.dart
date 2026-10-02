import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/menuItemsComponent.dart/itemsSoldToday.dart';
import 'package:nav_pos/trackDeatails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API.dart';
import '../Models/itemsSoldModel.dart';
import '../Models/postedInvoiceDetailsModel.dart';
import '../Models/postedSalesInvoiceModel.dart';
import '../Models/returnOrder.dart';
import '../apiHelper.dart';

class returnOrder extends StatefulWidget {
  // returnOrder({required this.docsNo});

  // String? docsNo;
  @override
  State<returnOrder> createState() => _returnOrderState();
}

class _returnOrderState extends State<returnOrder> {
  final Helper helper = new Helper();

  late Future<List<returnOrderModel>> _func;

  @override
  void initState() {
    _func = _getItems1();
    Timer(Duration(seconds: 1), () {
      setState(() {
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  String? token;
  String? userTypeId;

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = (prefs.getString('token') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Return Order",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        // automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder(
                future: _func,
                builder: (context, data) {
                  if (data.hasError) {
                    return Center(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Oops!! 😔"),
                        Text("Failed later"),
                      ],
                    ));
                  } else if (data.hasData) {
                    var items = data.data as List<returnOrderModel>;
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("There is no data currently availble"),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                        itemCount: items == null ? 0 : items.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: GestureDetector(
                              onTap: () {},
                              child: Card(
                                color: Color.fromARGB(255, 246, 246, 246),
                                child: Column(
                                  children: [
                                    ListTile(
                                      leading: Icon(Icons.numbers),
                                      title: Text(
                                        "NO: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].No.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.details),
                                      title: Text(
                                        "Status: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].Status.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.numbers_outlined),
                                      title: Text(
                                        "Items Weight: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].Items_Weight.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.date_range),
                                      title: Text(
                                        "Posted Date: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].Posting_Date.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              height: 140,
                              child: Image.asset("assets/images/loading.gif"))
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<returnOrderModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq 2023-09-07 and Transfer_from_Code eq 'SAL1' and Completely_Shipped eq false"),
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
      if (responseJson.containsKey("value")) {
        List responseList = responseJson["value"];
        return responseList
            .map((job) => returnOrderModel.fromJson(job))
            .toList();
      } else {
        // Value is empty, don't show an alert, and return an empty list.

        // helper.alertDialogNoTitle("No Available List", context);
        return [];
      }
    } else {
      // If that call was not successful, throw an error.
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

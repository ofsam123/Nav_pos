import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../API.dart';
import '../Models/TotalItemReceivedModel.dart';
import '../Models/itemsSoldModel.dart';
import '../Models/myTransferOrdModel.dart';
import '../apiHelper.dart';

class myTransferOrder extends StatefulWidget {
  myTransferOrder({required this.responsibilityCenter});
  final String responsibilityCenter;

  @override
  State<myTransferOrder> createState() => _totalItemsRevivedState();
}

class _totalItemsRevivedState extends State<myTransferOrder> {
  final Helper helper = Helper();
  late Future<List<tranOrdModel>> _func;
  String? token;
  String? userTypeId;

  DateTime now = DateTime.now();

  // Create a map to store the sum of quantities for each unique Item_No
  Map<String, int> _totalQuantities = {};

  @override
  void initState() {
    _func = _getItems1();
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Transfer Orders",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
                        ),
                      );
                    } else if (data.hasData) {
                      var items = data.data as List<tranOrdModel>;
                      if (items.isEmpty) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("No Item Received Today"),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: _totalQuantities.length,
                        physics: ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2),
                            child: GestureDetector(
                              onTap: () {
                                // Handle item tap
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                width: MediaQuery.of(context).size.width / 1.1,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 10.0, top: 5),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20, top: 05),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 80,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 0),
                                                        child: Text(
                                                          items[0]
                                                              .No
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize: 19,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        "Q",
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      Spacer(),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                right: 8.0),
                                                        child: Text(
                                                          items[0]
                                                              .DescriTransfer_to_Codeption_2
                                                              .toString(),
                                                          style: TextStyle(
                                                            color: Colors.grey,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 140,
                              child: Image.asset("assets/images/loading.gif"),
                            ),
                          ],
                        ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<tranOrdModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = prefs.getString('Sales_Resp_Ctr_Filter') ?? '';
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '${widget.responsibilityCenter.toString()}' and Completely_Shipped eq false"),
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
      String apiResponse = responseJson["value"].toString();
      List responseList = json.decode(response.body)["value"];

      // Calculate the sum of quantities for each unique Item_No

      return responseList.map((job) => tranOrdModel.fromJson(job)).toList();
    } else {
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

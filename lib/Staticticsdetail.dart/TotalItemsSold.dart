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
import '../apiHelper.dart';

class totalItemsSold extends StatefulWidget {
  totalItemsSold({required this.resCenter});

  String? resCenter;
  @override
  State<totalItemsSold> createState() => _totalItemsSoldState();
}

class _totalItemsSoldState extends State<totalItemsSold> {
  final Helper helper = new Helper();

  late Future<List<itemsSoldModel>> _func;

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

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Total Item Sold",
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
                    var items = data.data as List<itemsSoldModel>;
                    if (items.isEmpty) {
                      // Display an alert dialog when the list is empty
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No Items Sold Today"),
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
                              onTap: () {
                                // showDialog<void>(
                                //   context: context,
                                //   // barrierDismissible:
                                //   //     false, // user must tap button!
                                //   builder: (BuildContext context) {
                                //     return AlertDialog(
                                //       // <-- SEE HERE
                                //       title: const Text('Visitation Details'),
                                //       content: SingleChildScrollView(
                                //         child: Column(
                                //           children: const <Widget>[
                                //             Text(""),
                                //           ],
                                //         ),
                                //       ),
                                //       actions: <Widget>[
                                //         TextButton(
                                //           child: const Text('No'),
                                //           onPressed: () {
                                //             Navigator.of(context).pop();
                                //           },
                                //         ),
                                //         TextButton(
                                //           child: const Text('Yes'),
                                //           onPressed: () {
                                //             Navigator.of(context).pop();
                                //           },
                                //         ),
                                //       ],
                                //     );
                                //   },
                                // );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.grey,
                                  //     offset: const Offset(
                                  //       5.0,
                                  //       5.0,
                                  //     ),
                                  //     blurRadius: 100.0,
                                  //     spreadRadius: 2.0,
                                  //   ),
                                  // ],
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
                                              Text(
                                                items[index].No.toString(),
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              Container(
                                                height: 80,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.white),
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
                                                                      .only(
                                                                  left: 0),
                                                          child: Text(
                                                            items[index]
                                                                .Description
                                                                .toString(),
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 0),
                                                          child: Text(
                                                            "GH₵ " +
                                                                items[index]
                                                                    .Amount_Including_VAT
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .green,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                        Spacer(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 8.0),
                                                          child: Text(
                                                            items[index]
                                                                .Posting_Date
                                                                .toString(),
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "(QTY) " +
                                                          items[index]
                                                              .Quantity
                                                              .toString(),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider()
                                      ],
                                    )),
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

  Future<List<itemsSoldModel>> _getItems1() async {
    // helper.checkForInternet(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    // SimpleFontelicoProgressDialog progressDialog =
    //     SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "loading ...",
    // );
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvLineAPI?" +
              "\$filter=Location_Code eq '${widget.resCenter.toString()}' and Posting_Date eq " +
              "${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      //progressDialog.hide();
      // progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
      // helper.alertDialogTitle('${Helper.errorMessageOops}', '${err.toString()}', context);
    });
//
    if (response.statusCode == 200) {
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);
      String apiResponse = responseJson["value"].toString();
      List responseList = json.decode(response.body)["value"];
      // helper.alertDialogNoTitle(response.body, context);
      return responseList.map((job) => itemsSoldModel.fromJson(job)).toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

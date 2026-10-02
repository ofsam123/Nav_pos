import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nav_pos/Staticticsdetail.dart/TransferToRevcioeveDeatilsPage.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import '../API.dart';
import '../Models/transferToReveiveModel.dart';
import '../apiHelper.dart';

class TransferToRecieve extends StatefulWidget {
  TransferToRecieve({super.key, required this.responsCenter});

  String? responsCenter;
  @override
  State<TransferToRecieve> createState() => _TransferToRecieveState();
}

class _TransferToRecieveState extends State<TransferToRecieve> {
  final Helper helper = new Helper();

  late Future<List<TransferToRevieveModel>> _func;

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
          "Transfer To Recieve",
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
                    var items = data.data as List<TransferToRevieveModel>;
                    if (items.isEmpty) {
                      // Display an alert dialog when the list is empty
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("No Items Recieve"),
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
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            transferToReciveDetailsPage(
                                              docsNo:
                                                  items[index].No.toString(),
                                            )));
                              },
                              child: Container(
                                height: 100,
                                child: Card(
                                  color: Colors.white,
                                  // decoration: BoxDecoration(
                                  //   color: Colors.white,

                                  //   borderRadius: BorderRadius.circular(10),
                                  // ),
                                  // width: MediaQuery.of(context).size.width / 1.1,
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, top: 0, left: 5),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 05),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 85,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 10),
                                                            child: Text(
                                                              items[index]
                                                                  .No
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 19,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                          Spacer(),
                                                          Visibility(
                                                            visible: !items[
                                                                    index]
                                                                .POS_Status
                                                                .toString()
                                                                .contains(
                                                                    "Received"),
                                                            child: IconButton(
                                                              onPressed: () {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return AlertDialog(
                                                                      content: Text("Confirm Receipt of Transfer No " +
                                                                          items[index]
                                                                              .No
                                                                              .toString()),
                                                                      actions: [
                                                                        TextButton(
                                                                          child:
                                                                              Text("Cancel"),
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              40,
                                                                          width:
                                                                              120,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.black,
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(20)),
                                                                          ),
                                                                          child:
                                                                              TextButton(
                                                                            style:
                                                                                TextButton.styleFrom(
                                                                              textStyle: const TextStyle(fontSize: 17),
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.of(context).pop();
                                                                              // _postVisitation();
                                                                              _updateHeader(items[index].No.toString());
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              "Submit",
                                                                              style: TextStyle(color: Colors.white, fontSize: 17),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              icon: Icon(Icons
                                                                  .send_rounded),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            "Status:" +
                                                                items[index]
                                                                    .POS_Status
                                                                    .toString(),
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
                                                              items[index]
                                                                  .Posting_Date
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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
                                        ],
                                      )),
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

  Future<List<TransferToRevieveModel>> _getItems1() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '${widget.responsCenter.toString()}' and Completely_Shipped eq true and Shipment_Date eq ${now.year}-${now.month}-${now.day}"),
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
      return responseList
          .map((job) => TransferToRevieveModel.fromJson(job))
          .toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }

  Future<void> _updateHeader(String no) async {
    // if (passwordController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide password", context);
    //   return;
    // }
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Updating ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .patch(Uri.parse(ApiUrl.TransferHeaderAPI + "(No = '$no')"),
            headers: {
              'Content': 'application/x-www-form-urlencoded',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$basicAuth',
              "Access-Control-Allow-Origin": "*",
              "If-Match": "*"
            },
            body: jsonEncode(<String, String>{"POS_Status": "Received"}))
        .catchError((err) {
      progressDialog.hide();
      // helper.alertDialogTitle('${Helper.errorMessageOops}',
      //     '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyNevBar()));
      helper.flushBar2("Success", "Updated", context);
      //IF STC 200 UPDATE THE BUTTON TO RECIEVED BASE ON EACH ITEM IN THE LIST

      progressDialog.hide();

      // helper.flushBar2("Success", "Login Successful", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);
    }
  }
}

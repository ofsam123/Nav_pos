import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/scanQr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'API.dart';
import 'ReturnOrderLogic.dart';
import 'Staticticsdetail.dart/TotalItemRecieved.dart';
import 'Staticticsdetail.dart/TotalItemsSold.dart';
import 'Staticticsdetail.dart/myTransferOrderDetails.dart';
import 'Staticticsdetail.dart/postedSales.dart';
import 'Staticticsdetail.dart/returnOrder.dart';
import 'Staticticsdetail.dart/salesOrderOpen.dart';
import 'Staticticsdetail.dart/transferToRecieve.dart';

class statics extends StatefulWidget {
  const statics({super.key});

  @override
  State<statics> createState() => _staticsState();
}

class _staticsState extends State<statics> {
  final Helper helper = Helper();
  String UserName = "";
  String myTotalItemReceived = "";

  String myReurnOrder = "";
  String myOrderTransfer = "";
  String totalQuantity1 = "";
  String totalAmount1 = "";
  String poi = "";
  String salesoP = "";
  String traffer1 = "";
  String resCenter1 = "";

  String reQty = "";
  String reSold = "";
  String reItemsNo = "";
  String Noss = "";
  // List<String> matchingItemNos = [];
  // List<String> matchingItemNosItemNo = [];
  // List<int> subtractedQuantities = [];
  // List<String> qtyReceivedList = [];
  // List<String> qtySoldList = []; // Added to store Qty_Sold values

  @override
  void initState() {
    _getUserData();
    _getUserData1();
    // _refreshData();
    // _getResponsibiltyCenter();R

    Timer(Duration(seconds: 1), () {
      setState(() {
        _getResponsibiltyCenter();
        // QRecieve();
        // QSold();
        // _totalItemSold();
        // _PostedSalesInvoice();
        // _salesOrderOpen();
        // _transff();
        // _myTransaferOrders();
        // _myReturnOrders();
        // _myTotalItemRevied();
        // _refreshData();
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      // _getResponsibiltyCenter();
      // _getUserData();
      // _getResponsibiltyCenter();
      // QRecieve();
      // QSold();
      // _totalItemSold();
      // _PostedSalesInvoice();
      // _salesOrderOpen();
      // _transff();
      // _myTransaferOrders();
      // _myReturnOrders();
      // _myTotalItemRevied();
      //
      _checkLocationPermission();
      QRecieve();
      QSold();
      _totalItemSold();
      _PostedSalesInvoice();
      _salesOrderOpen();
      _transff();
      _myTransaferOrders();
      _myReturnOrders();
      _myTotalItemRevied();
    });
  }

  String userResCenter = "";
  String Location_Code1 = '';

  TextEditingController _controller = TextEditingController();
  TextEditingController _Amountcontroller = TextEditingController();
  var totalQuantityController = TextEditingController();
  var totalAmountController = TextEditingController();
  _getUserData() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    userResCenter = (prefs2.getString('Sales_Resp_Ctr_Filter') ?? '');

    // UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  _getUserData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  DateTime now = DateTime.now();
  int totalQuantityReceived = 0;
  int totalQuantitySold = 0;
  int difference = 0;

  //QTYRECIEVE
  Future<void> QRecieve() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq '$resCenter1' and Receipt_Date eq ${now.year}-${now.month}-${now.day}"),
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
              "\$filter=Location eq '$resCenter1' and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
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

  Widget _buildItemsLeftToday() {
    final itemsLeft = difference < 0 ? 0 : difference;
    final hasItemsLeft = itemsLeft > 0;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            itemsLeft.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: hasItemsLeft ? Colors.green[700] : Colors.red,
            ),
          ),
          SizedBox(width: 6),
          Text(
            hasItemsLeft ? "ITEMS LEFT\nTODAY" : "NO ITEMS\nLEFT TODAY",
            style: TextStyle(
              fontSize: 10,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denies location access.
        // You can show a dialog or message asking the user to enable location access in settings.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 250, 255, 1),
      appBar: AppBar(
        title: Text(
          UserName.toString(),
          // resCenter1.toString(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [_buildItemsLeftToday()],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          // color: Color.fromRGBO(243, 241, 241, 0.976),
          // color: Color.RGB 230, 230, 230,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "For Release",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PostedSales(
                                        responsibilityCenter:
                                            resCenter1.toString(),
                                      )));
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 2.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                spreadRadius: 2,
                                color: Color.fromARGB(66, 201, 201, 201),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      poi,
                                      style: TextStyle(
                                          fontSize: 39,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Text(
                                "Posted Sales Invoice",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => salesOrder(
                                        resCenter: resCenter1.toString(),
                                      )));
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 2.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                spreadRadius: 2,
                                color: Color.fromARGB(66, 201, 201, 201),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      salesoP,
                                      style: TextStyle(
                                          fontSize: 39,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Text(
                                "Sales Orders-Open",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 45,
                  ),
                  Container(
                    height: 10,
                    color: Colors.blue,
                  ),
                  Text(
                    "My Day Totals",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => totalItemsSold(
                                        resCenter: resCenter1.toString(),
                                      )));
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 2.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                spreadRadius: 2,
                                color: Color.fromARGB(66, 201, 201, 201),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      totalQuantity1,
                                      // "0",
                                      style: TextStyle(
                                          fontSize: 39,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Text(
                                "Total Item Sold",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => totalItemsRevived(
                                        responsibilityCenter:
                                            resCenter1.toString(),
                                      )));
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 2.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                spreadRadius: 2,
                                color: Color.fromARGB(66, 201, 201, 201),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      myTotalItemReceived,
                                      style: TextStyle(
                                          fontSize: 39,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Text(
                                "Total item Received",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => totalItemsSold(
                                    resCenter: resCenter1.toString(),
                                  )));
                    },
                    child: Container(
                      height: 130,
                      width: MediaQuery.of(context).size.width / 2.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0),
                            blurRadius: 2,
                            spreadRadius: 2,
                            color: Color.fromARGB(66, 201, 201, 201),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Spacer(),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.file_copy,
                                color: Colors.blue,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Container(
                                  height: 50,
                                  width: 110,
                                  child: Text(
                                    totalAmount1,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        fontSize: 39,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            ],
                          ),
                          Spacer(),
                          Text(
                            "Total Amount Sold",
                            style: TextStyle(fontSize: 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 10,
                    color: Colors.blue,
                  ),
                  Text("Transfer Activities",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      // GestureDetector(
                      //   onTap: () {
                      //     // Navigator.push(
                      //     //     context, (context) => myTransferOrder());
                      //     Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //             builder: (context) => myTransferOrder(
                      //                   responsibilityCenter:
                      //                       resCenter1.toString(),
                      //                 )));
                      //   },
                      //   child: Container(
                      //     height: 130,
                      //     width: MediaQuery.of(context).size.width / 2.3,
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(15),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           offset: Offset(0, 0),
                      //           blurRadius: 2,
                      //           spreadRadius: 2,
                      //           color: Color.fromARGB(66, 201, 201, 201),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.center,
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: [
                      //         Spacer(),
                      //         Row(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Icon(
                      //               Icons.file_copy,
                      //               color: Colors.blue,
                      //             ),
                      //             Padding(
                      //               padding: const EdgeInsets.only(right: 20),
                      //               child: Text(
                      //                 myOrderTransfer,
                      //                 style: TextStyle(
                      //                     fontSize: 39,
                      //                     fontWeight: FontWeight.bold),
                      //               ),
                      //             )
                      //           ],
                      //         ),
                      //         Spacer(),
                      //         Text(
                      //           "My Transfer Orders",
                      //           style: TextStyle(fontSize: 16),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TransferToRecieve(
                                        responsCenter: resCenter1.toString(),
                                      )));
                        },
                        child: Container(
                          height: 130,
                          width: MediaQuery.of(context).size.width / 2.3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 0),
                                blurRadius: 2,
                                spreadRadius: 2,
                                color: Color.fromARGB(66, 201, 201, 201),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Spacer(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.file_copy,
                                    color: Colors.blue,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      traffer1,
                                      style: TextStyle(
                                          fontSize: 39,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                              Spacer(),
                              Text(
                                "Transfer To Receive",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => returnOrder()));
                        },
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ReturnOrderLogic(
                                          rc: resCenter1.toString(),
                                        )));
                          },
                          child: Container(
                            height: 130,
                            width: MediaQuery.of(context).size.width / 2.3,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 0),
                                  blurRadius: 2,
                                  spreadRadius: 2,
                                  color: Color.fromARGB(66, 201, 201, 201),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Spacer(),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.file_copy,
                                      color: Colors.blue,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        difference.toString(),
                                        style: TextStyle(
                                            fontSize: 39,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  "Return Transafers",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getResponsibiltyCenter() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ResponsibilityCenterAPI?" +
              "\$filter=User_ID eq '$UserName" +
              "'"),
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
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      progressDialog.hide();
      String User_ID_2 = responseJson["value"][0]["User_ID"].toString();

      String userResCenter =
          responseJson["value"][0]["Sales_Resp_Ctr_Filter"].toString();
      String Code = responseJson["value"][0]["Code"].toString();
      String Location_Code =
          responseJson["value"][0]["Location_Code"].toString();

      // progressDialog.hide();
      SharedPreferences prefs2 = await SharedPreferences.getInstance();
      // prefs.setString('User_ID_2', User_ID_2);
      prefs2.setString('userResCenter', userResCenter);
      prefs2.setString('Code', Code);
      prefs2.setString('Location_Code', Location_Code);
      // helper.flushBar2('Success', userResCenter, context);

      setState(() {
        resCenter1 = userResCenter.toString();
        _refreshData();
        Location_Code1 = Location_Code.toString();
      });
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> _totalItemSold() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvLineAPI?" +
              "\$filter=Location_Code eq " +
              "\'" +
              "$resCenter1" +
              "\'" +
              " and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
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

      // List to store all quantities
      List<int> quantities = [];
      List<double> Amount = [];

      // Loop through the items and accumulate quantities
      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Quantity"].toString()) ?? 0;
        quantities.add(quantity);
      }
      for (var item in responseJson["value"]) {
        double Amounts =
            double.tryParse(item["Amount_Including_VAT"].toString()) ?? 0;
        Amount.add(Amounts);
      }

      // Calculate the total quantity
      int totalQuantity = quantities.fold(0, (sum, quantity) => sum + quantity);
      double totalAmount = Amount.fold(0.0, (sum, Amounts) => sum + Amounts);
      // helper.alertDialogNoTitle(
      //     "Total Quantity: $totalQuantity" + " \n" + "$totalAmount", context);
      setState(() {
        totalAmount1 = totalAmount.toString();
        totalQuantity1 = totalQuantity.toString();
        // _Amountcontroller = totalAmount as TextEditingController;
        // _controller = totalQuantityController;
      });

      // progressDialog.hide();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('Quantity', totalQuantity);
      prefs.setInt('Amount_Including_VAT', totalAmount as int);
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> _PostedSalesInvoice() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvHeaderAPI?" +
              "\$filter=Responsibility_Center eq " +
              "\'" +
              "$resCenter1" +
              "\'" +
              " and Posting_Date eq " +
              "${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        poi = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _salesOrderOpen() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/OSalesHeaderAPI?" +
              "\$filter=Responsibility_Center eq '$resCenter1' and Document_Type eq 'Order' and Status eq 'Open' and Document_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        salesoP = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _transff() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '$resCenter1' and Completely_Shipped eq true and Shipment_Date eq ${now.year}-${now.month}-${now.day} and POS_Status eq 'Open'"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        traffer1 = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myTransaferOrders() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '$resCenter1' and Completely_Shipped eq false"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        myOrderTransfer = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myReturnOrders() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_from_Code eq '$resCenter1' and Completely_Shipped eq false"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        myReurnOrder = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myTotalItemRevied() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ItemLedgerEntryAPI?" +
              "\$filter=Location_Code eq '$resCenter1' and Posting_Date eq ${now.year}-${now.month}-${now.day} and Quantity gt 0 and Entry_Type eq 'Transfer'"),
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

      // List to store all quantities
      List<int> quantities = [];
      List<double> Amount = [];

      // Loop through the items and accumulate quantities
      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Quantity"].toString()) ?? 0;
        quantities.add(quantity);
      }

      // Calculate the total quantity
      int totalQuantity = quantities.fold(0, (sum, quantity) => sum + quantity);

      // helper.alertDialogNoTitle(
      //     "Total Quantity: $totalQuantity" + " \n" + "$totalAmount", context);
      setState(() {
        myTotalItemReceived = totalQuantity.toString();
        // _Amountcontroller = totalAmount as TextEditingController;
        // _controller = totalQuantityController;
      });

      // progressDialog.hide();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('Quantity', totalQuantity);
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
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
}

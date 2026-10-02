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
import '../apiHelper.dart';

class SalesOrderDetails extends StatefulWidget {
  SalesOrderDetails({required this.docsNo});

  String? docsNo;

  @override
  State<SalesOrderDetails> createState() => _SalesOrderDetailsState();
}

class _SalesOrderDetailsState extends State<SalesOrderDetails> {
  final Helper helper = new Helper();

  late Future<List<postedSaledDetailsModel>> _func;

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
          "Sales Order",
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
                    var items = data.data as List<postedSaledDetailsModel>;
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
                                        "Description: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].Description.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.numbers_outlined),
                                      title: Text(
                                        "Quantity: ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index].Quantity.toString(),
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      // trailing: Icon(Icons.arrow_forward_ios),
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.money),
                                      title: Text(
                                        "Amount Including VAT : ",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        items[index]
                                            .Amount_Including_VAT
                                            .toString(),
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

  Future<List<postedSaledDetailsModel>> _getItems1() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/OSalesLineAPI?" +
              "\$filter=Document_No eq '${widget.docsNo.toString()}'"),
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
          .map((job) => postedSaledDetailsModel.fromJson(job))
          .toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

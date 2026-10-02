import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'API.dart';
import 'customerProfile.dart';
import 'customerShops.dart';

class ScanQr extends StatefulWidget {
  const ScanQr({super.key});

  // ScanQr({required this.responsibilityC});

  // String? responsibilityC;

  @override
  State<ScanQr> createState() => _ScanQrState();
}

class _ScanQrState extends State<ScanQr> {
  String userResCenter = "";
  String Location_Code = "";

  String UserName = "";
  String resCenter1 = "";

  @override
  void initState() {
    _getUserData();
    Timer(Duration(seconds: 1), () {
      setState(() {
        _getResponsibiltyCenter();
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  final Helper helper = new Helper();
  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  bool _isShow = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (context, constraint) {
      return Container(
        decoration: BoxDecoration(
            // color: Color.fromRGBO(14, 45, 90, 1),
            image: DecorationImage(
                image: AssetImage("assets/images/loginbg3.jpg"),
                fit: BoxFit.cover)),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraint.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 120,
                      width: MediaQuery.of(context).size.width / 1.0,

                      // width: 370,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color.fromARGB(255, 198, 199, 199)
                          // color: Color.fromRGBO(14, 54, 90, 1),
                          // image: DecorationImage(
                          //   image:
                          //   // image: AssetImage("assets/images/bbn.jpg"),
                          //   // fit: BoxFit.cover,
                          // ),
                          ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "Scan QR Code",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 19,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "Scan Qr Code of the Customer to get More Info Or Click on Available Customers to see all Customers assigned. $resCenter1"),
                          ),
                        ],
                      )),
                    ),
                    Visibility(
                      visible: _isShow,
                      child: GestureDetector(
                          onTap: () {
                            scanBarcodeNormal();
                          },
                          child:
                              Image(image: AssetImage("assets/images/qr.PNG"))),
                    ),
                    Text("CLICK TO SCAN"),
                    Spacer(),
                    Visibility(
                      visible: _isShow,
                      child: Container(
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          // boxShadow: [
                          //   BoxShadow(
                          //     color: const Color.fromARGB(255, 58, 183, 125),
                          //     spreadRadius: 10,
                          //     blurRadius: 20,
                          //   ),
                          // ],
                        ),
                        child: ElevatedButton(
                          child: Container(
                              width: double.infinity,
                              height: 50,
                              child: Center(
                                  child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.store_outlined),
                                  Spacer(),
                                  Text("Available Customers"),
                                  Spacer(),
                                  Icon(Icons.arrow_forward_ios)
                                ],
                              ))),
                          onPressed: () {
                            // _loginFunc();

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => customerShopsPage(
                                          Id: '',
                                          responsC: resCenter1.toString(),
                                        )));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }));
  }

  Future scanBarcodeNormal() async {
    String barcodeScanRes;

    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancel", true, ScanMode.QR);
    print(barcodeScanRes);

    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => customerShopsPage(
                    Id: barcodeScanRes.toString(),
                    responsC: resCenter1.toString(),
                  )));
      // _scanBarcode = barcodeScanRes;
    });
  }

  Future<void> _getResponsibiltyCenter() async {
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading Data please wait ...",
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
      // helper.alertDialogNoTitle(Location_Code, context);

      setState(() {
        resCenter1 = userResCenter.toString();
        _isShow = true;
        // _refreshData();
      });
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }
}

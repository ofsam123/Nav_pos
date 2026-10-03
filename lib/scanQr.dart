import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'API.dart';
import 'customerProfile.dart';
import 'customerShops.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

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
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const Text(
              "Scan",
              style: TextStyle(
                fontSize: 36,
                height: 1.15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Scan a customer's QR code to open their profile, or browse all customers assigned to you.",
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 26),
            AppCard(
              onTap: _isShow ? () => scanBarcodeNormal() : null,
              padding: const EdgeInsets.fromLTRB(20, 34, 20, 30),
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: _isShow
                        ? const Icon(Icons.qr_code_scanner_rounded,
                            size: 84, color: AppColors.primary)
                        : const Center(
                            child: SizedBox(
                              width: 34,
                              height: 34,
                              child: AppLoader(strokeWidth: 3),
                            ),
                          ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    _isShow ? "Tap to scan" : "Loading your data…",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Point the camera at the customer's QR code",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                  if (displayValue(resCenter1, fallback: '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    StatusPill(
                      text: "Responsibility center: $resCenter1",
                      color: AppColors.primary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Visibility(
              visible: _isShow,
              child: SizedBox(
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => customerShopsPage(
                                  Id: '',
                                  responsC: resCenter1.toString(),
                                )));
                  },
                  icon: const Icon(Icons.storefront_outlined),
                  label: const Text("Available Customers"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading your data ...",
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

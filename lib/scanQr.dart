import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/widgets/qr_scanner_page.dart';
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
      if (!mounted) return;
      _getResponsibiltyCenter();
    });
    super.initState();
  }

  final Helper helper = new Helper();
  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      if (mounted) setState(() {});
    });
  }

  bool _isShow = false;
  String? _loadError;

  void _retry() {
    setState(() => _loadError = null);
    _getResponsibiltyCenter();
  }
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
                        : _loadError != null
                            ? const Icon(Icons.cloud_off_rounded,
                                size: 72, color: AppColors.danger)
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
                    _isShow
                        ? "Tap to scan"
                        : _loadError != null
                            ? "Couldn't load your data"
                            : "Loading your data…",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _loadError ?? "Point the camera at the customer's QR code",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 15),
                  ),
                  if (_loadError != null) ...[
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: _retry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text("Try again"),
                    ),
                  ],
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

  static const _cameraChannel = MethodChannel('nav_pos/camera_permission');

  Future<bool> _ensureCameraPermission() async {
    if (kIsWeb) {
      helper.flushBar2(
          "Warning", "QR scanning is only available in the phone app", context);
      return false;
    }

    String status;
    try {
      status = await _cameraChannel.invokeMethod<String>('request') ?? 'denied';
    } on MissingPluginException {
      // No native handler on this platform: the scanner asks for itself.
      return true;
    } on PlatformException {
      return false;
    }
    if (!mounted) return false;

    if (status == 'granted') return true;
    if (status == 'permanentlyDenied') {
      await _showCameraSettingsDialog();
    } else {
      helper.flushBar2(
          "Warning", "Allow camera access to scan customer QR codes", context);
    }
    return false;
  }

  Future<void> _showCameraSettingsDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.no_photography_outlined,
            color: AppColors.warning, size: 36),
        title: const Text("Camera access is off"),
        content: const Text(
          "To scan customer QR codes, allow camera access for Nav POS in your phone's settings.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Not now"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _cameraChannel.invokeMethod('openSettings');
            },
            child: const Text("Open settings"),
          ),
        ],
      ),
    );
  }

  Future scanBarcodeNormal() async {
    if (!await _ensureCameraPermission()) return;

    final barcodeScanRes = await Navigator.push<String>(
        context, MaterialPageRoute(builder: (_) => const QrScannerPage()));
    print(barcodeScanRes);

    if (!mounted || barcodeScanRes == null || barcodeScanRes.trim().isEmpty) {
      return;
    }

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
    http.Response response;
    dynamic responseJson;
    try {
      response = await http.get(
        Uri.parse(
            "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/ResponsibilityCenterAPI?" +
                "\$filter=User_ID eq '$UserName" +
                "'"),
        headers: {
          'Content': 'application/x-www-form-urlencoded',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$basicAuth',
          "Access-Control-Allow-Origin": "*",
        },
      );
      responseJson = jsonDecode(response.body);
    } catch (err) {
      progressDialog.hide();
      if (!mounted) return;
      setState(() => _loadError =
          "Check your internet connection and try again.");
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
      return;
    }

    progressDialog.hide();
    if (!mounted) return;

    final rows = response.statusCode == 200 && responseJson is Map
        ? responseJson["value"]
        : null;
    if (rows is List && rows.isEmpty) {
      setState(() => _loadError =
          "No responsibility center is set up for $UserName.");
      return;
    }

    if (response.statusCode == 200 && rows is List) {
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

      if (!mounted) return;
      setState(() {
        resCenter1 = userResCenter.toString();
        _isShow = true;
        // _refreshData();
      });
    } else {
      // progressDialog.hide();
      setState(() => _loadError =
          "The server returned an error (${response.statusCode}).");
      helper.flushBar2("Error", 'Try again', context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }
}

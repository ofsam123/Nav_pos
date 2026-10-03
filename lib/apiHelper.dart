import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:nav_pos/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:http/http.dart' as http;

import 'theme/app_theme.dart';

class Helper {
  static const String customerCareNumber = "+233501622411";
  static const String whatsAppNumber = "+233501647773";
  static const String platform = "Android";
  static const String errorMessageOops = "Oops!! 😔";
  static const String applicationCurrentVersion = "1.0";
  static const String noData = "No data available";
  static const String errorMessageSomethingWentWrong =
      "Oops!! 😔 \nSomething went wrong !";
  static const String noInternet = "No internet connection available";
  static const String hashedSignature = "A8snHZvWIC1";
  static const String adminId = "Admin";
  static const String setupId = "SID3290830";
  static const String androidApiKey = "AIzaSyDGxLc4bqq_eCCHiE2VPORtVHLs8yBZl4g";
  static const String iosApiKey = "AIzaSyDGxLc4bqq_eCCHiE2VPORtVHLs8yBZl4g";

  void toastSuccessNotification(
    String msg,
  ) {
    Fluttertoast.showToast(
        msg: '${msg}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void toastFailedNotification(
    String msg,
  ) {
    Fluttertoast.showToast(
        msg: '${msg}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future<void> sendMessage(String phoneNumber, String msg) async {
    final response = await http.get(
      Uri.parse(
          "https://smsc.hubtel.com/v1/messages/send?clientsecret=umegayxu&clientid=uqslgtsx&from=Synergy&to=" +
              phoneNumber +
              "&content=" +
              msg),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
      },
    );
  }

  void snackBarNotification(String msg, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // void checkForInternet(BuildContext context) async {
  //   final ConnectivityResult result = await Connectivity().checkConnectivity();
  //   if (result != ConnectivityResult.wifi &&
  //       result != ConnectivityResult.mobile) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text("No internet connection 🛜")));
  //     return;
  //   }
  // }

  void alertDialogTitle(String title, String msg, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(msg),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void alertDialogNoTitle(String msg, BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text(msg),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  void flushBar2(String title, String msg, BuildContext context) {
    switch (title) {
      case "Success":
        _styledFlushbar(title, msg, AppColors.success,
                Icons.check_circle_rounded)
            .show(context);
        break;

      case "Error":
        _styledFlushbar(title, msg, AppColors.danger, Icons.error_rounded)
            .show(context);
        break;

      case "Warning":
        _styledFlushbar("Oops", msg, const Color(0xFF475569),
                Icons.info_rounded)
            .show(context);
        break;
    }
  }

  Flushbar _styledFlushbar(
      String title, String msg, Color color, IconData icon) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      flushbarStyle: FlushbarStyle.FLOATING,
      margin: EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(14),
      backgroundColor: color,
      duration: Duration(seconds: 3),
      icon: Icon(icon, color: Colors.white, size: 26),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
      titleText: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.w600, fontSize: 15.0, color: Colors.white),
      ),
      messageText: Text(
        msg,
        style: TextStyle(fontSize: 14.0, color: Colors.white),
      ),
    );
  }

  void flushBar1(String title, String msg, BuildContext context) {
    switch (title) {
      case "Success":
        {
          showTopSnackBar(
            context as OverlayState,
            CustomSnackBar.success(
              message: msg,
            ),
          );
        }
        break;

      case "Error":
        {
          showTopSnackBar(
            context as OverlayState,
            CustomSnackBar.error(
              message: msg,
            ),
          );
        }
        break;

      case "Warning":
        {
          showTopSnackBar(
            context as OverlayState,
            CustomSnackBar.info(
              message: msg,
            ),
          );
        }
        break;
    }
  }

  logoutFunc(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('User_Name');
    prefs.remove('CanUse_POS');
    prefs.remove('isUserLoggedIn');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => loginPage()),
      (Route<dynamic> route) => false,
    );
  }
}

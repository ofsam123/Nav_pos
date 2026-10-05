import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/API.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';

import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({required this.User_Security_ID});

  String? User_Security_ID;

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool obscureTextNewPassword = true;
  bool obscureTextConfirmPassword = true;
  final Helper helper = new Helper();
  // String User_Security_ID = "";

  // _getUserData1() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   //userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

  //   // User_Security_ID = (prefs.getString('User_Security_ID') ?? '');

  //   Timer(Duration(seconds: 0), () {
  //     setState(() {});
  //   });
  // }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.password,
                  size: 34, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Create a new password",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Enter and confirm your new password below.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          const SmallCapsLabel("Security"),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(widget.User_Security_ID.toString()),
                _fieldLabel("New Password"),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureTextNewPassword,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureTextNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureTextNewPassword = !obscureTextNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel("Confirm Password"),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureTextConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(obscureTextConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          obscureTextConfirmPassword =
                              !obscureTextConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _resetP();
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetP() async {
    if (newPasswordController.text.toString().isEmpty) {
      return helper.alertDialogNoTitle("new Password is Empty", context);
    }
    if (confirmPasswordController.text.toString().isEmpty) {
      return helper.alertDialogNoTitle("Confirm Password is Empty", context);
    }
    if (newPasswordController.text.toString() ==
        confirmPasswordController.text.toString()) {
      // Passwords match, you can proceed with your action here
      // For example, you can navigate to the next page or perform an action.
    } else {
      return helper.alertDialogNoTitle(
          'Confirmed Password not matching new password', context);
      // Passwords do not match, display an error message or take appropriate action.
      // You might want to show a snackbar or alert dialog to inform the user.
    }
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Resetting password ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .patch(
            Uri.parse(
                "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/UserAPI(User_Security_ID = ${widget.User_Security_ID})"),
            headers: {
              'Content': 'application/x-www-form-urlencoded',
              'Content-Type': 'application/json',
              "If-Match": "*",
              'Accept': 'application/json',
              'Authorization': '$basicAuth',
              "Access-Control-Allow-Origin": "*",
            },
            body: jsonEncode(<String, dynamic>{
              "Password_POS": confirmPasswordController.text.toString(),
              "Change_Password_POS": false
            }))
        .catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      progressDialog.hide();

      // Navigator.pop(context);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => loginPage()));

      helper.flushBar2("Success", " Successful Reset", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);
      // helper.flushBar2("Error", "Something went wrong", context);

      // helper.alertDialogNoTitle("Insert Image", context);
    }
  }
}

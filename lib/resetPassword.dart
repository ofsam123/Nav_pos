import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/API.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/loginPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 50,
                ),
                Icon(Icons.password, size: 55),
                SizedBox(height: 20),
                SizedBox(
                  height: 50,
                ),
                // Text(widget.User_Security_ID.toString()),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureTextNewPassword,
                  decoration: InputDecoration(
                    hintText: 'New Password',
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.only(left: 30),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                SizedBox(height: 20),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureTextConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Confirm Password',
                    filled: true,
                    fillColor: Colors.blueGrey[50],
                    labelStyle: TextStyle(fontSize: 12),
                    contentPadding: EdgeInsets.only(left: 30),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey),
                      borderRadius: BorderRadius.circular(15),
                    ),
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
                SizedBox(height: 50),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: ElevatedButton(
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      child: Center(child: Text("Submit")),
                    ),
                    onPressed: () {
                      _resetP();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "reseting ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .patch(
            Uri.parse(
                "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/UserAPI(User_Security_ID = ${widget.User_Security_ID})"),
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

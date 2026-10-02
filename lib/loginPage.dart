import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
// import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:nav_pos/resetPassword.dart';
import 'package:nav_pos/verifyUserNamePassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'API.dart';
import 'apiHelper.dart';
import 'otpPage.dart';

class loginPage extends StatefulWidget {
  const loginPage({super.key});

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  // final Helper helper = new Helper();
  var userController = TextEditingController();
  var passwordController = TextEditingController();
  // final Helper helper = new Helper();

  bool obscureTextConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    // return const Placeholder();

    return Scaffold(
      backgroundColor: Color(0xFFf5f5f5),
      body: ListView(
        padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width / 8),
        children: [
          Menu(),
          // MediaQuery.of(context).size.width >= 980
          //     ? Menu()
          //     : SizedBox(), // Responsive
          Body()
        ],
      ),
    );
  }
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // _menuItem(title: 'Home'),
              // _menuItem(title: 'About us'),
              // _menuItem(title: 'Contact us'),
              // _menuItem(title: 'Help'),
            ],
          ),
          Row(
            children: [
              _menuItem(title: 'Sign In', isActive: true),
              _registerButton()
            ],
          ),
        ],
      ),
    );
  }

  Widget _menuItem({String title = 'Title Menu', isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 75),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Column(
          children: [
            Text(
              '$title',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.deepPurple : Colors.grey,
              ),
            ),
            SizedBox(
              height: 6,
            ),
            isActive
                ? Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(30),
                    ),
                  )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 209, 207, 207),
            spreadRadius: 10,
            blurRadius: 12,
          ),
        ],
      ),
      child: Text(
        'About Nav POS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  bool CanUse_POS = true;
  final Helper helper = new Helper();
  var userController = TextEditingController();
  var passwordController = TextEditingController();

  bool obscureTextConfirmPassword = true;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
          ),
          Container(height: 200, child: Image.asset("assets/images/poss.png")),
          TextField(
            controller: userController,
            decoration: InputDecoration(
              hintText: 'User Name',
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
            ),
          ),
          SizedBox(height: 30),
          TextField(
            controller: passwordController,
            obscureText: obscureTextConfirmPassword,
            decoration: InputDecoration(
              hintText: ' Password',
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
                    obscureTextConfirmPassword = !obscureTextConfirmPassword;
                  });
                },
              ),
            ),
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Spacer(),
              // TextButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => verifyUserName()));
              //     },
              //     child: Text(
              //       'Set Password',
              //       style: TextStyle(
              //           fontWeight: FontWeight.bold, color: Colors.black),
              //     ))
            ],
          ),
          SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ElevatedButton(
              child: Container(
                  width: double.infinity,
                  height: 50,
                  child: Center(child: Text("Sign In"))),
              onPressed: () {
                // _loginFunc();
                _getSalesHeader();
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => OTP_Page()));
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
          SizedBox(height: 40),
          Row(children: [
            Expanded(
              child: Divider(
                color: Colors.grey[300],
                height: 50,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text("Terms and Conditions"),
            ),
            Expanded(
              child: Divider(
                color: Colors.grey[400],
                height: 50,
              ),
            ),
          ]),
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // _loginWithButton(image: 'images/google.png'),
              // _loginWithButton(image: 'images/github.png', isActive: true),
              // _loginWithButton(image: 'images/facebook.png'),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Powered By Synergy Center",
            style: TextStyle(color: Color.fromARGB(255, 214, 211, 211)),
          ),
        ],
      ),
    );
  }

  Future<void> _getSalesHeader() async {
    if (userController.text.toString().isEmpty) {
      helper.snackBarNotification("Please provide user Name", context);
      return;
    }

    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Login ...",
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/UserAPI?" +
              "\$" +
              "filter=User_Name eq " +
              "'" +
              userController.text.toString() +
              "'"),
      headers: {
        'Content': 'appliation/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      progressDialog.hide();
      // Handle error here if needed.
    });

    progressDialog.hide();

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      String CanUse_POS = responseJson["value"][0]["CanUse_POS"].toString();
      String User_Name = responseJson["value"][0]["User_Name"].toString();
      String ValueE = responseJson["value"][0][""].toString();

      String Change_Password_POS =
          responseJson["value"][0]["Change_Password_POS"].toString();

      String Password_POS = responseJson["value"][0]["Password_POS"].toString();

      String User_Security_ID =
          responseJson["value"][0]["User_Security_ID"].toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('User_Name', User_Name);

      if (CanUse_POS == "true" &&
          Change_Password_POS == "false" &&
          passwordController.text.toString() == Password_POS) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MyNevBar()),
          (Route<dynamic> route) => false,
        );
      }
      if (passwordController.text.toString() != Password_POS) {
        helper.flushBar2("Error", "Password Not Match", context);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => ResetPassword()));
      }
      if (passwordController.text.toString() != Password_POS &&
          Change_Password_POS == "true") {
        helper.flushBar2("Error", "Password Not Match", context);
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => ResetPassword()));
      } else if (CanUse_POS == "true" && Change_Password_POS == "true") {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ResetPassword(
                      User_Security_ID: User_Security_ID,
                    )));
        helper.flushBar2("Error", "Login Failed,Reset Password", context);
      } else if (CanUse_POS == "false") {
        helper.flushBar2(
            "Error", "User not Authenticated to use this POS", context);
      } else if (ValueE.isEmpty) {
        helper.flushBar2("Error", "Please check credentials", context);
      }
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", "Try again", context);
    }
  }
}
//CHECK IF THE passwordController == THE Password_POS
// and the Change_Password_POS == true  Alert the use to reset his password
//else if THE PASSWORDcONTROLLER == THE Password_POS
//and the Change_Password_POS == false Login  
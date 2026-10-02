// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:nav_pos/API.dart';
// import 'package:nav_pos/apiHelper.dart';
// import 'package:nav_pos/resetPassword.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

// class verifyUserName extends StatefulWidget {
//   const verifyUserName({Key? key}) : super(key: key);

//   @override
//   _verifyUserNameState createState() => _verifyUserNameState();
// }

// class _verifyUserNameState extends State<verifyUserName> {
//   TextEditingController newuseNameController = TextEditingController();
//   // TextEditingController confirmPasswordController = TextEditingController();
//   bool obscureTextNewPassword = true;
//   bool obscureTextConfirmPassword = true;
//   final Helper helper = new Helper();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Verify UserName'),
//         centerTitle: true,
//       ),
//       body: Container(
//         child: Padding(
//           padding: const EdgeInsets.all(30.0),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 50,
//                 ),
//                 Icon(Icons.password, size: 55),
//                 SizedBox(height: 20),
//                 SizedBox(
//                   height: 50,
//                 ),
//                 TextField(
//                   controller: newuseNameController,
//                   // obscureText: obscureTextNewPassword,
//                   decoration: InputDecoration(
//                     hintText: 'User Name',
//                     filled: true,
//                     fillColor: Colors.blueGrey[50],
//                     labelStyle: TextStyle(fontSize: 12),
//                     contentPadding: EdgeInsets.only(left: 30),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.blueGrey),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(color: Colors.blueGrey),
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 SizedBox(height: 50),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                   child: ElevatedButton(
//                     child: Container(
//                       width: double.infinity,
//                       height: 50,
//                       child: Center(child: Text("Verify")),
//                     ),
//                     onPressed: () {
//                       _verifyUserNameB();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       primary: Colors.blue,
//                       onPrimary: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _verifyUserNameB() async {
//     if (newuseNameController.text.toString().isEmpty) {
//       helper.snackBarNotification("Please provide user Name", context);
//       return;
//     }

//     SimpleFontelicoProgressDialog progressDialog =
//         SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
//     progressDialog.show(
//       message: "Login ...",
//     );

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String auth = (prefs.getString('auth') ?? '');
//     String basicAuth = 'Basic ' +
//         base64Encode(
//             utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

//     final response = await http.get(
//       Uri.parse(
//           "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/UserAPI?" +
//               "\$" +
//               "filter=User_Name eq " +
//               "'" +
//               newuseNameController.text.toString() +
//               "'"),
//       headers: {
//         'Content': 'appliation/x-www-form-urlencoded',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': '$basicAuth',
//         "Access-Control-Allow-Origin": "*",
//       },
//     ).catchError((err) {
//       progressDialog.hide();
//       // Handle error here if needed.
//     });

//     progressDialog.hide();

//     final responseJson = jsonDecode(response.body);

//     if (response.statusCode == 200) {
//       String CanUse_POS = responseJson["value"][0]["CanUse_POS"].toString();
//       String User_Name = responseJson["value"][0]["User_Name"].toString();
//       String ValueE = responseJson["value"][0][""].toString();

//       String User_Security_ID =
//           responseJson["value"][0]["User_Security_ID"].toString();

//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       prefs.setString('User_Security_ID', User_Security_ID);

//       if (CanUse_POS == "true") {
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => ResetPassword()),
//           (Route<dynamic> route) => false,
//         );
//       } else if (CanUse_POS == "false") {
//         helper.flushBar2(
//             "Error", "User not Authenticated to use this POS", context);
//       } else if (ValueE.isEmpty) {
//         helper.flushBar2("Error", "Please check credentials", context);
//       }
//     } else {
//       progressDialog.hide();
//       helper.flushBar2("Error", "Try again", context);
//     }
//   }
// }

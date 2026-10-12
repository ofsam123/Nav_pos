import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
// import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:nav_pos/resetPassword.dart';
import 'package:nav_pos/verifyUserNamePassword.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';

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
      backgroundColor: Colors.white,
      body: Body(),
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

  static const _headerTop = Color(0xFF0A2C7E);
  static const _headerBottom = Color(0xFF1D5ED6);
  static const _buttonBlue = Color(0xFF0B3FA8);
  static const _titleNavy = Color(0xFF0F1D4A);
  static const _fieldFill = Color(0xFFF3F5F9);
  static const _fieldBorder = Color(0xFFE2E6EE);
  static const _hintGrey = Color(0xFF6B7280);

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _fieldBorder),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintGrey, fontSize: 16),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 20),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 18, right: 12),
        child: Icon(icon, color: _hintGrey, size: 26),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 56),
      suffixIcon: suffix,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: _buttonBlue, width: 1.5),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 44),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.point_of_sale_rounded,
                size: 76,
                color: Color(0xFF0B2A6F),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              "Nav POS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 46,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 30, height: 1.5, color: Colors.white70),
                const SizedBox(width: 12),
                const Text(
                  "Sales & Distribution",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(width: 12),
                Container(width: 30, height: 1.5, color: Colors.white70),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Welcome back",
          style: TextStyle(
            color: _titleNavy,
            fontSize: 34,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Sign in with your company account",
          style: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
        ),
        const SizedBox(height: 30),
        TextField(
          controller: userController,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 16),
          decoration: _fieldDecoration(
            hint: 'Username',
            icon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: passwordController,
          obscureText: obscureTextConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _getSalesHeader(),
          style: const TextStyle(fontSize: 16),
          decoration: _fieldDecoration(
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: Icon(
                  obscureTextConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _hintGrey,
                  size: 26,
                ),
                onPressed: () {
                  setState(() {
                    obscureTextConfirmPassword = !obscureTextConfirmPassword;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              _getSalesHeader();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _buttonBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text("Sign In"),
          ),
        ),
        const SizedBox(height: 40),
        const Text(
          "Powered by Synergy Center",
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4B5563), fontSize: 14),
        ),
        const SizedBox(height: 14),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sync_rounded, size: 22, color: Color(0xFF6B7280)),
            SizedBox(width: 8),
            Text(
              "v1.0",
              style: TextStyle(color: Color(0xFF4B5563), fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_headerTop, _headerBottom],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _HeaderWavesPainter(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxWidth: 440),
                              child: _buildForm(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _getSalesHeader() async {
    if (userController.text.toString().isEmpty) {
      helper.snackBarNotification("Please provide user Name", context);
      return;
    }

    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Signing in ...",
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

class _HeaderWavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = Colors.white.withOpacity(0.06);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.22)
        ..quadraticBezierTo(w * 0.35, h * 0.12, w * 0.6, h * 0.24)
        ..quadraticBezierTo(w * 0.85, h * 0.36, w, h * 0.26)
        ..lineTo(w, h * 0.45)
        ..lineTo(0, h * 0.45)
        ..close(),
      paint,
    );

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.45, 0)
        ..quadraticBezierTo(w * 0.7, h * 0.12, w, h * 0.08)
        ..lineTo(w, 0)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
//CHECK IF THE passwordController == THE Password_POS
// and the Change_Password_POS == true  Alert the use to reset his password
//else if THE PASSWORDcONTROLLER == THE Password_POS
//and the Change_Password_POS == false Login  
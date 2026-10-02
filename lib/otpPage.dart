import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

import 'bottomNavigation.dart';

class OTP_Page extends StatefulWidget {
  const OTP_Page({super.key});

  @override
  State<OTP_Page> createState() => _OTP_PageState();
}

class _OTP_PageState extends State<OTP_Page> {
  var otcController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color.fromRGBO(15, 86, 148, 1),
        body: Container(
            decoration: BoxDecoration(
                // color: Color.fromRGBO(15, 86, 148, 1),
                // image: DecorationImage(
                //     image: AssetImage("assets/images/art1.png"), fit: BoxFit.none)
                ),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 40,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40),
                                  child: Container(
                                      height: 200,
                                      child:
                                          Image.asset("assets/images/otp.png")),
                                ),
                                Text(
                                  "OTP Verification  ",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  "Hello",
                                  style: TextStyle(color: Colors.black),
                                ),
                                Text(
                                  "Please type your OTP as shared on your email or Phone Number",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(30.0),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(0),
                                        child: OTPTextField(
                                            length: 4,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            textFieldAlignment:
                                                MainAxisAlignment.spaceAround,
                                            fieldWidth: 45,
                                            fieldStyle: FieldStyle.box,
                                            outlineBorderRadius: 15,
                                            style: TextStyle(
                                                fontSize: 17,
                                                color: Colors.black),
                                            onChanged: (pin) {
                                              print("Changed: " + pin);
                                            },
                                            onCompleted: (pin) {
                                              print("Completed: " + pin);
                                            }),
                                        // end onSubmit
                                      ),
                                      SizedBox(
                                        height: 0,
                                      ),
                                      SizedBox(
                                        height: 70,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "OTP not recieved?",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                          Text(
                                            "Resend Code?",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 30,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyNevBar()));
                                        },
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              gradient: LinearGradient(colors: [
                                                Colors.blue,
                                                Colors.blue,
                                              ])),
                                          child: Center(
                                            child: Text(
                                              "Verify OTP",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // Text(
                                //   "One Time PassCode will be send to your\n mobile Number,this may take a minute.",
                                //   style: TextStyle(color: Colors.white),
                                // ),
                                // SizedBox(
                                //   height: 20,
                                // ),
                                Text(
                                  "Powered By Synergy Center",
                                  style: TextStyle(
                                      color:
                                          Color.fromARGB(255, 214, 211, 211)),
                                ),
                              ],
                            ),
                          ),
                        ])),
              ),
            )));
  }
}

 /////////////////////////////////////////////
 ///
 ///
 
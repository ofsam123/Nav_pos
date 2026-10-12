import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

import 'bottomNavigation.dart';
import 'theme/app_theme.dart';

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
        body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                    height: 170,
                    child: Image.asset("assets/images/otp.png")),
                const SizedBox(height: 28),
                const Text(
                  "OTP Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Hello",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Please type your OTP as shared on your email or Phone Number",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                ),
                const SizedBox(height: 32),
                LayoutBuilder(
                  builder: (context, constraints) => OTPTextField(
                      length: 4,
                      width: constraints.maxWidth,
                      textFieldAlignment: MainAxisAlignment.spaceEvenly,
                      fieldWidth: 58,
                      fieldStyle: FieldStyle.box,
                      outlineBorderRadius: 14,
                      otpFieldStyle: OtpFieldStyle(
                        backgroundColor: AppColors.inputFill,
                        borderColor: AppColors.border,
                        enabledBorderColor: AppColors.border,
                        focusBorderColor: AppColors.primary,
                      ),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                      onChanged: (pin) {
                        print("Changed: " + pin);
                      },
                      onCompleted: (pin) {
                        print("Completed: " + pin);
                      }),
                ),
                const SizedBox(height: 28),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "OTP not recieved? ",
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                    Text(
                      "Resend Code?",
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyNevBar()));
                  },
                  child: const Text("Verify OTP"),
                ),
                const SizedBox(height: 32),
                // Text(
                //   "One Time PassCode will be send to your\n mobile Number,this may take a minute.",
                //   style: TextStyle(color: Colors.white),
                // ),
                // SizedBox(
                //   height: 20,
                // ),
                const Text(
                  "Powered By Synergy Center",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

 /////////////////////////////////////////////
 ///
 ///
 

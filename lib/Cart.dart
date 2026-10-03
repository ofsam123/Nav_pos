import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';

import 'API.dart';
import 'bottomNavigation.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class Cart extends StatefulWidget {
  Cart({required this.Docs_No, required this.selectedItems});
  // final List<String> selectedItems;

  String? Docs_No;
  String? selectedItems;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Helper helper = new Helper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Items Cart" + widget.Docs_No.toString(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              height: 36,
              width: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "8",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        itemCount: widget.selectedItems.toString().length,
        itemBuilder: (context, index) {
          return AppCard(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const IconBadge(
                  icon: Icons.liquor_rounded,
                  color: AppColors.primary,
                  size: 40,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.selectedItems.toString()[index],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _postSalesLine();
              },
              icon: const Icon(Icons.shopping_cart_checkout_rounded),
              label: const Text('Check Out: 2,000₵'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _postSalesLine() async {
    // if (userNameController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide user Name", context);
    //   return;
    // }
    // if (passwordController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide password", context);
    //   return;
    // }
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .post(
      Uri.parse(ApiUrl.SalesLineAPI),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
      body: jsonEncode(<String, dynamic>{
        "Document_Type": "Order",
        "Document_No": widget.Docs_No,
        "No": "BDO001",
        "Description": "QWERTY",
        "Quantity": 99,
        "Location_Code": Location_Code,
        "Type": "Item",
        "Document_Type": "Order",
        "Document_No": 169,
        "No": "CMT059",
        "Description": "Sam",
        "Quantity": 16,
        "Type": "Item",
        "Location_Code": "SAL1"
      }),
    )
        .catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 201) {
      progressDialog.hide();

      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => MyNevBar())));

      setState(() {
        // Docs_No = responseJson["No"].toString();
      });

      // String role1 = responseJson["roles"].toString();
      // String active      = responseJson["active"] .toString();
      // String token = responseJson["token"].toString();
      progressDialog.hide();

      helper.flushBar2("Success", "Submited Successfully", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }
}

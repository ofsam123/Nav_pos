import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nav_pos/Staticticsdetail.dart/TransferToRevcioeveDeatilsPage.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:nav_pos/widgets/app_loader.dart';
import '../API.dart';
import '../Models/transferToReveiveModel.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class TransferToRecieve extends StatefulWidget {
  TransferToRecieve({super.key, required this.responsCenter});

  String? responsCenter;
  @override
  State<TransferToRecieve> createState() => _TransferToRecieveState();
}

class _TransferToRecieveState extends State<TransferToRecieve> {
  final Helper helper = new Helper();

  late Future<List<TransferToRevieveModel>> _func;

  @override
  void initState() {
    _func = _getItems1();
    Timer(Duration(seconds: 1), () {
      setState(() {
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  String? token;
  String? userTypeId;

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = (prefs.getString('token') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer To Receive"),
      ),
      body: FutureBuilder(
        future: _func,
        builder: (context, data) {
          if (data.hasError) {
            return const EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Failed to load data',
            );
          } else if (data.hasData) {
            var items = data.data as List<TransferToRevieveModel>;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.local_shipping_outlined,
                title: "No Items Recieve",
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final received =
                    items[index].POS_Status.toString().contains("Received");
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => transferToReciveDetailsPage(
                                  docsNo: items[index].No.toString(),
                                )));
                  },
                  child: Row(
                    children: [
                      const IconBadge(
                        icon: Icons.local_shipping_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayValue(items[index].No.toString()),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 6),
                            StatusPill(
                              text: displayValue(
                                  items[index].POS_Status.toString()),
                              color: received
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayValue(
                                  items[index].Posting_Date.toString()),
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: !items[index]
                            .POS_Status
                            .toString()
                            .contains("Received"),
                        child: IconButton(
                          tooltip: "Receive",
                          color: AppColors.primary,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Confirm Receipt"),
                                  content: Text(
                                    "Confirm Receipt of Transfer No " +
                                        items[index].No.toString(),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Cancel"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(120, 44),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        // _postVisitation();
                                        _updateHeader(
                                            items[index].No.toString());
                                      },
                                      child: const Text("Submit"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppColors.textMuted),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: AppLoader()),
            );
          }
        },
      ),
    );
  }

  Future<List<TransferToRevieveModel>> _getItems1() async {
    // helper.checkForInternet(context);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    // AppLoadingDialog progressDialog =
    //     AppLoadingDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "loading ...",
    // );
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '${widget.responsCenter.toString()}' and Completely_Shipped eq true and Shipment_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      //progressDialog.hide();
      // progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
      // helper.alertDialogTitle('${Helper.errorMessageOops}', '${err.toString()}', context);
    });
//
    if (response.statusCode == 200) {
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);
      String apiResponse = responseJson["value"].toString();
      List responseList = json.decode(response.body)["value"];
      // helper.alertDialogNoTitle(response.body, context);
      return responseList
          .map((job) => TransferToRevieveModel.fromJson(job))
          .toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }

  Future<void> _updateHeader(String no) async {
    // if (passwordController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide password", context);
    //   return;
    // }
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Updating ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .patch(Uri.parse(ApiUrl.TransferHeaderAPI + "(No = '$no')"),
            headers: {
              'Content': 'application/x-www-form-urlencoded',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': '$basicAuth',
              "Access-Control-Allow-Origin": "*",
              "If-Match": "*"
            },
            body: jsonEncode(<String, String>{"POS_Status": "Received"}))
        .catchError((err) {
      progressDialog.hide();
      // helper.alertDialogTitle('${Helper.errorMessageOops}',
      //     '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyNevBar()));
      helper.flushBar2("Success", "Updated", context);
      //IF STC 200 UPDATE THE BUTTON TO RECIEVED BASE ON EACH ITEM IN THE LIST

      progressDialog.hide();

      // helper.flushBar2("Success", "Login Successful", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);
    }
  }
}

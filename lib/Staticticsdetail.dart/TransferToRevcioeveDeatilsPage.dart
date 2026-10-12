import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/menuItemsComponent.dart/itemsSoldToday.dart';
import 'package:nav_pos/trackDeatails.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API.dart';
import '../Models/TransferToRecieveDetailsModel.dart';
import '../Models/itemsSoldModel.dart';
import '../Models/postedInvoiceDetailsModel.dart';
import '../Models/postedSalesInvoiceModel.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class transferToReciveDetailsPage extends StatefulWidget {
  transferToReciveDetailsPage({required this.docsNo});

  String? docsNo;

  @override
  State<transferToReciveDetailsPage> createState() =>
      _transferToReciveDetailsPageState();
}

class _transferToReciveDetailsPageState
    extends State<transferToReciveDetailsPage> {
  final Helper helper = new Helper();

  late Future<List<ttrModel>> _func;

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
        title: const Text("Details"),
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
            var items = data.data as List<ttrModel>;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                AppCard(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      _infoRow("Transfer No", displayValue(widget.docsNo)),
                      const SizedBox(height: 10),
                      _infoRow("Lines", items.length.toString()),
                    ],
                  ),
                ),
                const SmallCapsLabel("Transfer lines"),
                for (final item in items)
                  AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconBadge(
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayValue(item.Description.toString()),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "No. ${displayValue(item.Item_No.toString())}",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Receipt ${displayValue(item.Receipt_Date.toString())}",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayValue(item.Quantity.toString()),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            const Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              displayValue(item.Qty_to_Receive.toString()),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            const Text(
                              "To receive",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
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

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Future<List<ttrModel>> _getItems1() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferLineAPI?" +
              "\$filter=Document_No eq '${widget.docsNo.toString()}' and Completely_Shipped eq true and Shipment_Date eq ${now.year}-${now.month}-${now.day}"),
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
      return responseList.map((job) => ttrModel.fromJson(job)).toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

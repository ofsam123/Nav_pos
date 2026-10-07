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
import '../Models/itemsSoldModel.dart';
import '../Models/postedInvoiceDetailsModel.dart';
import '../Models/postedSalesInvoiceModel.dart';
import '../Models/returnOrder.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class returnOrder extends StatefulWidget {
  // returnOrder({required this.docsNo});

  // String? docsNo;
  @override
  State<returnOrder> createState() => _returnOrderState();
}

class _returnOrderState extends State<returnOrder> {
  final Helper helper = new Helper();

  late Future<List<returnOrderModel>> _func;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Return Order"),
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
            var items = data.data as List<returnOrderModel>;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.assignment_return_outlined,
                title: "No return orders",
                message: "There is no data currently available",
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: items.length + 1,
              itemBuilder: (context, position) {
                if (position == 0) {
                  return SmallCapsLabel(
                      '${items.length} ${items.length == 1 ? 'order' : 'orders'}');
                }
                final index = position - 1;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const IconBadge(
                        icon: Icons.assignment_return_outlined,
                        color: AppColors.warning,
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
                            const SizedBox(height: 4),
                            Text(
                              "Posted ${displayValue(items[index].Posting_Date.toString())}",
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            StatusPill(
                              text: displayValue(items[index].Status.toString()),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayValue(items[index].Items_Weight.toString()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Items weight",
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
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

  Future<List<returnOrderModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq 2023-09-07 and Transfer_from_Code eq 'SAL1' and Completely_Shipped eq false"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson.containsKey("value")) {
        List responseList = responseJson["value"];
        return responseList
            .map((job) => returnOrderModel.fromJson(job))
            .toList();
      } else {
        // Value is empty, don't show an alert, and return an empty list.

        // helper.alertDialogNoTitle("No Available List", context);
        return [];
      }
    } else {
      // If that call was not successful, throw an error.
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

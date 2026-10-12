import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../API.dart';
import '../Models/TotalItemReceivedModel.dart';
import '../Models/itemsSoldModel.dart';
import '../Models/myTransferOrdModel.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class myTransferOrder extends StatefulWidget {
  myTransferOrder({required this.responsibilityCenter});
  final String responsibilityCenter;

  @override
  State<myTransferOrder> createState() => _totalItemsRevivedState();
}

class _totalItemsRevivedState extends State<myTransferOrder> {
  final Helper helper = Helper();
  late Future<List<tranOrdModel>> _func;
  String? token;
  String? userTypeId;

  DateTime now = DateTime.now();

  // Create a map to store the sum of quantities for each unique Item_No
  Map<String, int> _totalQuantities = {};

  @override
  void initState() {
    _func = _getItems1();
    _getUserData();
    super.initState();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer Orders')),
      body: FutureBuilder(
        future: _func,
        builder: (context, data) {
          if (data.hasError) {
            return const EmptyState(
              icon: Icons.cloud_off_rounded,
              title: 'Failed to load data',
              message: 'Please check your connection and try again later.',
            );
          } else if (data.hasData) {
            var items = data.data as List<tranOrdModel>;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.local_shipping_outlined,
                title: 'No Item Received Today',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: _totalQuantities.length,
              itemBuilder: (context, index) {
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () {
                    // Handle item tap
                  },
                  child: Row(
                    children: [
                      const IconBadge(
                        icon: Icons.local_shipping_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[0].No.toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Q',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        items[0].DescriTransfer_to_Codeption_2.toString(),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
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

  Future<List<tranOrdModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = prefs.getString('Sales_Resp_Ctr_Filter') ?? '';
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '${widget.responsibilityCenter.toString()}' and Completely_Shipped eq false"),
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
      String apiResponse = responseJson["value"].toString();
      List responseList = json.decode(response.body)["value"];

      // Calculate the sum of quantities for each unique Item_No

      return responseList.map((job) => tranOrdModel.fromJson(job)).toList();
    } else {
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

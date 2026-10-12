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
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: AppColors.textMuted),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class SalesOrderDetails extends StatefulWidget {
  SalesOrderDetails({required this.docsNo});

  String? docsNo;

  @override
  State<SalesOrderDetails> createState() => _SalesOrderDetailsState();
}

class _SalesOrderDetailsState extends State<SalesOrderDetails> {
  final Helper helper = new Helper();

  late Future<List<postedSaledDetailsModel>> _func;

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
      appBar: AppBar(title: const Text('Sales Order')),
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
            var items = data.data as List<postedSaledDetailsModel>;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No order lines found',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const IconBadge(
                            icon: Icons.inventory_2_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.Description.toString(),
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
                                  'No. ${item.No.toString()}',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1, color: AppColors.border),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Quantity',
                        value: item.Quantity.toString(),
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        label: 'Amount Including VAT',
                        value: 'GH₵ ${item.Amount_Including_VAT.toString()}',
                        valueColor: AppColors.success,
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

  Future<List<postedSaledDetailsModel>> _getItems1() async {
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
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/OSalesLineAPI?" +
              "\$filter=Document_No eq '${widget.docsNo.toString()}'"),
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
          .map((job) => postedSaledDetailsModel.fromJson(job))
          .toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

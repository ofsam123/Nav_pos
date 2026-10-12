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
import '../Models/postedSalesInvoiceModel.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import 'PostedSalesDetails.dart';

class PostedSales extends StatefulWidget {
  PostedSales({required this.responsibilityCenter});
  String? responsibilityCenter;

  @override
  State<PostedSales> createState() => _PostedSalesState();
}

class _PostedSalesState extends State<PostedSales> {
  DateTime now = DateTime.now();
  final Helper helper = new Helper();

  late Future<List<postedSaledModel>> _func;
  String resCenter1 = "";
  @override
  void initState() {
    _getUserData();
    _func = _getItems1();
    Timer(Duration(seconds: 1), () {
      setState(() {
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  String? UserName;
  String? userTypeId;
  String userResCenter = "";

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _func = _getItems1();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posted Sales"),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder(
          future: _func,
          builder: (context, data) {
            if (data.hasError) {
              return _scrollable(const [
                EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Failed to load data',
                ),
              ]);
            } else if (data.hasData) {
              var items = data.data as List<postedSaledModel>;
              if (items.isEmpty) {
                return _scrollable(const [
                  EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: "No Posted Sales Invoice",
                  ),
                ]);
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostedSalesDetails(
                                    docsNo: items[index].No.toString(),
                                  )));
                    },
                    child: Row(
                      children: [
                        const IconBadge(
                          icon: Icons.receipt_long_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayValue(
                                    item.Sell_to_Customer_Name.toString()),
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
                                displayValue(item.No.toString()),
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Customer ${displayValue(item.Sell_to_Customer_No.toString())}",
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          displayValue(item.Posting_Date.toString()),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted),
                      ],
                    ),
                  );
                },
              );
            } else {
              return _scrollable(const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: AppLoader()),
                ),
              ]);
            }
          },
        ),
      ),
    );
  }

  Widget _scrollable(List<Widget> children) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: children,
    );
  }

  Future<List<postedSaledModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvHeaderAPI?" +
              "\$filter=Responsibility_Center eq  " +
              "\'" +
              "${widget.responsibilityCenter.toString()}" +
              "\'" +
              " and Posting_Date eq " +
              "${now.year}-${now.month}-${now.day}"),
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
      return responseList.map((job) => postedSaledModel.fromJson(job)).toList();
      // progressDialog.hide();
    } else {
      // If that call was not successful, throw an error.
      // progressDialog.hide();

      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

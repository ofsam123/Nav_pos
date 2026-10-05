import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nav_pos/Staticticsdetail.dart/TotalItemRecievedHistory.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../API.dart';
import '../Models/TotalItemReceivedModel.dart';
import '../Models/itemsSoldModel.dart';
import '../apiHelper.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';

class _ReceivedItemRow extends StatelessWidget {
  const _ReceivedItemRow({
    required this.itemNo,
    required this.quantity,
    required this.date,
  });

  final String itemNo;
  final int quantity;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const IconBadge(icon: Icons.inventory_2_rounded, color: AppColors.success),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                itemNo,
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
                date,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Text(
              'Qty',
              style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
            ),
          ],
        ),
      ],
    );
  }
}

class totalItemsRevived extends StatefulWidget {
  totalItemsRevived({required this.responsibilityCenter});
  final String responsibilityCenter;

  @override
  State<totalItemsRevived> createState() => _totalItemsRevivedState();
}

class _totalItemsRevivedState extends State<totalItemsRevived> {
  final Helper helper = Helper();
  late Future<List<itemsRecivedModel>> _func;
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
      appBar: AppBar(
        title: const Text('Total Item Received Today'),
        actions: [
          IconButton(
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TotalItemRecievedHistory(
                            responsibilityCenter:
                                widget.responsibilityCenter.toString(),
                          )));
            },
            icon: const Icon(Icons.history_rounded),
          ),
        ],
      ),
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
            var items = data.data as List<itemsRecivedModel>;
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.move_to_inbox_outlined,
                title: 'No Item Received Today',
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              itemCount: _totalQuantities.length,
              itemBuilder: (context, index) {
                String itemNo = _totalQuantities.keys.elementAt(index);
                int totalQuantity = _totalQuantities[itemNo]!;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () {
                    // Handle item tap
                  },
                  child: _ReceivedItemRow(
                    itemNo: itemNo,
                    quantity: totalQuantity,
                    date: items[0].Posting_Date.toString(),
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

  Future<List<itemsRecivedModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String resCenter = prefs.getString('Sales_Resp_Ctr_Filter') ?? '';
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/ItemLedgerEntryAPI?" +
              "\$filter=Location_Code eq '${widget.responsibilityCenter.toString()}' and Posting_Date eq ${now.year}-${now.month}-${now.day} and Quantity gt 0 and Entry_Type eq 'Transfer'"),
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
      _totalQuantities.clear();
      for (var job in responseList) {
        itemsRecivedModel item = itemsRecivedModel.fromJson(job);
        String itemNo = item.Item_No.toString();
        int? quantity = item.Quantity;
        if (_totalQuantities.containsKey(itemNo)) {
          _totalQuantities[itemNo] =
              (_totalQuantities[itemNo] ?? 0) + (item.Quantity ?? 0);
        } else {
          _totalQuantities[itemNo] = item.Quantity ?? 0;
        }
      }

      return responseList
          .map((job) => itemsRecivedModel.fromJson(job))
          .toList();
    } else {
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }
}

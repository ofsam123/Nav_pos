import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';

import 'API.dart';
import 'Models/ItemsModel.dart';
import 'bottomNavigation.dart';
import 'customerProfile.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class SelectionPage extends StatefulWidget {
  final List<itemsModel> selectedItems;
  final String customerId;
  final String name;
  final String salespersonCode;
  final String responsibilityCenter;

  SelectionPage(
      {required this.selectedItems,
      required this.customerId,
      required this.name,
      required this.salespersonCode,
      required this.responsibilityCenter});

  @override
  _SelectionPageState createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  List<itemsModel> selectedItems = [];
  final Helper helper = Helper();

  DateTime now = DateTime.now();
  String Doc_No = "";
  String currentTime = '';

  List<TextEditingController> quantityControllers = [];
  List<List<String>> dropdownItems = [];
  Map<int, String?> selectedCodeMap = {};

  @override
  void initState() {
    getCurrentTime();
    super.initState();
    selectedItems.addAll(widget.selectedItems);
    quantityControllers.addAll(
      List.generate(
        selectedItems.length,
        (index) => TextEditingController(text: '1'),
      ),
    );

    dropdownItems.addAll(
      List.generate(
        selectedItems.length,
        (index) => <String>[],
      ),
    );

    Timer(Duration(seconds: 1), () {
      setState(() {
        if (selectedItems.isNotEmpty) {
          for (int i = 0; i < selectedItems.length; i++) {
            _getUnitMeasure2(i);
          }
        }
      });
    });
  }

  void getCurrentTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    setState(() {
      currentTime = formattedTime;
    });

    // Update the current time every second (optional)
    Future.delayed(Duration(seconds: 1), getCurrentTime);
  }

  List<String> randomProductImageURLs = [
    "https://images.pexels.com/photos/2912108/pexels-photo-2912108.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/3490355/pexels-photo-3490355.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://m.media-amazon.com/images/I/61KqnxQdPCL.jpg",
    "https://thewoksoflife.com/wp-content/uploads/2019/09/shaoxing-wine.jpg"
        "https://img.freepik.com/free-photo/wine-bottle-glass-grapes-isolated-white_167946-36.jpg?size=626&ext=jpg&ga=GA1.2.1776209590.1686836153&semt=sph"
    // Add more image URLs here
  ];
  static const int _maxInlineUnits = 4;

  int get _totalUnits => quantityControllers.fold<int>(
      0, (sum, c) => sum + (int.tryParse(c.text) ?? 0));

  void _changeQuantity(int index, int delta) {
    final current = int.tryParse(quantityControllers[index].text) ?? 0;
    final next = current + delta;
    if (next < 1) return;
    setState(() {
      quantityControllers[index].text = next.toString();
    });
  }

  Future<void> _pickUnit(int index) async {
    final options = dropdownItems[index];
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        String query = '';
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final filtered = options
                .where((o) => o.toLowerCase().contains(query.toLowerCase()))
                .toList();
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                      child: Text(
                        "Unit of measure",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        "${selectedItems[index].Item_Description} · ${options.length} units",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    if (options.length > 6)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: TextField(
                          onChanged: (value) =>
                              setSheetState(() => query = value),
                          decoration: const InputDecoration(
                            hintText: "Search units",
                            prefixIcon: Icon(Icons.search_rounded),
                          ),
                        ),
                      ),
                    Flexible(
                      child: filtered.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                "No matching units",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final code = filtered[i];
                                final isSelected =
                                    selectedCodeMap[index] == code;
                                return ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primarySoft,
                                  leading: Icon(
                                    isSelected
                                        ? Icons.radio_button_checked_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                  title: Text(
                                    code,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  onTap: () =>
                                      Navigator.pop(sheetContext, code),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (picked != null) {
      setState(() {
        selectedCodeMap[index] = picked;
      });
    }
  }

  Widget _buildUnitSelector(int index) {
    final options = dropdownItems[index];
    final selected = selectedCodeMap[index];

    if (options.isEmpty) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: AppLoader(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text(
            "Loading units…",
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      );
    }

    if (options.length <= _maxInlineUnits) {
      return Wrap(
        spacing: 10,
        runSpacing: 8,
        alignment: WrapAlignment.end,
        children: [
          for (final code in options)
            _UnitChip(
              label: code,
              selected: selected == code,
              onTap: () {
                setState(() {
                  selectedCodeMap[index] = code;
                });
              },
            ),
        ],
      );
    }

    return Material(
      color: selected == null ? AppColors.surface : AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected == null ? const Color(0xFFD1D5DB) : AppColors.primary,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _pickUnit(index),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  selected ?? "Unit (${options.length})",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: selected == null
                        ? AppColors.textMuted
                        : Colors.white,
                  ),
                ),
              ),
              Icon(
                Icons.expand_more_rounded,
                color: selected == null ? AppColors.textMuted : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(int index) {
    return Container(
      height: 44,
      padding: const EdgeInsets.only(left: 2, right: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () => _changeQuantity(index, -1),
            icon: const Icon(Icons.remove_rounded,
                color: AppColors.textDark, size: 22),
          ),
          SizedBox(
            width: 40,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: quantityControllers[index],
              onChanged: (value1) {
                setState(() {});
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
              decoration: const InputDecoration(
                hintText: "0",
                isDense: true,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () => _changeQuantity(index, 1),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.liquor_rounded,
                    color: Color(0xFF6B7280), size: 40),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${selectedItems[index].Item_Description}",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayValue(selectedItems[index].Item_No),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: "Remove",
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Color(0xFFD9534F), size: 26),
                onPressed: () {
                  removeItem(index);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                _buildQuantityStepper(index),
                const SizedBox(width: 14),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildUnitSelector(index),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        shape: const Border(),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initialsOf(widget.name),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayValue(widget.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.customerId,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SmallCapsLabel("Items (${selectedItems.length})"),
          const SizedBox(height: 4),
          if (selectedItems.isEmpty)
            const EmptyState(
              icon: Icons.remove_shopping_cart_outlined,
              title: "Your cart is empty",
              message: "Go back and select items for this customer.",
            )
          else
            for (int index = 0; index < selectedItems.length; index++)
              _buildCartItem(index),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F1D4A).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      "${selectedItems.length} item${selectedItems.length == 1 ? '' : 's'}",
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "$_totalUnits units",
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _getSalesHeader();
                    },
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded,
                        size: 26),
                    label: const Text("Place Order"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void removeItem(int index) {
    setState(() {
      if (index >= 0 && index < selectedItems.length) {
        selectedItems.removeAt(index);
        quantityControllers.removeAt(index);
        dropdownItems.removeAt(index);
        selectedCodeMap.remove(index);
      }
    });
  }

  Future<void> _postSalesLine() async {
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

    bool allLinesPosted = true;

    for (int i = 0; i < selectedItems.length; i++) {
      // Initialize Description and No variables for each item
      String description = selectedItems[i].Item_Description ?? "";
      String no = selectedItems[i].Item_No ?? "";

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
          "Document_No": Doc_No.toString(),
          "Description": description, // Use the extracted description
          "Quantity": int.tryParse(quantityControllers[i].text) ??
              0, // Use the respective controller value
          "Type": "Item",
          "No": no, // Use the extracted No
          "Location_Code": Location_Code.toString(),
          "Unit_of_Measure_Code": selectedCodeMap[i],
        }),
      )
          .catchError((err) {
        progressDialog.hide();
        helper.alertDialogTitle('${Helper.errorMessageOops}',
            '${Helper.errorMessageSomethingWentWrong}', context);
      });

      if (response.statusCode != 201) {
        allLinesPosted = false;
        break;
      }
    }

    progressDialog.hide();

    if (allLinesPosted) {
      await _postVisitation();
    } else {
      helper.flushBar2("Error", "OOPS! Try again...", context);
    }
  }

  Future<void> _getSalesHeader() async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String auth = (prefs.getString('auth') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http
        .post(
      Uri.parse(ApiUrl.SalesHeaderAPI),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
      body: jsonEncode(<String, dynamic>{
        "Sell_to_Customer_No": widget.customerId.toString(),
        "Sell_to_Customer_Name": widget.name.toString(),
        "Salesperson_Code": widget.salespersonCode.toString(),
        "Responsibility_Center": widget.responsibilityCenter.toString(),
        "Document_Type": "Order",
        "Posting_Date": "${now.year}-${now.month}-${now.day}",
        "Prices_Including_VAT": true,
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

      setState(() {
        Doc_No = responseJson["No"].toString();
        _postSalesLine();
      });
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);
    }
  }

  Future<void> _postVisitation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        helper.flushBar2("Error",
            "Location permission is required to record the visit", context);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      AppLoadingDialog progressDialog =
          AppLoadingDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Submitting ...",
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String User_Name = (prefs.getString('User_Name') ?? '');
      String basicAuth = 'Basic ' +
          base64Encode(
              utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
      final response = await http
          .post(
        Uri.parse(ApiUrl.VisitationApi),
        headers: {
          'Content': 'application/x-www-form-urlencoded',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': '$basicAuth',
          "Access-Control-Allow-Origin": "*",
        },
        body: jsonEncode(<String, dynamic>{
          "CustomerID": widget.customerId,
          "Date": "${now.year}-${now.month}-${now.day}",
          "UserID": User_Name,
          "Longitute": longitude,
          "Latitude": latitude,
          "Visitation_Type": "Visitation and Sales",
          "Time": currentTime,
        }),
      )
          .catchError((err) {
        progressDialog.hide();
      });

      progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        progressDialog.hide();
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyNevBar()));

        helper.flushBar2("Success", "Items Submitted Successfuly", context);
      } else {
        progressDialog.hide();
        helper.flushBar2("Error", "OOPS! Try again ", context);
      }
    } catch (e) {
      print("Error: $e");
      helper.flushBar2("Error", e.toString(), context);
    }
  }

  Future<void> _getUnitMeasure2(int index) async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading units ...",
    );

    if (index < 0 || index >= selectedItems.length) {
      progressDialog.hide();
      return;
    }

    String? itemNo = selectedItems[index].Item_No;

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));

    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ItemUnitofMeasureAPI?\$filter=Item_No eq '$itemNo'"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    progressDialog.hide();
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      progressDialog.hide();
      setState(() {
        dropdownItems[index] = List<String>.from(
          json
              .decode(response.body)["value"]
              .map((item) => item["Code"].toString()),
        );
      });
    } else {
      progressDialog.hide();
      helper.toastFailedNotification(Helper.errorMessageSomethingWentWrong);
      throw Exception('Failed to load post');
    }
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: selected ? AppColors.primary : const Color(0xFFD1D5DB),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          alignment: Alignment.center,
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 15,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

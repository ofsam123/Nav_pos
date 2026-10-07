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
import 'widgets/cart_widgets.dart';

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
      if (!mounted) return;
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
                        "${selectedItems[index].Item_Description} Â· ${options.length} units",
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

  int get _missingUnits {
    var count = 0;
    for (var i = 0; i < selectedItems.length; i++) {
      if (dropdownItems[i].isNotEmpty && selectedCodeMap[i] == null) count++;
    }
    return count;
  }

  static const TextStyle _fieldLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  Widget _buildUnitSelector(int index) {
    final options = dropdownItems[index];
    final selected = selectedCodeMap[index];

    if (options.isEmpty) {
      return const Row(
        children: [
          SizedBox(width: 14, height: 14, child: AppLoader(strokeWidth: 2)),
          SizedBox(width: 8),
          Text(
            "Loading unitsâ€¦",
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      );
    }

    if (options.length <= _maxInlineUnits) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final code in options) ...[
              UnitChip(
                label: code,
                selected: selected == code,
                warn: selected == null,
                onTap: () => setState(() => selectedCodeMap[index] = code),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      );
    }

    final hasValue = selected != null;
    final accent = hasValue ? AppColors.primary : AppColors.warning;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: hasValue ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: hasValue ? AppColors.primary : accent),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _pickUnit(index),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    hasValue
                        ? selected.toUpperCase()
                        : "Unit (${options.length})",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: accent,
                    ),
                  ),
                ),
                Icon(Icons.expand_more_rounded, size: 18, color: accent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantityStepper(int index) {
    final quantity = int.tryParse(quantityControllers[index].text) ?? 0;
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StepButton(
            icon: Icons.remove_rounded,
            onTap: quantity > 1 ? () => _changeQuantity(index, -1) : null,
          ),
          SizedBox(
            width: 38,
            child: TextField(
              keyboardType: TextInputType.number,
              controller: quantityControllers[index],
              onChanged: (value1) {
                setState(() {});
              },
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
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
          StepButton(
            icon: Icons.add_rounded,
            filled: true,
            onTap: () => _changeQuantity(index, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = selectedItems[index];

    return Dismissible(
      key: ObjectKey(item),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => removeItem(index),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Remove",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.liquor_rounded,
                      color: AppColors.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayValue(item.Item_Description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        displayValue(item.Item_No),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                InkResponse(
                  onTap: () => removeItem(index),
                  radius: 18,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded,
                        color: AppColors.textMuted, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildUnitSelector(index)),
                const SizedBox(width: 10),
                _buildQuantityStepper(index),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              initialsOf(widget.name),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ORDER FOR", style: _fieldLabel),
                const SizedBox(height: 3),
                Text(
                  displayValue(widget.name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.customerId,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.storefront_outlined, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    final missing = _missingUnits;
    final itemCount = selectedItems.length;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TOTAL", style: _fieldLabel),
                      const SizedBox(height: 2),
                      Text(
                        "$_totalUnits unit${_totalUnits == 1 ? '' : 's'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    "$itemCount item${itemCount == 1 ? '' : 's'}",
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (missing > 0) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.warning),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "$missing item${missing == 1 ? '' : 's'} still need${missing == 1 ? 's' : ''} a unit",
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    _getSalesHeader();
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Place order"),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: selectedItems.isEmpty
          ? Center(
              child: EmptyState(
                icon: Icons.remove_shopping_cart_outlined,
                title: "Your cart is empty",
                message: "Go back and select items for this customer.",
                action: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text("Back to items"),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _buildCustomerCard(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Text(
                      "Items",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${selectedItems.length}",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      "Swipe left to remove",
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (int index = 0; index < selectedItems.length; index++)
                  _buildCartItem(index),
              ],
            ),
      bottomNavigationBar: selectedItems.isEmpty ? null : _buildSummaryBar(),
    );
  }

  void removeItem(int index) {
    setState(() {
      if (index >= 0 && index < selectedItems.length) {
        selectedItems.removeAt(index);
        quantityControllers.removeAt(index);
        dropdownItems.removeAt(index);
        // Units are keyed by position, so items after the removed one shift up.
        final shifted = <int, String?>{};
        selectedCodeMap.forEach((i, code) {
          if (i < index) shifted[i] = code;
          if (i > index) shifted[i - 1] = code;
        });
        selectedCodeMap
          ..clear()
          ..addAll(shifted);
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
    if (index < 0 || index >= selectedItems.length) {
      return;
    }

    final requestedItem = selectedItems[index];
    String? itemNo = requestedItem.Item_No;

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
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    if (!mounted) return;
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // The item may have moved or been removed while its units loaded.
      final currentIndex = selectedItems.indexOf(requestedItem);
      if (currentIndex < 0) return;
      setState(() {
        dropdownItems[currentIndex] = List<String>.from(
          json
              .decode(response.body)["value"]
              .map((item) => item["Code"].toString()),
        );
      });
    } else {
      helper.toastFailedNotification(Helper.errorMessageSomethingWentWrong);
      throw Exception('Failed to load post');
    }
  }
}

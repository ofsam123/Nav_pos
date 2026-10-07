import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'API.dart';
import 'Models/customerModel.dart';
import 'apiHelper.dart';
import 'itemCart.dart';
import 'theme/app_theme.dart';
import 'widgets/app_loader.dart';
import 'widgets/app_widgets.dart';
import 'widgets/cart_widgets.dart';

Map<String, String> _headers() {
  final basicAuth = 'Basic ' +
      base64Encode(utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
  return {
    'Content': 'application/x-www-form-urlencoded',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': basicAuth,
    "Access-Control-Allow-Origin": "*",
  };
}

String _serverMessage(http.Response response) {
  try {
    final message = jsonDecode(response.body)["error"]["message"];
    if (message is String && message.trim().isNotEmpty) return message.trim();
  } catch (_) {}
  return "The server returned an error (${response.statusCode}).";
}

class ItemCartPage extends StatefulWidget {
  const ItemCartPage({super.key});

  @override
  State<ItemCartPage> createState() => _ItemCartPageState();
}

class _ItemCartPageState extends State<ItemCartPage> {
  final ItemCart cart = ItemCart.instance;
  final Helper helper = Helper();
  final Map<ItemCartLine, TextEditingController> _qtyControllers = {};

  static const int _maxInlineUnits = 4;

  /// Order already created in NAV whose lines did not all post. Retrying for
  /// the same customer adds the remaining lines to it instead of a new order.
  String? _openDocNo;
  String? _openDocCustomerNo;

  static const TextStyle _fieldLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _qtyController(ItemCartLine line) {
    final controller = _qtyControllers.putIfAbsent(
        line, () => TextEditingController(text: '${line.quantity}'));
    return controller;
  }

  void _changeQuantity(ItemCartLine line, int delta) {
    final next = line.quantity + delta;
    if (next < 1) return;
    cart.setQuantity(line, next);
    _qtyController(line).text = '$next';
  }

  void _remove(ItemCartLine line) {
    cart.remove(line);
    _qtyControllers.remove(line)?.dispose();
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text("All items will be removed from the cart."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
    if (ok == true) {
      cart.clear();
      for (final c in _qtyControllers.values) {
        c.dispose();
      }
      _qtyControllers.clear();
    }
  }

  // ---------------------------------------------------------------- checkout

  Future<void> _checkout() async {
    FocusScope.of(context).unfocus();
    if (cart.unitsLoading) {
      helper.flushBar2(
          "Warning", "Units are still loading, try again in a moment", context);
      return;
    }
    if (cart.lines.any((l) => l.unitsFailed)) {
      helper.flushBar2("Warning",
          "Some units couldn't load. Tap Retry on those items first.", context);
      return;
    }
    final missing = cart.missingUnits;
    if (missing > 0) {
      helper.flushBar2(
          "Warning",
          "Choose a unit for $missing item${missing == 1 ? '' : 's'}",
          context);
      return;
    }

    final userContext = await _loadUserContext();
    if (userContext == null || !mounted) return;

    final customer = await showDialog<customerModel>(
      context: context,
      builder: (_) => CustomerPickerDialog(
        responsibilityCenter: userContext.resCenter,
        initialCustomerNo: _openDocCustomerNo,
        itemCount: cart.itemCount,
        totalUnits: cart.totalUnits,
      ),
    );
    if (customer == null || !mounted) return;

    await _placeOrder(customer, userContext.locationCode);
  }

  Future<({String resCenter, String locationCode})?> _loadUserContext() async {
    final prefs = await SharedPreferences.getInstance();
    final resCenter = prefs.getString('userResCenter') ?? '';
    final locationCode = prefs.getString('Location_Code') ?? '';
    if (resCenter.isNotEmpty && locationCode.isNotEmpty) {
      return (resCenter: resCenter, locationCode: locationCode);
    }

    if (!mounted) return null;
    final progress = AppLoadingDialog(context: context);
    progress.show(message: "Loading your data");
    try {
      final userName = prefs.getString('User_Name') ?? '';
      final response = await http.get(
        Uri.parse(ApiUrl.ResponsibilityCenterAPI + "$userName'"),
        headers: _headers(),
      );
      progress.hide();
      if (!mounted) return null;
      final rows = response.statusCode == 200
          ? jsonDecode(response.body)["value"] as List
          : null;
      if (rows == null || rows.isEmpty) {
        helper.alertDialogTitle(
            "Can't check out",
            rows == null
                ? _serverMessage(response)
                : "No responsibility center is set up for $userName.",
            context);
        return null;
      }
      final row = rows.first;
      final loadedResCenter = row["Sales_Resp_Ctr_Filter"].toString();
      final loadedLocation = row["Location_Code"].toString();
      prefs.setString('userResCenter', loadedResCenter);
      prefs.setString('Code', row["Code"].toString());
      prefs.setString('Location_Code', loadedLocation);
      return (resCenter: loadedResCenter, locationCode: loadedLocation);
    } catch (_) {
      progress.hide();
      if (mounted) {
        helper.alertDialogTitle('${Helper.errorMessageOops}',
            '${Helper.errorMessageSomethingWentWrong}', context);
      }
      return null;
    }
  }

  Future<void> _placeOrder(customerModel customer, String locationCode) async {
    final progress = AppLoadingDialog(context: context);
    progress.show(message: "Creating order");
    final now = DateTime.now();

    try {
      String docNo;
      if (_openDocNo != null && _openDocCustomerNo == customer.No) {
        docNo = _openDocNo!;
      } else {
        final header = await http.post(
          Uri.parse(ApiUrl.SalesHeaderAPI),
          headers: _headers(),
          body: jsonEncode(<String, dynamic>{
            "Sell_to_Customer_No": customer.No.toString(),
            "Sell_to_Customer_Name": customer.Name.toString(),
            "Salesperson_Code": customer.Salesperson_Code.toString(),
            "Responsibility_Center": customer.Responsibility_Center.toString(),
            "Document_Type": "Order",
            "Posting_Date": "${now.year}-${now.month}-${now.day}",
            "Prices_Including_VAT": true,
          }),
        );
        if (header.statusCode != 201) {
          progress.hide();
          if (mounted) {
            helper.alertDialogTitle(
                "Couldn't create the order", _serverMessage(header), context);
          }
          return;
        }
        docNo = jsonDecode(header.body)["No"].toString();
        _openDocNo = docNo;
        _openDocCustomerNo = customer.No;
      }

      final lines = List.of(cart.lines);
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        progress.updateMessageText("Adding item ${i + 1} of ${lines.length}");
        final response = await http.post(
          Uri.parse(ApiUrl.SalesLineAPI),
          headers: _headers(),
          body: jsonEncode(<String, dynamic>{
            "Document_Type": "Order",
            "Document_No": docNo,
            "Description": line.item.Description ?? "",
            "Quantity": line.quantity,
            "Type": "Item",
            "No": line.no,
            "Location_Code": locationCode,
            "Unit_of_Measure_Code": line.unit,
          }),
        );
        if (response.statusCode != 201) {
          progress.hide();
          if (mounted) {
            _showPartialFailure(
              docNo: docNo,
              failedItem: line.item.Description ?? line.no,
              remaining: lines.length - i,
              message: _serverMessage(response),
            );
          }
          return;
        }
        _remove(line);
      }

      _openDocNo = null;
      _openDocCustomerNo = null;
      progress.updateMessageText("Recording visit");
      final visitProblem = await _postVisitation(customer);
      progress.hide();
      if (mounted) {
        await _showSuccess(docNo, customer, visitProblem: visitProblem);
      }
    } catch (_) {
      progress.hide();
      if (mounted) {
        helper.alertDialogTitle('${Helper.errorMessageOops}',
            "Check your internet connection and try again.", context);
      }
    }
  }

  /// Records a "Visitation and Sales" visit for the customer. Returns why it
  /// couldn't be saved, or null when it was.
  Future<String?> _postVisitation(customerModel customer) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return "Location is turned off on this phone.";
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return "Location permission was not given.";
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 20),
      );
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      final response = await http.post(
        Uri.parse(ApiUrl.VisitationApi),
        headers: _headers(),
        body: jsonEncode(<String, dynamic>{
          "CustomerID": customer.No.toString(),
          "Date": "${now.year}-${now.month}-${now.day}",
          "UserID": prefs.getString('User_Name') ?? '',
          "Longitute": position.longitude,
          "Latitude": position.latitude,
          "Visitation_Type": "Visitation and Sales",
          "Time": DateFormat('HH:mm:ss').format(now),
        }),
      );
      return response.statusCode == 201 ? null : _serverMessage(response);
    } on TimeoutException {
      return "Couldn't get your location in time.";
    } catch (_) {
      return "Couldn't reach the server.";
    }
  }

  void _showPartialFailure({
    required String docNo,
    required String failedItem,
    required int remaining,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.error_outline_rounded,
            color: AppColors.warning, size: 40),
        title: const Text("Order not complete"),
        content: Text(
          "Order $docNo was created, but \"$failedItem\" couldn't be added:\n\n"
          "$message\n\n"
          "$remaining item${remaining == 1 ? ' is' : 's are'} still in the cart. "
          "Fix the problem and check out again with the same customer to "
          "add ${remaining == 1 ? 'it' : 'them'} to order $docNo.",
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _showSuccess(
    String docNo,
    customerModel customer, {
    String? visitProblem,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.success, size: 36),
        ),
        title: const Text("Order placed"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Order $docNo",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayValue(customer.Name),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: (visitProblem == null
                        ? AppColors.success
                        : AppColors.warning)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    visitProblem == null
                        ? Icons.location_on_rounded
                        : Icons.location_off_rounded,
                    size: 18,
                    color: visitProblem == null
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      visitProblem == null
                          ? "Visit recorded"
                          : "Visit not recorded: $visitProblem",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: visitProblem == null
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: const Text("Done"),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- UI

  Future<void> _pickUnit(ItemCartLine line) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                "Unit of measure",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                displayValue(line.item.Description),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textMuted),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                children: [
                  for (final code in line.units)
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      selected: line.unit == code,
                      selectedTileColor: AppColors.primarySoft,
                      leading: Icon(
                        line.unit == code
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color: line.unit == code
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      title: Text(code),
                      onTap: () => Navigator.pop(sheetContext, code),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (picked != null) cart.setUnit(line, picked);
  }

  Widget _buildUnitSelector(ItemCartLine line) {
    if (line.unitsLoading) {
      return const Row(
        children: [
          SizedBox(width: 14, height: 14, child: AppLoader(strokeWidth: 2)),
          SizedBox(width: 8),
          Text(
            "Loading units…",
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      );
    }

    if (line.unitsFailed) {
      return Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.danger),
          const SizedBox(width: 6),
          const Flexible(
            child: Text(
              "Units didn't load",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => cart.loadUnits(line),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text("Retry"),
          ),
        ],
      );
    }

    if (line.units.isEmpty) {
      return const Text(
        "No units set up",
        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
      );
    }

    if (line.units.length <= _maxInlineUnits) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final code in line.units) ...[
              UnitChip(
                label: code,
                selected: line.unit == code,
                warn: line.unit == null,
                onTap: () => cart.setUnit(line, code),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      );
    }

    final hasValue = line.unit != null;
    final accent = hasValue ? AppColors.primary : AppColors.warning;
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: hasValue ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: accent),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _pickUnit(line),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    hasValue
                        ? line.unit!.toUpperCase()
                        : "Unit (${line.units.length})",
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

  Widget _buildQuantityStepper(ItemCartLine line) {
    final controller = _qtyController(line);
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
            onTap: line.quantity > 1 ? () => _changeQuantity(line, -1) : null,
          ),
          SizedBox(
            width: 42,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 1) {
                  cart.setQuantity(line, parsed);
                }
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                controller.text = '${line.quantity}';
              },
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              decoration: const InputDecoration(
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
            onTap: () => _changeQuantity(line, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildLine(ItemCartLine line) {
    return Dismissible(
      key: ObjectKey(line),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _remove(line),
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
                        displayValue(line.item.Description),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        displayValue(line.item.No),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                InkResponse(
                  onTap: () => _remove(line),
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
                Expanded(child: _buildUnitSelector(line)),
                const SizedBox(width: 10),
                _buildQuantityStepper(line),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final missing = cart.missingUnits;
    final units = cart.totalUnits;
    final items = cart.itemCount;
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
                        "$units unit${units == 1 ? '' : 's'}",
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
                    "$items item${items == 1 ? '' : 's'}",
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 15),
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
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_checkout_rounded, size: 22),
                      SizedBox(width: 10),
                      Text("Checkout"),
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
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        final lines = cart.lines;
        return Scaffold(
          appBar: AppBar(
            title: const Text("Cart"),
            actions: [
              if (lines.isNotEmpty)
                TextButton(
                  onPressed: _confirmClear,
                  child: const Text("Clear"),
                ),
              const SizedBox(width: 6),
            ],
          ),
          body: lines.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.remove_shopping_cart_outlined,
                    title: "Your cart is empty",
                    message: "Add products from the Items page.",
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
                            "${lines.length}",
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
                              color: AppColors.textMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (final line in lines) _buildLine(line),
                  ],
                ),
          bottomNavigationBar: lines.isEmpty ? null : _buildSummaryBar(),
        );
      },
    );
  }
}

/// Searchable customer list shown at checkout. Pops with the chosen customer.
class CustomerPickerDialog extends StatefulWidget {
  const CustomerPickerDialog({
    super.key,
    required this.responsibilityCenter,
    required this.itemCount,
    required this.totalUnits,
    this.initialCustomerNo,
  });

  final String responsibilityCenter;
  final String? initialCustomerNo;
  final int itemCount;
  final int totalUnits;

  @override
  State<CustomerPickerDialog> createState() => _CustomerPickerDialogState();
}

class _CustomerPickerDialogState extends State<CustomerPickerDialog> {
  final TextEditingController _search = TextEditingController();
  List<customerModel> _customers = [];
  customerModel? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse(ApiUrl.customerAPI + widget.responsibilityCenter + "'"),
        headers: _headers(),
      );
      if (!mounted) return;
      if (response.statusCode != 200) {
        setState(() {
          _loading = false;
          _error = _serverMessage(response);
        });
        return;
      }
      final rows = jsonDecode(response.body)["value"] as List;
      final customers = rows.map((c) => customerModel.fromJson(c)).toList()
        ..sort((a, b) => (a.Name ?? '')
            .toLowerCase()
            .compareTo((b.Name ?? '').toLowerCase()));
      setState(() {
        _customers = customers;
        _loading = false;
        if (widget.initialCustomerNo != null) {
          for (final c in customers) {
            if (c.No == widget.initialCustomerNo) _selected = c;
          }
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "Check your internet connection and try again.";
      });
    }
  }

  bool _isBlocked(customerModel c) => c.Blocked?.trim().toLowerCase() == 'all';

  List<customerModel> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _customers;
    return _customers
        .where((c) =>
            (c.Name ?? '').toLowerCase().contains(q) ||
            (c.No ?? '').toLowerCase().contains(q) ||
            (c.Phone_No ?? '').toLowerCase().contains(q))
        .toList();
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: AppLoader()),
      );
    }
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: "Couldn't load customers",
        message: _error,
        action: OutlinedButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text("Try again"),
        ),
      );
    }
    final customers = _filtered;
    if (customers.isEmpty) {
      return EmptyState(
        icon: Icons.person_search_outlined,
        title: _customers.isEmpty ? "No customers yet" : "No matching customers",
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        final blocked = _isBlocked(c);
        final selected = identical(c, _selected);
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: selected ? AppColors.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: blocked ? null : () => setState(() => _selected = c),
              child: Opacity(
                opacity: blocked ? 0.5 : 1,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      InitialsAvatar(name: c.Name, size: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayValue(c.Name),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              blocked
                                  ? "${displayValue(c.No)} · Blocked"
                                  : [
                                      displayValue(c.No),
                                      if (displayValue(c.Phone_No,
                                              fallback: '')
                                          .isNotEmpty)
                                        displayValue(c.Phone_No),
                                    ].join(" · "),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: blocked
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                        color:
                            selected ? AppColors.primary : AppColors.border,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Choose customer",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${widget.itemCount} item${widget.itemCount == 1 ? '' : 's'} · "
                          "${widget.totalUnits} unit${widget.totalUnits == 1 ? '' : 's'}",
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: "Close",
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search name, number or phone",
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => setState(_search.clear),
                        ),
                ),
              ),
            ),
            Flexible(child: _buildBody()),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () => Navigator.pop(context, selected),
                  child: Text(
                    selected == null
                        ? "Select a customer"
                        : "Place order for ${displayValue(selected.Name)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

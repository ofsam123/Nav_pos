import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/scanQr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';

import 'API.dart';
import 'ReturnOrderLogic.dart';
import 'Staticticsdetail.dart/TotalItemRecieved.dart';
import 'Staticticsdetail.dart/TotalItemsSold.dart';
import 'Staticticsdetail.dart/myTransferOrderDetails.dart';
import 'Staticticsdetail.dart/postedSales.dart';
import 'Staticticsdetail.dart/returnOrder.dart';
import 'Staticticsdetail.dart/salesOrderOpen.dart';
import 'Staticticsdetail.dart/transferToRecieve.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class statics extends StatefulWidget {
  const statics({super.key});

  @override
  State<statics> createState() => _staticsState();
}

class _staticsState extends State<statics> {
  final Helper helper = Helper();
  String UserName = "";
  String myTotalItemReceived = "";

  String myReurnOrder = "";
  String myOrderTransfer = "";
  String totalQuantity1 = "";
  String totalAmount1 = "";
  String poi = "";
  String salesoP = "";
  String traffer1 = "";
  String resCenter1 = "";

  String reQty = "";
  String reSold = "";
  String reItemsNo = "";
  String Noss = "";
  // List<String> matchingItemNos = [];
  // List<String> matchingItemNosItemNo = [];
  // List<int> subtractedQuantities = [];
  // List<String> qtyReceivedList = [];
  // List<String> qtySoldList = []; // Added to store Qty_Sold values

  @override
  void initState() {
    _getUserData();
    _getUserData1();
    // _refreshData();
    // _getResponsibiltyCenter();R

    Timer(Duration(seconds: 1), () {
      setState(() {
        _getResponsibiltyCenter();
        // QRecieve();
        // QSold();
        // _totalItemSold();
        // _PostedSalesInvoice();
        // _salesOrderOpen();
        // _transff();
        // _myTransaferOrders();
        // _myReturnOrders();
        // _myTotalItemRevied();
        // _refreshData();
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      // _getResponsibiltyCenter();
      // _getUserData();
      // _getResponsibiltyCenter();
      // QRecieve();
      // QSold();
      // _totalItemSold();
      // _PostedSalesInvoice();
      // _salesOrderOpen();
      // _transff();
      // _myTransaferOrders();
      // _myReturnOrders();
      // _myTotalItemRevied();
      //
      _checkLocationPermission();
      QRecieve();
      QSold();
      _totalItemSold();
      _PostedSalesInvoice();
      _salesOrderOpen();
      _transff();
      _myTransaferOrders();
      _myReturnOrders();
      _myTotalItemRevied();
    });
  }

  String userResCenter = "";
  String Location_Code1 = '';

  TextEditingController _controller = TextEditingController();
  TextEditingController _Amountcontroller = TextEditingController();
  var totalQuantityController = TextEditingController();
  var totalAmountController = TextEditingController();
  _getUserData() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    userResCenter = (prefs2.getString('Sales_Resp_Ctr_Filter') ?? '');

    // UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  _getUserData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  DateTime now = DateTime.now();
  int totalQuantityReceived = 0;
  int totalQuantitySold = 0;
  int difference = 0;

  //QTYRECIEVE
  Future<void> QRecieve() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantityReceivedAPI?" +
              "\$filter=Transfer_to_Code eq '$resCenter1' and Receipt_Date eq ${now.year}-${now.month}-${now.day}"),
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

      int total = 0;

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Received"].toString()) ?? 0;
        total += quantity;
      }

      setState(() {
        totalQuantityReceived = total;
        calculateDifference();
      });
    } else {
      helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> QSold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/QuantitySoldAPI?" +
              "\$filter=Location eq '$resCenter1' and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
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

      int total = 0;

      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Qty_Sold"].toString()) ?? 0;
        total += quantity;
      }

      setState(() {
        totalQuantitySold = total;
        calculateDifference();
      });
    } else {
      helper.flushBar2("Error", response.body, context);
      helper.alertDialogNoTitle(response.body, context);
    }
  }

  void calculateDifference() {
    setState(() {
      difference = totalQuantityReceived - totalQuantitySold;
    });
  }

  Widget _buildItemsLeftToday() {
    final itemsLeft = difference < 0 ? 0 : difference;
    final hasItemsLeft = itemsLeft > 0;

    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            itemsLeft.toString(),
            style: TextStyle(
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: hasItemsLeft ? AppColors.textDark : AppColors.danger,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            hasItemsLeft ? "ITEMS LEFT TODAY" : "NO ITEMS LEFT TODAY",
            style: TextStyle(
              fontSize: 9.5,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w700,
              color: hasItemsLeft ? AppColors.textDark : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denies location access.
        // You can show a dialog or message asking the user to enable location access in settings.
      }
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  Widget _statRow(Widget left, Widget right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 14),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 18, 24),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF8EBBF5),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initialsOf(UserName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
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
                      _greeting,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        UserName.toString(),
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildItemsLeftToday(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionLabel("My Day"),
                  _statRow(
                    StatCard(
                      icon: Icons.shopping_cart_rounded,
                      color: AppColors.success,
                      value: totalQuantity1,
                      label: "Items Sold",
                      onTap: () => _open(totalItemsSold(
                        resCenter: resCenter1.toString(),
                      )),
                    ),
                    StatCard(
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.primaryLight,
                      value: myTotalItemReceived,
                      label: "Items Received",
                      onTap: () => _open(totalItemsRevived(
                        responsibilityCenter: resCenter1.toString(),
                      )),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _statRow(
                    StatCard(
                      icon: Icons.local_shipping_outlined,
                      color: AppColors.warning,
                      value: totalAmount1,
                      label: "Amount Sold",
                      onTap: () => _open(totalItemsSold(
                        resCenter: resCenter1.toString(),
                      )),
                    ),
                    StatCard(
                      icon: Icons.receipt_long_outlined,
                      color: AppColors.purple,
                      value: salesoP,
                      label: "Open Orders",
                      onTap: () => _open(salesOrder(
                        resCenter: resCenter1.toString(),
                      )),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const SectionLabel("Transfers"),
                  NavRowCard(
                    icon: Icons.download_rounded,
                    color: AppColors.primaryLight,
                    title: "Transfer to Receive",
                    value: traffer1,
                    onTap: () => _open(TransferToRecieve(
                      responsCenter: resCenter1.toString(),
                    )),
                  ),
                  NavRowCard(
                    icon: Icons.undo_rounded,
                    color: AppColors.purple,
                    title: "Return Transfers",
                    value: difference.toString(),
                    onTap: () => _open(ReturnOrderLogic(
                      rc: resCenter1.toString(),
                    )),
                  ),
                  const SizedBox(height: 10),
                  const SectionLabel("Sales"),
                  NavRowCard(
                    icon: Icons.description_outlined,
                    color: AppColors.primary,
                    title: "Posted Sales Invoices",
                    value: poi,
                    onTap: () => _open(PostedSales(
                      responsibilityCenter: resCenter1.toString(),
                    )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getResponsibiltyCenter() async {
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Loading ...",
    );
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ResponsibilityCenterAPI?" +
              "\$filter=User_ID eq '$UserName" +
              "'"),
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
      String User_ID_2 = responseJson["value"][0]["User_ID"].toString();

      String userResCenter =
          responseJson["value"][0]["Sales_Resp_Ctr_Filter"].toString();
      String Code = responseJson["value"][0]["Code"].toString();
      String Location_Code =
          responseJson["value"][0]["Location_Code"].toString();

      // progressDialog.hide();
      SharedPreferences prefs2 = await SharedPreferences.getInstance();
      // prefs.setString('User_ID_2', User_ID_2);
      prefs2.setString('userResCenter', userResCenter);
      prefs2.setString('Code', Code);
      prefs2.setString('Location_Code', Location_Code);
      // helper.flushBar2('Success', userResCenter, context);

      setState(() {
        resCenter1 = userResCenter.toString();
        _refreshData();
        Location_Code1 = Location_Code.toString();
      });
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> _totalItemSold() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    // AppLoadingDialog progressDialog =
    //     AppLoadingDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "Loading ...",
    // );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvLineAPI?" +
              "\$filter=Location_Code eq " +
              "\'" +
              "$resCenter1" +
              "\'" +
              " and Posting_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    // progressDialog.hide();

    if (response.statusCode == 200) {
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      // List to store all quantities
      List<int> quantities = [];
      List<double> Amount = [];

      // Loop through the items and accumulate quantities
      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Quantity"].toString()) ?? 0;
        quantities.add(quantity);
      }
      for (var item in responseJson["value"]) {
        double Amounts =
            double.tryParse(item["Amount_Including_VAT"].toString()) ?? 0;
        Amount.add(Amounts);
      }

      // Calculate the total quantity
      int totalQuantity = quantities.fold(0, (sum, quantity) => sum + quantity);
      double totalAmount = Amount.fold(0.0, (sum, Amounts) => sum + Amounts);
      // helper.alertDialogNoTitle(
      //     "Total Quantity: $totalQuantity" + " \n" + "$totalAmount", context);
      setState(() {
        totalAmount1 = totalAmount.toString();
        totalQuantity1 = totalQuantity.toString();
        // _Amountcontroller = totalAmount as TextEditingController;
        // _controller = totalQuantityController;
      });

      // progressDialog.hide();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('Quantity', totalQuantity);
      prefs.setInt('Amount_Including_VAT', totalAmount as int);
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  Future<void> _PostedSalesInvoice() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/SalesInvHeaderAPI?" +
              "\$filter=Responsibility_Center eq " +
              "\'" +
              "$resCenter1" +
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
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        poi = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _salesOrderOpen() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/OSalesHeaderAPI?" +
              "\$filter=Responsibility_Center eq '$resCenter1' and Document_Type eq 'Order' and Status eq 'Open' and Document_Date eq ${now.year}-${now.month}-${now.day}"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        salesoP = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _transff() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '$resCenter1' and Completely_Shipped eq true and Shipment_Date eq ${now.year}-${now.month}-${now.day} and POS_Status eq 'Open'"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        traffer1 = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myTransaferOrders() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_to_Code eq '$resCenter1' and Completely_Shipped eq false"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        myOrderTransfer = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myReturnOrders() async {
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/TransferHeaderAPI?" +
              "\$filter=Posting_Date eq ${now.year}-${now.month}-${now.day} and Transfer_from_Code eq '$resCenter1' and Completely_Shipped eq false"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // Handle errors here
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // If the status code is 200, get the number of items in the list
      int numberOfItems = responseJson["value"].length;
      print("Number of Items: $numberOfItems");

      setState(() {
        myReurnOrder = numberOfItems.toString();
      });

      // You can use the numberOfItems variable as needed
      // For example, you can store it in SharedPreferences or display it in your UI.
    } else {
      // Handle the case where the status code is not 200
      helper.flushBar2("Error", 'Try again', context);
    }
  }

  Future<void> _myTotalItemRevied() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String Location_Code = (prefs.getString('Location_Code') ?? '');
    // AppLoadingDialog progressDialog =
    //     AppLoadingDialog(context: context, barrierDimisable: true);
    // progressDialog.show(
    //   message: "Loading ...",
    // );

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ItemLedgerEntryAPI?" +
              "\$filter=Location_Code eq '$resCenter1' and Posting_Date eq ${now.year}-${now.month}-${now.day} and Quantity gt 0 and Entry_Type eq 'Transfer'"),
      headers: {
        'Content': 'application/x-www-form-urlencoded',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$basicAuth',
        "Access-Control-Allow-Origin": "*",
      },
    ).catchError((err) {
      // progressDialog.hide();
      helper.alertDialogTitle('${Helper.errorMessageOops}',
          '${Helper.errorMessageSomethingWentWrong}', context);
    });

    // progressDialog.hide();

    if (response.statusCode == 200) {
      // progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      // List to store all quantities
      List<int> quantities = [];
      List<double> Amount = [];

      // Loop through the items and accumulate quantities
      for (var item in responseJson["value"]) {
        int quantity = int.tryParse(item["Quantity"].toString()) ?? 0;
        quantities.add(quantity);
      }

      // Calculate the total quantity
      int totalQuantity = quantities.fold(0, (sum, quantity) => sum + quantity);

      // helper.alertDialogNoTitle(
      //     "Total Quantity: $totalQuantity" + " \n" + "$totalAmount", context);
      setState(() {
        myTotalItemReceived = totalQuantity.toString();
        // _Amountcontroller = totalAmount as TextEditingController;
        // _controller = totalQuantityController;
      });

      // progressDialog.hide();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('Quantity', totalQuantity);
    } else {
      // progressDialog.hide();
      helper.flushBar2("Error", 'Try again', context);
      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  String matchingItemNo = "";

  void compareAndDisplayAppBarValue() {
    if (reItemsNo.isNotEmpty && Noss.isNotEmpty) {
      List<String> itemsNoList = reItemsNo.split(', ');
      List<String> nosList = Noss.split(', ');

      for (String itemNo in itemsNoList) {
        if (nosList.contains(itemNo)) {
          setState(() {
            matchingItemNo = itemNo;
          });
          break;
        }
      }
    }
  }
}

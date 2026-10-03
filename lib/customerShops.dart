import 'dart:async';
import 'dart:convert';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/bottomNavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API.dart';
import 'Models/customerModel.dart';
import 'createCustomer.dart';
import 'customerProfile.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class customerShopsPage extends StatefulWidget {
  customerShopsPage({required this.Id, required this.responsC});

  String? Id;
  String? responsC;

  @override
  State<customerShopsPage> createState() => _customerShopsPageState();
}

class _customerShopsPageState extends State<customerShopsPage> {
  final Helper helper = new Helper();
  late Future<List<customerModel>> _func;
  final TextEditingController _searchController = TextEditingController();
  List<customerModel> _customerList = [];
  List<customerModel> _filteredCustomerList = [];

  @override
  void initState() {
    _getUserData();
    _func = _getItems1();
    Timer(Duration(seconds: 1), () {
      setState(() {
        _func = _getItems1();
        _filteredCustomerList =
            _customerList; // Initialize filtered list with all customers
      });
    });
    super.initState();
  }

  String? token;
  String? userTypeId;
  String userResCenter = "";
  String Code = "";
  String? Location_Code;

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs2 = await SharedPreferences.getInstance();
    // userResCenter = (prefs.getString("Sales_Resp_Ctr_Filter") ?? '');

    Code = (prefs2.getString('Code') ?? '');

    // Location_Code = (prefs.getString('Location_Code') ?? '');

    userResCenter = (prefs2.getString('Sales_Resp_Ctr_Filter') ?? '');
    Location_Code = (prefs2.getString('Location_Code') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _getItems1();
    });
  }

  void _searchPressed(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomerList = _customerList;
      } else {
        final q = query.toLowerCase();
        _filteredCustomerList = _customerList
            .where((customer) =>
                (customer.Name ?? '').toLowerCase().contains(q) ||
                (customer.No ?? '').toLowerCase().contains(q) ||
                (customer.Phone_No ?? '').toLowerCase().contains(q))
            .toList();
      }
    });
  }

  Future<bool> _onBackPressed() {
    // Handle the back button press here
    // You can navigate back to the login page or perform any other action
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyNevBar(), // Replace with your login page widget
      ),
    );
    return Future.value(false); // Prevent the app from quitting
  }

  void _openProfile(customerModel customer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => customerProfile(
          customerId: customer.No.toString(),
          balance: '',
          balanceDue: '',
          blocked: customer.Blocked.toString(),
          email: customer.E_Mail.toString(),
          homePage: customer.Home_Page.toString(),
          name: customer.Name.toString(),
          no: customer.No.toString(),
          phoneNumber: customer.Phone_No.toString(),
          picture: customer.Picture.toString(),
          primaryContacNo: customer.Primary_Contact_No.toString(),
          responsibilityCenter: customer.Responsibility_Center.toString(),
          salespersonCode: customer.Salesperson_Code.toString(),
          latitude: customer.Latitude,
          longitude: customer.Longitude,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.softShadow,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _searchPressed,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Search name, number or phone',
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(Icons.search_rounded, size: 26),
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    _searchPressed('');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final count = _filteredCustomerList.length;
    final center = displayValue(widget.responsC, fallback: '');
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 20, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: "Back",
              onPressed: _onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textDark),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Customers",
                    style: TextStyle(
                      fontSize: 36,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    center.isEmpty
                        ? "$count customers"
                        : "$count customers  •  $center",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerTile(customerModel customer) {
    final phone = displayValue(customer.Phone_No, fallback: '');
    return AppCard(
      onTap: () => _openProfile(customer),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          InitialsAvatar(name: customer.Name, size: 56),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayValue(customer.Name),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phone.isEmpty
                      ? customer.No.toString()
                      : "${customer.No}  •  $phone",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 28),
        ],
      ),
    );
  }

  Widget _scrollableMessage(Widget child) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [const SizedBox(height: 40), child],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          body: Column(
            children: [
              FutureBuilder(
                future: _func,
                builder: (context, _) => _buildHeader(),
              ),
              _buildSearchBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: FutureBuilder(
                    future: _func,
                    builder: (context, data) {
                      if (data.hasError) {
                        return _scrollableMessage(
                          EmptyState(
                            icon: Icons.person_search_rounded,
                            title: "Customer Not Found",
                            message:
                                "The customer with ID ${widget.Id} cannot be found / is not assined to your Account.",
                            action: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("OK"),
                            ),
                          ),
                        );
                      } else if (data.hasData) {
                        if (_filteredCustomerList.isEmpty) {
                          return _scrollableMessage(
                            EmptyState(
                              icon: Icons.storefront_rounded,
                              title: _searchController.text.isEmpty
                                  ? "No customers yet"
                                  : "No matching customers",
                              message: _searchController.text.isEmpty
                                  ? "Customers assigned to you will appear here."
                                  : "Try a different name, number or phone.",
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(20, 2, 20, 100),
                          itemCount: _filteredCustomerList.length,
                          itemBuilder: (context, index) =>
                              _buildCustomerTile(_filteredCustomerList[index]),
                        );
                      } else {
                        return _scrollableMessage(
                          const Column(
                            children: [
                              AppLoader(),
                              SizedBox(height: 14),
                              Text(
                                "Loading customers…",
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RegisterCustomerPage(
                            responsC: widget.responsC.toString(),
                          )));
            },
            icon: const Icon(Icons.add_rounded, size: 28),
            label: const Text(
              "New customer",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ));
  }

  Future<List<customerModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');
    String Location_Code = (prefs.getString('Location_Code') ?? '');

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(ApiUrl.customerAPI + widget.responsC.toString() + "'"),
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
      List responseList = json.decode(response.body)["value"];
      _customerList =
          responseList.map((job) => customerModel.fromJson(job)).toList();
      _filteredCustomerList = List.from(_customerList);

      if (widget.Id != null && widget.Id!.isNotEmpty) {
        final foundCustomer = _customerList
            .firstWhere((customer) => customer.No.toString() == widget.Id);
        if (foundCustomer != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => customerProfile(
                customerId: foundCustomer.No.toString(),
                balance: '',
                balanceDue: '',
                blocked: foundCustomer.Blocked.toString(),
                email: foundCustomer.E_Mail.toString(),
                homePage: foundCustomer.Home_Page.toString(),
                name: foundCustomer.Name.toString(),
                no: foundCustomer.No.toString(),
                phoneNumber: foundCustomer.Phone_No.toString(),
                picture: foundCustomer.Picture.toString(),
                primaryContacNo: foundCustomer.Primary_Contact_No.toString(),
                responsibilityCenter:
                    foundCustomer.Responsibility_Center.toString(),
                salespersonCode: foundCustomer.Salesperson_Code.toString(),
                latitude: foundCustomer.Latitude,
                longitude: foundCustomer.Longitude,
              ),
            ),
          );
        }
      }

      return _customerList;
    } else {
      helper.alertDialogNoTitle('Try again', context);
      throw Exception('Failed to load post');
    }
  }
}

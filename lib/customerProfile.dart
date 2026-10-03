import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/testPage.dart';
import 'package:nav_pos/testp2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'API.dart';
import 'Cart.dart';
import 'Models/ItemsModel.dart';
import 'bottomNavigation.dart';
import 'customWidget.dart';
import 'editCustomer.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

class customerProfile extends StatefulWidget {
  customerProfile({
    required this.customerId,
    required this.name,
    required this.picture,
    required this.no,
    required this.balance,
    required this.balanceDue,
    required this.blocked,
    required this.salespersonCode,
    required this.responsibilityCenter,
    required this.primaryContacNo,
    required this.phoneNumber,
    required this.email,
    required this.homePage,
    this.latitude,
    this.longitude,
  });

  String? customerId;
  String? name;
  String? picture;
  String? no;
  String? balance;
  String? balanceDue;
  String? blocked;
  String? salespersonCode;
  String? responsibilityCenter;
  String? primaryContacNo;
  String? phoneNumber;
  String? email;
  String? homePage;
  double? latitude;
  double? longitude;

  @override
  State<customerProfile> createState() => _customerProfileState();
}

class _customerProfileState extends State<customerProfile> {
  late List<bool> selectedItems;

  List categories = [
    "All",
    "Today",
    "Other",
  ];

  DateTime now = DateTime.now();

  bool value = false;
  int selectedCategory = 0;
  var quantityController = TextEditingController(text: "1");
  final outcomeController = TextEditingController();
  final commentController = TextEditingController();

  late String? _name = widget.name;
  late String? _phoneNumber = widget.phoneNumber;
  late String? _email = widget.email;
  late String? _homePage = widget.homePage;
  late double? _latitude = widget.latitude;
  late double? _longitude = widget.longitude;
  final Helper helper = new Helper();
  String Docs_No = "";
  // late Future<List<itemsModel>> _func;
  String Longitude1 = "";
  String Latitude1 = "";
  List<bool> itemSelections = List.filled(100, false);

  late Future<List<itemsModel>> _func;
  late List<itemsModel> items; // Define the list here
  List<String> randomProductImageURLs = [
    "https://images.pexels.com/photos/2912108/pexels-photo-2912108.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/3490355/pexels-photo-3490355.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://m.media-amazon.com/images/I/61KqnxQdPCL.jpg",
    "https://thewoksoflife.com/wp-content/uploads/2019/09/shaoxing-wine.jpg"
        "https://img.freepik.com/free-photo/wine-bottle-glass-grapes-isolated-white_167946-36.jpg?size=626&ext=jpg&ga=GA1.2.1776209590.1686836153&semt=sph"
    // Add more image URLs here
  ];

  String currentTime = '';

  void getCurrentTime() {
    final now = DateTime.now();
    final formattedTime = DateFormat('HH:mm:ss').format(now);
    setState(() {
      currentTime = formattedTime;
    });
  }

  void openMaps() async {
    try {
      // Get the latitude and longitude as double values
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      final url =
          'https://www.google.com/maps/search/?api=1&query=$longitude,$latitude';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print("Error: $e");
      // Handle errors here
    }
  }

  @override
  void initState() {
    // _func = _getItems1();
    getCurrentLocation();
    getCurrentTime();
    _getUserData1();
    _func = _getItems1();
    Timer(Duration(seconds: 1), () {
      setState(() {
        // _getSalesHeader();
        // SearchController.text = widget.drugName!;
        // loadSharedPref();
      });
    });
    super.initState();
  }

  Future<void> _openEditCustomer() async {
    final updated = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => EditCustomerPage(
          customerId: widget.customerId.toString(),
          name: _name,
          phoneNumber: _phoneNumber,
          email: _email,
          homePage: _homePage,
          latitude: _latitude,
          longitude: _longitude,
        ),
      ),
    );
    if (updated == null || !mounted) return;

    setState(() {
      _name = updated["Name"];
      _phoneNumber = updated["Phone_No"];
      _email = updated["E_Mail"];
      _homePage = updated["Home_Page"];
      _latitude = updated["Latitude"];
      _longitude = updated["Longitude"];
    });
    helper.flushBar2("Success", "Customer updated", context);
  }

  @override
  void dispose() {
    outcomeController.dispose();
    commentController.dispose();
    super.dispose();
  }

  String UserName = "";
  _getUserData1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //userResCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');

    UserName = (prefs.getString('User_Name') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  int get _selectedCount => itemSelections.where((s) => s).length;

  Future<void> _callCustomer() async {
    final phone = displayValue(_phoneNumber, fallback: '');
    if (phone.isEmpty) {
      helper.flushBar2(
          "Warning", "No phone number saved for this customer", context);
      return;
    }
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _openCustomerLocation() async {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null || (lat == 0 && lng == 0)) {
      helper.flushBar2("Warning",
          "No location saved. Edit the customer to add one.", context);
      return;
    }
    await launchUrl(
      Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng'),
      mode: LaunchMode.externalApplication,
    );
  }

  void _openCart() {
    List<itemsModel> selectedItems = [];

    for (int i = 0; i < itemSelections.length; i++) {
      if (itemSelections[i]) {
        selectedItems.add(items[i]);
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectionPage(
          customerId: widget.customerId.toString(),
          name: _name.toString(),
          responsibilityCenter: widget.responsibilityCenter.toString(),
          salespersonCode: widget.salespersonCode.toString(),
          selectedItems: selectedItems,
        ),
      ),
    );
  }

  Widget _buildStatusPill() {
    final blocked = displayValue(widget.blocked, fallback: '');
    final isActive = blocked.isEmpty || blocked == '_blank_';
    return StatusPill(
      text: isActive ? "Active" : "Blocked: $blocked",
      color: isActive ? AppColors.success : AppColors.danger,
    );
  }

  Widget _buildHeroCard() {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Text(
              initialsOf(_name),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 34,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            displayValue(_name, fallback: 'Unnamed customer'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.no.toString(),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 17,
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusPill(),
            ],
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _showDetails,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 32),
              textStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            child: const Text("View details"),
          ),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickAction(
                icon: Icons.call_rounded,
                label: "Call",
                onTap: _callCustomer,
              ),
              _QuickAction(
                icon: Icons.location_on_rounded,
                label: "Map",
                onTap: _openCustomerLocation,
              ),
              _QuickAction(
                icon: Icons.groups_rounded,
                label: "Visit",
                onTap: () => _Alert(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              displayValue(value),
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.8,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            children: [
              const Text(
                "Customer details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const SmallCapsLabel("General info"),
              _infoRow("Balance (LCY)", "0.00"),
              _infoRow("Balance Due (LCY)", "0.00"),
              _infoRow("Credit Limit", "0.00"),
              _infoRow("Blocked", widget.blocked),
              _infoRow("Salesperson Code", widget.salespersonCode),
              _infoRow("Responsibility Center", widget.responsibilityCenter),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 14),
              const SmallCapsLabel("Contact"),
              _infoRow("Primary Contact Code", widget.primaryContacNo),
              _infoRow("Contact Name", _name),
              _infoRow("Phone Number", _phoneNumber),
              _infoRow("Email", _email),
              _infoRow("Fax No", null),
              _infoRow("Home Page", _homePage),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemTile(int index) {
    final selected = itemSelections[index];
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      onTap: () {
        setState(() {
          itemSelections[index] = !itemSelections[index];
        });
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.inputFill,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.liquor_rounded,
                color: Color(0xFF4B5563), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  items[index].Item_Description.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayValue(items[index].Item_No),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: selected ? AppColors.primary : const Color(0xFFC5CBD6),
                width: 1.5,
              ),
            ),
            child: selected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return FutureBuilder<List<itemsModel>>(
      future: _func,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: AppLoader()),
          );
        } else if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.cloud_off_rounded,
            title: "Failed to load data",
            message: "Check your connection and try again.",
            action: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _func = _getItems1();
                });
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Retry"),
            ),
          );
        } else if (snapshot.hasData) {
          items = _filterItems(snapshot.data!);
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: selectedCategory == 1
                  ? "No Item Received Today"
                  : "No items available",
            );
          }
          return ListView.builder(
            itemCount: items.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => _buildItemTile(index),
          );
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: AppLoader()),
          );
        }
      },
    );
  }

  Widget build(BuildContext context) {
    final selectedCount = _selectedCount;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer"),
        actions: [
          IconButton(
              tooltip: "Edit customer",
              onPressed: _openEditCustomer,
              icon: const Icon(Icons.edit_outlined, size: 26)),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          _buildHeroCard(),
          const SizedBox(height: 18),
          SegmentedTabs(
            labels: [for (final c in categories) c.toString()],
            selectedIndex: selectedCategory,
            onChanged: (index) {
              setState(() {
                selectedCategory = index;
                itemSelections = List.filled(100, false);
              });
            },
          ),
          const SizedBox(height: 16),
          _buildItemsList(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            height: 60,
            child: ElevatedButton.icon(
              onPressed: _openCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.shopping_cart_outlined, size: 28),
              label: Text(selectedCount > 0
                  ? "View Cart ($selectedCount)"
                  : "View Cart"),
            ),
          ),
        ),
      ),
    );
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
        "Sell_to_Customer_Name": _name.toString(),
        "Salesperson_Code": widget.salespersonCode.toString(),
        "Responsibility_Center": widget.responsibilityCenter.toString(),
        "Document_Type": "Order",
        "Posting_Date": "${now.year}-${now.month}-${now.day}",
        "Prices_Including_VAT": true // Set it as a boolean here
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
        Docs_No = responseJson["No"].toString();
      });

      // String role1 = responseJson["roles"].toString();
      // String active      = responseJson["active"] .toString();
      // String token = responseJson["token"].toString();
      progressDialog.hide();

      // helper.flushBar2("Success", " Successful", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }

  bool _isReceivedToday(itemsModel item) {
    final postingDate = DateTime.tryParse(item.Posting_Date ?? '');
    final today = DateTime.now();
    return postingDate != null &&
        postingDate.year == today.year &&
        postingDate.month == today.month &&
        postingDate.day == today.day;
  }

  List<itemsModel> _filterItems(List<itemsModel> entries) {
    final todayItemNos =
        entries.where(_isReceivedToday).map((e) => e.Item_No).toSet();

    Iterable<itemsModel> matching = entries;
    if (selectedCategory == 1) {
      matching = entries.where(_isReceivedToday);
    } else if (selectedCategory == 2) {
      matching = entries.where((e) => !todayItemNos.contains(e.Item_No));
    }

    final seenItemNos = <String?>{};
    return matching.where((e) => seenItemNos.add(e.Item_No)).toList();
  }

  Future<List<itemsModel>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Docs_No = (prefs.getString('Docs_No') ?? ''); // Update Docs_No here

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/ItemLedgerEntryAPI?" +
              "\$filter=Location_Code eq '${widget.responsibilityCenter.toString()}' and Quantity gt 0 and Entry_Type eq 'Transfer'"),
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

      return responseList.map((job) => itemsModel.fromJson(job)).toList();
    } else {
      helper.alertDialogNoTitle(response.body, context);
      throw Exception('Failed to load post');
    }
  }

  Future<void> _postVisitation({
    String outcome = "",
    String comment = "",
  }) async {
    try {
      // Get the latitude and longitude as double values
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      AppLoadingDialog progressDialog =
          AppLoadingDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Saving visit ...",
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String User_Name = (prefs.getString('User_Name') ?? '');
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
          // "CustomerID": widget.customerId.toString(),

          // "Date":
          //     "${now.year}-${now.month}-${now.day}", // date should be from the dependecy
          // "UserID": UserName.toString(),
          // "Longitute": longitude, //should be from the actual map
          // "Latitude": latitude,
          // "Visitation_Type": "Visitation and Sales",
          // "Time": currentTime, // date should be from the dependecy
          "CustomerID": widget.customerId.toString(),
          "Date": "${now.year}-${now.month}-${now.day}",
          "UserID": UserName.toString(),
          "Longitute": longitude,
          "Latitude": latitude,
          "Visitation_Type": "Visitation",
          "Time": currentTime,
          "Comment": comment,
          "Outcome_of_the_visit": outcome,
        }),
      )
          .catchError((err) {
        progressDialog.hide();
        // helper.alertDialogTitle('${Helper.errorMessageOops}',
        //     '${Helper.errorMessageSomethingWentWrong}', context);
      });

      progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        progressDialog.hide();

        helper.flushBar2("Success", "Visitation Added", context);
        // Navigator.pop(context);
      } else {
        progressDialog.hide();
        helper.flushBar2("Error", "Retry Again Later", context);
      }
    } catch (e) {
      print("Error: $e");
      // Handle errors here
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      // Call _postVisitation with latitude and longitude
      // _postVisitation(latitude, longitude);

      // Display the latitude and longitude (you can use a dialog or any other widget)
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text("Current Location"),
      //       content: Text("Latitude: $latitude\nLongitude: $longitude"),
      //       actions: [
      //         TextButton(
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //           },
      //           child: Text("Close"),
      //         ),
      //       ],
      //     );
      //   },
      // );
    } catch (e) {
      print("Error: $e");
      // Handle errors here
    }
  }

  _Alert(BuildContext context) {
    outcomeController.clear();
    commentController.clear();
    final locationFuture = Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    locationFuture.ignore();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Record onsite visit",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${displayValue(_name, fallback: '')}  •  ${widget.no}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LocationBanner(future: locationFuture),
                  const SizedBox(height: 22),
                  const Text(
                    "Outcome of the visit",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: outcomeController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _sheetFieldDecoration(
                      hint: "What was the outcome of this visit?",
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _sheetFieldDecoration(
                      hint: "Add a note about this visit…",
                      label: "Comment",
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textMuted,
                            minimumSize: const Size(0, 56),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: () {
                              _postVisitation(
                                outcome: outcomeController.text.trim(),
                                comment: commentController.text.trim(),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text("Submit visit"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  InputDecoration _sheetFieldDecoration({required String hint, String? label}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
    );
    return InputDecoration(
      hintText: hint,
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      labelStyle: const TextStyle(
        color: AppColors.textDark,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.future});

  final Future<Position> future;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: future,
      builder: (context, snapshot) {
        final String text;
        final String? coords;
        if (snapshot.hasData) {
          text = "Location captured";
          coords =
              "${snapshot.data!.latitude.toStringAsFixed(4)}, ${snapshot.data!.longitude.toStringAsFixed(4)}";
        } else if (snapshot.hasError) {
          text = "Location unavailable — allow location access";
          coords = null;
        } else {
          text = "Capturing location…";
          coords = null;
        }
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                snapshot.hasError
                    ? Icons.location_off_rounded
                    : Icons.location_on_rounded,
                color: snapshot.hasError ? AppColors.danger : AppColors.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: text,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15.5,
                    ),
                    children: [
                      if (coords != null)
                        TextSpan(
                          text: "  •  $coords",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

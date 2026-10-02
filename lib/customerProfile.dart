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
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:url_launcher/url_launcher.dart';
import 'API.dart';
import 'Cart.dart';
import 'Models/ItemsModel.dart';
import 'bottomNavigation.dart';
import 'customWidget.dart';

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

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Customer Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _Alert(context);
              },
              icon: Icon(Icons.accessibility))
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                // color: Colors.black,
                height: 120,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/cp.jpg"))),
              ),
              // SizedBox(
              //   height: 10,
              // ),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 10, top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 200,
                      child: Text(
                        widget.name.toString().replaceAll("null", "Empty"),
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.w400),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Spacer(),
                    // Container(
                    //   height: 40,
                    //   width: 40,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       border: Border.all(width: 1.0, color: Colors.grey)),
                    //   child: IconButton(
                    //       onPressed: () {
                    //         openMaps();
                    //       },
                    //       icon: Icon(
                    //         Icons.location_pin,
                    //         color: Colors.black,
                    //         size: 25,
                    //       )),
                    // ),
                    SizedBox(
                      width: 7,
                    ),
                    // Container(
                    //   height: 40,
                    //   width: 40,
                    //   decoration: BoxDecoration(
                    //       borderRadius: BorderRadius.circular(10),
                    //       border: Border.all(width: 1.0, color: Colors.grey)),
                    //   child: IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Icons.history,
                    //         color: Colors.black,
                    //         size: 25,
                    //       )),
                    // )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Text(
                      widget.no.toString(),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 1,
              ),
              ExpansionTile(
                title: Text(
                  "General Info",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Balance(LCY):",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "0.00",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "balance Due(LCY):",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "0.00",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Credit Limit:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "0.00",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Blocked",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.blocked.toString(),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Salesperson Code:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.salespersonCode.toString(),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Responsibility Center",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.responsibilityCenter.toString(),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 1,
              ),
              ExpansionTile(
                title: Text(
                  "Contact",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Primary Contact Code:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.primaryContacNo
                              .toString()
                              .replaceAll("", "Empty"),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Contact Name:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.name.toString().replaceAll("null", "Empty"),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Phone Number:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.phoneNumber
                              .toString()
                              .replaceAll("null", "Empty"),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Email:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.email.toString().replaceAll("null", "Empty"),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Fax No:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "(blank)",
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: [
                        Text(
                          "Home Page:",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          widget.homePage
                              .toString()
                              .replaceAll("null", "Empty"),
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0),
                      child: Container(
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            ),
                        // width: 280,
                        height: 50,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: categories.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: ((context, index) => CategoryCard(
                                  bColor: index == selectedCategory
                                      ? Colors.black
                                      : Colors.white,
                                  onTap: () {
                                    setState(() {
                                      selectedCategory = index;
                                      itemSelections =
                                          List.filled(100, false);
                                    });
                                  },
                                  text: categories[index],
                                  textColor: selectedCategory == index
                                      ? Colors.white
                                      : Color(0xFF6F6F6F),
                                ))),
                      ),
                    ),
                    Spacer(),
                    // SizedBox(
                    //   width: 0,
                    // ),
                  ],
                ),
              ),

              if (selectedCategory == 0)
                ...{}
              else if (selectedCategory == 1) ...{
                // Padding(
                //   padding: EdgeInsets.only(bottom: 4),
                //   child: Container(
                //     height: 500,
                //     // child: DashboardTransactionHistory(),
                //   ),
                // ),
              },

              // SingleChildScrollView(
              //   child: Column(
              //     children: [
              //       Container(
              //         height: 20000,
              //         child: SelectionList(),
              //       ),
              //     ],
              //   ),
              // ),

              FutureBuilder<List<itemsModel>>(
                future: _func,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Oops!! 😔"),
                          Text("Failed to load data"),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _func = _getItems1();
                              });
                            },
                            child: Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    items = _filterItems(snapshot.data!);
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(selectedCategory == 1
                                ? "No Item Received Today"
                                : "No items available"),
                          ],
                        ),
                      );
                    }
                    // Initialize items here
                    return ListView.builder(
                      itemCount: items == null ? 0 : items.length,
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        int randomImageIndex =
                            Random().nextInt(randomProductImageURLs.length);
                        return ListTile(
                          leading: Container(
                            height: 120,
                            width: 100,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 240, 238, 238),
                              // image: DecorationImage(
                              //     colorFilter: ColorFilter.mode(
                              //       Color.fromARGB(255, 146, 144, 144)
                              //           .withOpacity(0.9),
                              //       BlendMode.modulate,
                              //     ),
                              //     image: NetworkImage(
                              //       randomProductImageURLs[randomImageIndex],
                              //     ),
                              //     fit: BoxFit.cover),
                              borderRadius: BorderRadius.circular(10),
                              // color: Color.fromARGB(101, 11, 117, 187)
                            ),
                            child: Center(
                              child: Container(
                                  height: 80,
                                  // child: Image.asset("assets/images/perfume.png"),
                                  child: Icon(
                                    Icons.shopify_outlined,
                                    color: Colors.grey,
                                  )),
                            ),
                          ),
                          title: Text(
                            items[index].Item_Description.toString(),
                          ),
                          trailing: Checkbox(
                            checkColor: Colors.blue,
                            activeColor: Colors.white,
                            value: itemSelections[index],
                            onChanged: (bool? value) {
                              setState(() {
                                itemSelections[index] = value ?? false;
                              });
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),

              SizedBox(
                height: 50,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.shopping_cart),
        onPressed: () async {
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
                // selectedItems.cast<itemsModel>(),
                // Docs_No.toString(),
                customerId: widget.customerId.toString(),
                name: widget.name.toString(),
                responsibilityCenter: widget.responsibilityCenter.toString(),
                salespersonCode: widget.salespersonCode.toString(),
                selectedItems: selectedItems,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _getSalesHeader() async {
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
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

      SimpleFontelicoProgressDialog progressDialog =
          SimpleFontelicoProgressDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Visitation Loading ...",
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
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            //title: Text("Do you want to logout ?"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Do you want to mark Onsite Visitation?"),
                  SizedBox(height: 16),
                  TextField(
                    controller: outcomeController,
                    decoration: InputDecoration(
                      labelText: "Outcome of the visit",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Comment",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              Container(
                height: 40,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                  onPressed: () {
                    _postVisitation(
                      outcome: outcomeController.text.trim(),
                      comment: commentController.text.trim(),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ),
            ],
          );
        });
  }
}

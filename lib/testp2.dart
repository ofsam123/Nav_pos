import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'API.dart';
import 'Models/ItemsModel.dart';
import 'bottomNavigation.dart';
import 'customerProfile.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cart Items"),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 5,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: selectedItems.length,
        itemBuilder: (context, index) {
          int randomImageIndex =
              Random().nextInt(randomProductImageURLs.length);
          return Column(
            children: [
              ListTile(
                leading: Container(
                  height: 130,
                  width: 70,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 238, 238),
                    // image: DecorationImage(
                    //     colorFilter: ColorFilter.mode(
                    //       Color.fromARGB(255, 146, 144, 144).withOpacity(0.9),
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
                title: Text("${selectedItems[index].Item_Description}"),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        removeItem(index);
                      },
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    DropdownButton(
                      hint: Text(
                        'Select U.O.M',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      items: dropdownItems[index].map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        setState(() {
                          selectedCodeMap[index] = newVal;
                        });
                      },
                      value: selectedCodeMap[index],
                    ),
                  ],
                ),
                trailing: Container(
                  width: 40,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: quantityControllers[index],
                    onChanged: (value1) {
                      setState(() {
                        // if(quantityController)
                      });
                    },
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "0",
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              Divider()
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // _postSalesLine();
          _getSalesHeader();
        },
        backgroundColor: Colors.black,
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        label: Text(
          'Check Out',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
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

      SimpleFontelicoProgressDialog progressDialog =
          SimpleFontelicoProgressDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Submiting ...",
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
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "UM ...",
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

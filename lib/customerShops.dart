import 'dart:async';
import 'dart:convert';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'API.dart';
import 'Models/customerModel.dart';
import 'createCustomer.dart';
import 'customerProfile.dart';

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
        _filteredCustomerList = _customerList
            .where((customer) =>
                customer.Name!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Customers",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 40,
              width: 170, // Adjust the width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.0, color: Colors.grey),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _searchPressed,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                FutureBuilder(
                  future: _func,
                  builder: (context, data) {
                    if (data.hasError) {
                      return Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Oops!! 😔"),
                          Text("Failed"),
                          AlertDialog(
                            title: Text("Customer Not Found"),
                            content: Text(
                                "The customer with ID ${widget.Id} cannot be found / is not assined to your Account."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          )
                        ],
                      ));
                    } else if (data.hasData) {
                      return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredCustomerList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => customerProfile(
                                        customerId: _filteredCustomerList[index]
                                            .No
                                            .toString(),
                                        balance: '',
                                        balanceDue: '',
                                        blocked: _filteredCustomerList[index]
                                            .Blocked
                                            .toString(),
                                        email: _filteredCustomerList[index]
                                            .E_Mail
                                            .toString(),
                                        homePage: _filteredCustomerList[index]
                                            .Home_Page
                                            .toString(),
                                        name: _filteredCustomerList[index]
                                            .Name
                                            .toString(),
                                        no: _filteredCustomerList[index]
                                            .No
                                            .toString(),
                                        phoneNumber:
                                            _filteredCustomerList[index]
                                                .Phone_No
                                                .toString(),
                                        picture: _filteredCustomerList[index]
                                            .Picture
                                            .toString(),
                                        primaryContacNo:
                                            _filteredCustomerList[index]
                                                .Primary_Contact_No
                                                .toString(),
                                        responsibilityCenter:
                                            _filteredCustomerList[index]
                                                .Responsibility_Center
                                                .toString(),
                                        salespersonCode:
                                            _filteredCustomerList[index]
                                                .Salesperson_Code
                                                .toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 70,
                                  child: Card(
                                    color: Colors.white,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8),
                                      child: Row(children: [
                                        Icon(
                                          Icons.store,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(
                                          width: 25,
                                        ),
                                        Text(
                                          _filteredCustomerList[index]
                                              .Name
                                              .toString(),
                                          style: TextStyle(fontSize: 19),
                                        ),
                                        Spacer(),
                                        Text(
                                          _filteredCustomerList[index]
                                              .No
                                              .toString(),
                                          style: TextStyle(fontSize: 15),
                                        )
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 60,
                            ),
                            Container(
                                height: 140,
                                child: Center(
                                  child: Column(
                                    children: [
                                      CircularProgressIndicator(),
                                      Text("Loading Please wait....")
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 60,
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RegisterCustomerPage(
                        responsC: widget.responsC.toString(),
                      )));
        },
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
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

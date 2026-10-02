import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'API.dart';
import 'Models/itemsModel2.dart';
import 'customWidget.dart';
import 'itemsDesscription.dart';

class dashboardPage extends StatefulWidget {
  const dashboardPage({Key? key}) : super(key: key);

  @override
  State<dashboardPage> createState() => _dashboardPageState();
}

class _dashboardPageState extends State<dashboardPage> {
  final TextEditingController _searchController = TextEditingController();

  final Helper helper = Helper();

  late Future<List<itemsModel2>> _func;
  List<String> randomProductImageURLs = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSs8ymzz6UoMQhZIyrw9yMiv0WC20UdLVzVAw&usqp=CAU"
        "https://images.pexels.com/photos/2912108/pexels-photo-2912108.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/3490355/pexels-photo-3490355.jpeg?auto=compress&cs=tinysrgb&w=1600",
    "https://m.media-amazon.com/images/I/61KqnxQdPCL.jpg",
    "https://img.freepik.com/free-photo/wine-bottle-glass-grapes-isolated-white_167946-36.jpg?size=626&ext=jpg&ga=GA1.2.1776209590.1686836153&semt=sph",
  ];

  @override
  void initState() {
    _func = _getItems1();

    Timer(Duration(seconds: 1), () {
      setState(() {});
    });
    super.initState();
  }

  String? token;
  String? userTypeId;

  List<itemsModel2> _items = [];
  List<itemsModel2> _filteredItems = [];

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    token = (prefs.getString('token') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _func = _getItems1();
    });
  }

  List categories = [
    // "All",
    // "Drinks",
    // "Cusmetics",
  ];

  int selectedCategory = 0;

  void _filterItems(String query) {
    setState(() {
      _filteredItems = _items.where((item) {
        final itemTitle = item.Description!.toLowerCase();
        return itemTitle.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        leading: Icon(Icons.workspaces_outlined),
        title: Column(
          children: [
            Text(
              "Discover",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              height: 40,
              width: 150, // Adjust the width as needed
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(width: 1.0, color: Colors.grey),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
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
        onRefresh: _refresh,
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 10),
                  child: Row(
                    children: [
                      Text(
                        "All Products",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
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
                                Text("Failed later"),
                              ],
                            ),
                          );
                        } else if (data.hasData) {
                          var items = _searchController.text.isNotEmpty
                              ? _filteredItems
                              : data.data as List<itemsModel2>;

                          return GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisExtent: getVerticalSize(220.00),
                              crossAxisCount: 3,
                              mainAxisSpacing: getHorizontalSize(00),
                              crossAxisSpacing: getHorizontalSize(11.00),
                            ),
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: items == null ? 0 : items.length,
                            itemBuilder: (context, index) {
                              int randomImageIndex = Random()
                                  .nextInt(randomProductImageURLs.length);

                              String description =
                                  items[index].Description.toString();
                              List<String> words = description.split(' ');
                              String firstThreeWords =
                                  words.take(2).take(3).join(' ');

                              return Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => itemDetails(
                                          Description: items[index]
                                              .Description
                                              .toString(),
                                          No: items[index].No.toString(),
                                          SerialNums: items[index]
                                              .Serial_Nos
                                              .toString(),
                                          basedUnit: items[index]
                                              .Base_Unit_of_Measure
                                              .toString(),
                                          description2: items[index]
                                              .Description_2
                                              .toString(),
                                          itemCatCode: items[index]
                                              .Item_Category_Code
                                              .toString(),
                                          itemTrackingCode: items[index]
                                              .Item_Tracking_Code
                                              .toString(),
                                          lotsNos:
                                              items[index].Lot_Nos.toString(),
                                          pricesVat: '',
                                          salesUnit: items[index]
                                              .Sales_Unit_of_Measure
                                              .toString(),
                                          type: items[index].Type.toString(),
                                          block:
                                              items[index].Blocked.toString(),
                                          image: randomProductImageURLs[
                                              randomImageIndex],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    height: 140,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 130,
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 236, 235, 235),
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                randomProductImageURLs[
                                                    randomImageIndex],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          child: Center(
                                            child: Container(
                                              height: 80,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Text(
                                            firstThreeWords,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 5.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                child: Text(
                                                  items[index].No.toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 140,
                                  child:
                                      Image.asset("assets/images/loading.gif"),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<itemsModel2>> _getItems1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.get(
      Uri.parse(ApiUrl.ItemAPI),
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
      _items = responseList.map((job) => itemsModel2.fromJson(job)).toList();
      return _items;
    } else {
      //  helper.alertDialogTitle('Try again', context);
      helper.alertDialogNoTitle('Try again', context);
      throw Exception('Failed to load post');
    }
  }
}

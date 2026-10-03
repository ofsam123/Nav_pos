import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:nav_pos/size_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'API.dart';
import 'Models/itemsModel2.dart';
import 'customWidget.dart';
import 'itemsDesscription.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';

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

  void _openItem(itemsModel2 item) {
    int randomImageIndex = Random().nextInt(randomProductImageURLs.length);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => itemDetails(
          Description: item.Description.toString(),
          No: item.No.toString(),
          SerialNums: item.Serial_Nos.toString(),
          basedUnit: item.Base_Unit_of_Measure.toString(),
          description2: item.Description_2.toString(),
          itemCatCode: item.Item_Category_Code.toString(),
          itemTrackingCode: item.Item_Tracking_Code.toString(),
          lotsNos: item.Lot_Nos.toString(),
          pricesVat: '',
          salesUnit: item.Sales_Unit_of_Measure.toString(),
          type: item.Type.toString(),
          block: item.Blocked.toString(),
          image: randomProductImageURLs[randomImageIndex],
        ),
      ),
    );
  }

  Widget _buildItemCard(itemsModel2 item) {
    return AppCard(
      onTap: () => _openItem(item),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.liquor_rounded,
                  size: 44, color: Color(0xFF9CA3AF)),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayValue(item.Description),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue(item.No),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: FutureBuilder(
                future: _func,
                builder: (context, data) {
                  final count = _searchController.text.isNotEmpty
                      ? _filteredItems.length
                      : _items.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Items",
                        style: TextStyle(
                          fontSize: 36,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.hasData ? "$count products" : "All products",
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.softShadow,
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search products',
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
                            _filterItems('');
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
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder(
                  future: _func,
                  builder: (context, data) {
                    if (data.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          const SizedBox(height: 40),
                          EmptyState(
                            icon: Icons.cloud_off_rounded,
                            title: "Failed to load products",
                            message: "Pull down to try again.",
                          ),
                        ],
                      );
                    } else if (data.hasData) {
                      var items = _searchController.text.isNotEmpty
                          ? _filteredItems
                          : data.data as List<itemsModel2>;
                      if (items.isEmpty) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 40),
                            EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: "No products found",
                            ),
                          ],
                        );
                      }
                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 2, 20, 24),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisExtent: 230,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) =>
                            _buildItemCard(items[index]),
                      );
                    } else {
                      return const Center(child: AppLoader());
                    }
                  },
                ),
              ),
            ),
          ],
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

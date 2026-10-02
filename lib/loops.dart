// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:nav_pos/testp2.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'API.dart';
// import 'Models/ItemsModel.dart';
// import 'apiHelper.dart';

// class Looptest extends StatefulWidget {
//   const Looptest({super.key});

//   @override
//   State<Looptest> createState() => _LooptestState();
// }

// class _LooptestState extends State<Looptest> {
//   bool value = false;
//   int selectedCategory = 0;
//   var quantityController = TextEditingController(text: "1");
//   final Helper helper = new Helper();
//   String Docs_No = "";
//   // late Future<List<itemsModel>> _func;

//   List<bool> itemSelections = List.filled(100, false);

//   late Future<List<itemsModel>> _func;
//   late List<itemsModel> items; // Define the list here

//   DateTime now = DateTime.now();

//   @override
//   void initState() {
//     // _func = _getItems1();
//     _func = _getItems1();
//     Timer(Duration(seconds: 1), () {
//       setState(() {
//         // _getSalesHeader();
//         // SearchController.text = widget.drugName!;
//         // loadSharedPref();
//       });
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         child: FutureBuilder<List<itemsModel>>(
//           future: _func,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             } else if (snapshot.hasError) {
//               return Center(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text("Oops!! 😔"),
//                     Text("Failed to load data"),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _func = _getItems1();
//                         });
//                       },
//                       child: Text("Retry"),
//                     ),
//                   ],
//                 ),
//               );
//             } else if (snapshot.hasData) {
//               items = snapshot.data!; // Initialize items here
//               return ListView.builder(
//                 itemCount: 200,
//                 physics: ClampingScrollPhysics(),
//                 shrinkWrap: true,
//                 scrollDirection: Axis.vertical,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     leading: Container(
//                       height: 120,
//                       width: 120,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 240, 238, 238),
//                         // image: DecorationImage(
//                         //     colorFilter: ColorFilter.mode(
//                         //       Color.fromARGB(
//                         //               255, 146, 144, 144)
//                         //           .withOpacity(0.9),
//                         //       BlendMode.modulate,
//                         //     ),
//                         //     image: NetworkImage(
//                         //       items[index]
//                         //           .banner
//                         //           .toString(),
//                         //     ),
//                         //     fit: BoxFit.cover),
//                         borderRadius: BorderRadius.circular(10),
//                         // color: Color.fromARGB(101, 11, 117, 187)
//                       ),
//                       child: Center(
//                         child: Container(
//                           height: 80,
//                           child: Image.asset("assets/images/perfume.png"),
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       items[index].Description.toString(),
//                     ),
//                     trailing: Checkbox(
//                       checkColor: Colors.blue,
//                       activeColor: Colors.white,
//                       value: itemSelections[index],
//                       onChanged: (bool? value) {
//                         setState(() {
//                           itemSelections[index] = value ?? false;
//                         });
//                       },
//                     ),
//                   );
//                 },
//               );
//             } else {
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//           },
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blue,
//         child: Icon(Icons.shopping_cart),
//         onPressed: () async {
//           List<itemsModel> selectedItems = [];

//           for (int i = 0; i < itemSelections.length; i++) {
//             if (itemSelections[i]) {
//               selectedItems.add(items[i]);
//             }
//           }

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SelectionPage(
//                   selectedItems.cast<itemsModel>(), Docs_No.toString()),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Future<List<itemsModel>> _getItems1() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     Docs_No = (prefs.getString('Docs_No') ?? ''); // Update Docs_No here

//     String basicAuth = 'Basic ' +
//         base64Encode(
//             utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
//     final response = await http.get(
//       Uri.parse(ApiUrl.ItemAPI),
//       headers: {
//         'Content': 'application/x-www-form-urlencoded',
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         'Authorization': '$basicAuth',
//         "Access-Control-Allow-Origin": "*",
//       },
//     ).catchError((err) {
//       helper.alertDialogTitle('${Helper.errorMessageOops}',
//           '${Helper.errorMessageSomethingWentWrong}', context);
//     });

//     if (response.statusCode == 200) {
//       final responseJson = jsonDecode(response.body);
//       String apiResponse = responseJson["value"].toString();
//       List responseList = json.decode(response.body)["value"];
//       return responseList.map((job) => itemsModel.fromJson(job)).toList();
//     } else {
//       helper.alertDialogNoTitle(response.body, context);
//       throw Exception('Failed to load post');
//     }
//   }
// }

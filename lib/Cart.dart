import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nav_pos/apiHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';

import 'API.dart';
import 'bottomNavigation.dart';

class Cart extends StatefulWidget {
  Cart({required this.Docs_No, required this.selectedItems});
  // final List<String> selectedItems;

  String? Docs_No;
  String? selectedItems;

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final Helper helper = new Helper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Items Cart" + widget.Docs_No.toString(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(width: 1.0, color: Colors.grey)),
                child: Center(child: Text("8"))),
          )
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: widget.selectedItems.toString().length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(widget.selectedItems.toString()[index]),
                    );
                  },
                ),

                //  ListView.builder(
                //     itemCount: 8,
                //     physics: ClampingScrollPhysics(),
                //     shrinkWrap: true,
                //     scrollDirection: Axis.vertical,
                //     itemBuilder: (context, index) {
                //       return Padding(
                //         padding: const EdgeInsets.all(2),
                //         child: GestureDetector(
                //           onTap: () {},
                // child: Container(
                //   decoration: BoxDecoration(
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   width: MediaQuery.of(context).size.width / 1.1,
                //   child: Padding(
                //     padding:
                //         const EdgeInsets.only(right: 10.0, top: 7),
                //     child: Row(
                //       children: [
                //         Container(
                //           height: 100,
                //           width: 140,
                //           decoration: BoxDecoration(
                //             color: const Color.fromARGB(
                //                 255, 240, 238, 238),
                //             // image: DecorationImage(
                //             //     colorFilter: ColorFilter.mode(
                //             //       Color.fromARGB(
                //             //               255, 146, 144, 144)
                //             //           .withOpacity(0.9),
                //             //       BlendMode.modulate,
                //             //     ),
                //             //     image: NetworkImage(
                //             //       items[index]
                //             //           .banner
                //             //           .toString(),
                //             //     ),
                //             //     fit: BoxFit.cover),
                //             borderRadius: BorderRadius.circular(10),
                //             // color: Color.fromARGB(101, 11, 117, 187)
                //           ),
                //           child: Center(
                //             child: Container(
                //               height: 80,
                //               child: Image.asset(
                //                   "assets/images/perfume.png"),
                //             ),
                //           ),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(
                //               left: 10.0, top: 10),
                //           child: Column(
                //             mainAxisAlignment:
                //                 MainAxisAlignment.center,
                //             crossAxisAlignment:
                //                 CrossAxisAlignment.center,
                //             children: [
                //               Text("Sauvignon",
                //                   style: TextStyle(
                //                       // fontWeight: FontWeight.bold,
                //                       fontSize: 16)),
                //               SizedBox(
                //                 height: 10,
                //               ),
                //               Row(
                //                 children: [
                //                   Text("GHS 200",
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: 14,
                //                           color: Colors.black))
                //                 ],
                //               ),
                //             ],
                //           ),
                //         ),
                //         Spacer(),
                //         Column(
                //           children: [
                //             Row(
                //               children: [
                //                 Container(
                //                   width: 40,
                //                   child: TextField(
                //                     onChanged: (value1) {
                //                       setState(() {
                //                         // if(quantityController)
                //                       });
                //                     },
                //                     // controller: quantityController,
                //                     textAlign: TextAlign.center,
                //                     decoration: InputDecoration(
                //                         hintText: "0",
                //                         border: UnderlineInputBorder(
                //                             borderSide: BorderSide(
                //                                 color:
                //                                     Colors.black))),
                //                   ),
                //                 ),
                //                 Padding(
                //                   padding:
                //                       const EdgeInsets.only(top: 0.0),
                //                   child: Text("QTY",
                //                       style: TextStyle(
                //                           color: Colors.grey,
                //                           fontWeight:
                //                               FontWeight.bold)),
                //                 ),
                //               ],
                //             ),
                //             Row(
                //               children: [
                //                 IconButton(
                //                     onPressed: () {},
                //                     icon: Icon(
                //                       Icons.delete_forever,
                //                       color: Colors.red,
                //                     )),
                //               ],
                //             ),
                //           ],
                //         )
                //       ],
                //     ),
                //   ),
                // ),
                //         ),
                //       );
                //     }),
              ),
              SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _postSalesLine();
        },
        backgroundColor: Colors.black,
        icon: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
        label: Text(
          'Check Out: 2,000₵',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _postSalesLine() async {
    // if (userNameController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide user Name", context);
    //   return;
    // }
    // if (passwordController.text.toString().isEmpty) {
    //   helper.snackBarNotification("Please provide password", context);
    //   return;
    // }
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
        "Document_No": widget.Docs_No,
        "No": "BDO001",
        "Description": "QWERTY",
        "Quantity": 99,
        "Location_Code": Location_Code,
        "Type": "Item",
        "Document_Type": "Order",
        "Document_No": 169,
        "No": "CMT059",
        "Description": "Sam",
        "Quantity": 16,
        "Type": "Item",
        "Location_Code": "SAL1"
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

      Navigator.push(
          context, MaterialPageRoute(builder: ((context) => MyNevBar())));

      setState(() {
        // Docs_No = responseJson["No"].toString();
      });

      // String role1 = responseJson["roles"].toString();
      // String active      = responseJson["active"] .toString();
      // String token = responseJson["token"].toString();
      progressDialog.hide();

      helper.flushBar2("Success", "Submited Successfully", context);
    } else {
      progressDialog.hide();
      helper.flushBar2("Error", response.body, context);

      // helper.alertDialogNoTitle(response.body, context);
    }
  }
}

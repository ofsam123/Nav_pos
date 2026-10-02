import 'package:flutter/material.dart';

class itemDetails extends StatefulWidget {
  itemDetails({
    required this.No,
    required this.Description,
    required this.description2,
    required this.basedUnit,
    required this.type,
    required this.itemCatCode,
    required this.pricesVat,
    required this.salesUnit,
    required this.itemTrackingCode,
    required this.lotsNos,
    required this.SerialNums,
    required this.block,
    required this.image,
  });

  String? No;
  String? Description;
  String? description2;
  String? basedUnit;
  String? type;
  String? itemCatCode;
  String? pricesVat;
  String? salesUnit;
  String? itemTrackingCode;
  String? lotsNos;
  String? SerialNums;
  String? block;
  String? image;

  @override
  State<itemDetails> createState() => _itemDetailsState();
}

class _itemDetailsState extends State<itemDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 231, 229, 229),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Container(
              //   height: 300,
              //   color: Color.fromARGB(255, 236, 236, 236),
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios)),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Details",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  )
                ],
              ),
              SizedBox(
                height: 300,
                child: Center(
                  child: Container(
                      height: 250,
                      // child: Image.asset("assets/images/perfume.png")
                      child: Image.network(widget.image.toString())),
                ),
              ),
              Container(
                width: double.infinity,
                height: 600,
                // height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Text(
                            "Category Name:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color.fromARGB(255, 1, 41, 75)),
                          ),
                          Text(
                            widget.itemCatCode.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              // color: Color.fromARGB(255, 1, 41, 75)
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "ID NO:  " + widget.No.toString(),
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 16,
                          // color: Color.fromARGB(255, 1, 41, 75)
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Product Discription",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color.fromARGB(255, 1, 41, 75)),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        widget.Description.toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.grey),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text("Discription",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 41, 75)))),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text("Blocked",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 41, 75)))),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text(widget.description2.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey))),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              child: Text(
                                  widget.block
                                      .toString()
                                      .replaceAll("null", "false"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey))
                              // padding: EdgeInsets.only(top: 20),
                              // child: Checkbox(value: (bool? vale), onChanged: (bool? value) {  },)),
                              )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text("Base Unit Measure",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 41, 75)))),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text("Item Category Code",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color.fromARGB(255, 1, 41, 75)))),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text(widget.basedUnit.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey))),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                              // height: 80,
                              width: MediaQuery.of(context).size.width / 2.4,
                              // padding: EdgeInsets.only(top: 20),
                              child: Text(widget.itemCatCode.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey))),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ExpansionTile(
                          title: Text("Inventory",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 1, 41, 75)))),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class visitationDeatils extends StatefulWidget {
  visitationDeatils(
      {required this.id,
      required this.date,
      required this.name,
      required this.userId,
      required this.time,
      required this.longitue,
      required this.latitude});

  String? id;
  String? date;
  String? name;
  String? userId;
  String? longitue;
  String? latitude;
  String? time;
  @override
  State<visitationDeatils> createState() => _visitationDeatilsState();
}

class _visitationDeatilsState extends State<visitationDeatils> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Visitation Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  leading: Icon(Icons.person_2_outlined),
                  title: Text("CustomerID: "),
                  subtitle: Text(
                    widget.id.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  // trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  leading: Icon(Icons.date_range),
                  title: Text("Date: "),
                  subtitle: Text(
                    widget.date.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  // trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  leading: Icon(Icons.abc),
                  title: Text("Customer name: "),
                  subtitle: Text(
                    widget.name.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  // trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  leading: Icon(Icons.person_2_outlined),
                  title: Text("UserID: "),
                  subtitle: Text(
                    widget.userId.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  // trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                color: Colors.white,
                //                           <-- Card widget
                child: ListTile(
                  leading: Icon(Icons.timelapse),
                  title: Text("Time: "),
                  subtitle: Text(
                    widget.time.toString(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  // trailing: Icon(Icons.arrow_forward_ios),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Card(
                  color: Colors.white,
                  //                           <-- Card widget
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Text(
                              "Longitue",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text("Latitude",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 10),
                        child: Row(
                          children: [
                            Text(widget.longitue.toString()),
                            Spacer(),
                            Text(widget.latitude.toString())
                          ],
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

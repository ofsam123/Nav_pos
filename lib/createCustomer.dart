import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:http/http.dart' as http;
import 'API.dart';
import 'apiHelper.dart';
import 'bottomNavigation.dart';
import 'customerShops.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisterCustomerPage extends StatefulWidget {
  RegisterCustomerPage({required this.responsC});

  String? responsC;

  @override
  State<RegisterCustomerPage> createState() => _RegisterCustomerPageState();
}

class _RegisterCustomerPageState extends State<RegisterCustomerPage> {
  final Helper helper = new Helper();
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneController = TextEditingController();
  var EmailAddressController = TextEditingController();
  var userNameController = TextEditingController();
  var passwordController = TextEditingController();
  var contactNameController = TextEditingController();
  var faxNoController = TextEditingController();
  var homePageController = TextEditingController();

  late double myLat = 0;
  late double myLong = 0;
  late LatLng myLocation = LatLng(myLat, myLong);
  String resCenter = "";
  String Location_Code = "";
  @override
  void initState() {
    _getUserData();
    getCurrentLocation();
    Timer(Duration(seconds: 1), () {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');
    Location_Code = (prefs.getString('Location_Code') ?? '');

    Timer(Duration(seconds: 0), () {
      setState(() {});
    });
  }

  var otherLocationController = TextEditingController();
  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      // Handle the picked image (e.g., display it, upload it, etc.)
      // You can use pickedImage.path to get the file path of the selected image.
    } else {
      // User canceled the image picker.
    }
  }

  String? base64Image = "";
  File? image;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        this.image = imageTemp;
        File imageFile = new File(image!.path);
        List<int> imageBytes = imageFile.readAsBytesSync();
        base64Image = base64Encode(imageBytes);
      });
      // setState(() => this.image = imageTemp);
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  String newNo = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Customer"),
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 05,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        resCenter.toString(),
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          // CircleAvatar(
                          //   radius: 50,
                          //   backgroundColor: Colors.grey,
                          //   child: Center(
                          //     child: IconButton(
                          //       icon: Icon(Icons.add),
                          //       onPressed: _pickImage, // Open image picker
                          //     ),
                          //   ),
                          // ),
                          // GestureDetector(
                          //   onTap: () {
                          //     pickImage();
                          //   },
                          //   child: Container(
                          //       height: 80,
                          //       width: 80,
                          //       decoration: BoxDecoration(
                          //           color: Colors.white,
                          //           border: Border.all(
                          //               width: 1, color: Colors.black),
                          //           borderRadius: BorderRadius.circular(30)),
                          //       child: Center(
                          //         child: image != null
                          //             ? Image.file(image!)
                          //             : Text("+ Image"),
                          //       )),
                          // ),

                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20,
                            ),
                            child: TextField(
                              controller: userNameController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.store,
                                  color: Colors.grey,
                                ),
                                label: Text("Customer Name"),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(left: 30),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20,
                            ),
                            child: TextField(
                              controller: EmailAddressController,
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.alternate_email_outlined,
                                  color: Colors.grey,
                                ),
                                label: Text("Email (opt)*"),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(fontSize: 14),
                                contentPadding: EdgeInsets.only(left: 30),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(
                          //     left: 20.0,
                          //     right: 20,
                          //   ),
                          //   child: TextField(
                          //     keyboardType: TextInputType.number,
                          //     maxLength: 10,
                          //     controller: phoneController,
                          //     decoration: InputDecoration(
                          //       suffixIcon: Icon(
                          //         Icons.phone_android,
                          //         color: Colors.grey,
                          //       ),
                          //       label: Text("Phone Number"),
                          //       filled: true,
                          //       fillColor: Colors.blueGrey[50],
                          //       labelStyle: TextStyle(fontSize: 14),
                          //       contentPadding: EdgeInsets.only(left: 30),
                          //       enabledBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.blueGrey,
                          //         ),
                          //         borderRadius: BorderRadius.circular(15),
                          //       ),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(
                          //           color: Colors.blueGrey,
                          //         ),
                          //         borderRadius: BorderRadius.circular(15),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 226, 226, 226),
                                  borderRadius: BorderRadius.circular(20)),
                              child: ExpansionTile(
                                title: Text("Contacts"),
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                    ),
                                    child: TextField(
                                      // keyboardType: TextInputType.number,
                                      // maxLength: 10,
                                      controller: contactNameController,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Icons.person,
                                          color: Colors.grey,
                                        ),
                                        label: Text("Contact Name"),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                        labelStyle: TextStyle(fontSize: 14),
                                        contentPadding:
                                            EdgeInsets.only(left: 30),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                    ),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      controller: phoneController,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Icons.phone_android,
                                          color: Colors.grey,
                                        ),
                                        label: Text("Phone Number"),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                        labelStyle: TextStyle(fontSize: 14),
                                        contentPadding:
                                            EdgeInsets.only(left: 30),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //     left: 20.0,
                                  //     right: 20,
                                  //   ),
                                  //   child: TextField(
                                  //     keyboardType: TextInputType.number,
                                  //     // maxLength: 10,
                                  //     controller: faxNoController,
                                  //     decoration: InputDecoration(
                                  //       suffixIcon: Icon(
                                  //         Icons.numbers,
                                  //         color: Colors.grey,
                                  //       ),
                                  //       label: Text("Fax No"),
                                  //       filled: true,
                                  //       fillColor: Colors.blueGrey[50],
                                  //       labelStyle: TextStyle(fontSize: 14),
                                  //       contentPadding:
                                  //           EdgeInsets.only(left: 30),
                                  //       enabledBorder: OutlineInputBorder(
                                  //         borderSide: BorderSide(
                                  //           color: Colors.blueGrey,
                                  //         ),
                                  //         borderRadius:
                                  //             BorderRadius.circular(15),
                                  //       ),
                                  //       focusedBorder: OutlineInputBorder(
                                  //         borderSide: BorderSide(
                                  //           color: Colors.blueGrey,
                                  //         ),
                                  //         borderRadius:
                                  //             BorderRadius.circular(15),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),

                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 20.0,
                                      right: 20,
                                    ),
                                    child: TextField(
                                      // keyboardType: TextInputType.number,
                                      // maxLength: 10,
                                      controller: homePageController,
                                      decoration: InputDecoration(
                                        suffixIcon: Icon(
                                          Icons.home,
                                          color: Colors.grey,
                                        ),
                                        label: Text("Home Page"),
                                        filled: true,
                                        fillColor: Colors.blueGrey[50],
                                        labelStyle: TextStyle(fontSize: 14),
                                        contentPadding:
                                            EdgeInsets.only(left: 30),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.blueGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      showPlacePicker();
                                    },
                                    child: Text(
                                      "Add Location +",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    )),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showPlacePicker();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 20.0,
                                right: 20,
                              ),
                              child: TextField(
                                readOnly: true,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  label: Text("lng & Lat"),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                    ),
                                    onPressed: showPlacePicker, // Get location
                                  ),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(fontSize: 14),
                                  contentPadding: EdgeInsets.only(left: 30),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20.0,
                              right: 20,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ElevatedButton(
                                child: Container(
                                  width: double.infinity,
                                  height: 50,
                                  child: Center(
                                    child: Text("Register Customer"),
                                  ),
                                ),
                                onPressed: () {
                                  _registerCustomer();
                                  // showPlacePicker();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(15, 86, 148, 1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 50,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Text("Terms and Conditions"),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey,
                                  height: 50,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Powered By Synergy Center",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showPlacePicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: Platform.isAndroid ? Helper.androidApiKey : Helper.iosApiKey,
          onPlacePicked: (result) {
            setState(() {
              // Extract the latitude and longitude from the result
              double latitude = result.geometry!.location.lat;
              double longitude = result.geometry!.location.lng;

              // Update the passwordController text with the coordinates
              passwordController.text = "Lat: $latitude, Lng: $longitude";
            });

            Navigator.of(context).pop();
          },
          initialPosition: myLocation,
          useCurrentLocation: true,
          resizeToAvoidBottomInset:
              false, // remove this line, if map offsets are wrong
        ),
      ),
    );

    if (result == null) {
      // Handle when the user cancels the Place Picker
    }
  }

  // void showPlacePicker() async {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => PlacePicker(
  //         apiKey: Platform.isAndroid ? Helper.androidApiKey : Helper.iosApiKey,
  //         onPlacePicked: (result) {
  //           //  print(result.address);
  //           setState(() {
  //             //otherLocationController.text = result.name.toString().replaceAll("null", "");
  //             otherLocationController.text =
  //                 result.formattedAddress.toString().replaceAll("null", "");
  //             // _currentAddress = otherLocationController.text;
  //             // _addLocation(result.geometry!.location.lng.toString(),result.geometry!.location.lat.toString(),);
  //           });

  //           Navigator.of(context).pop();
  //         },
  //         initialPosition: myLocation,
  //         useCurrentLocation: true,
  //         resizeToAvoidBottomInset:
  //             false, // remove this line, if map offsets are wrong
  //       ),
  //     ),
  //   );
  // }

  // created method for getting user current location
  // void _getCurrentLocation() {
  //   getCurrentLocation(); // Just call the function to get and handle the location

  //   passwordController.text = "Lat: $myLat, Lng: $myLong";
  // }

  Future<void> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      setState(() {
        passwordController.text = "Lat: $latitude, Lng: $longitude";
      });

      // Call _postVisitation with latitude and longitude
      // _postVisitation(latitude, longitude);

      // Display the latitude and longitude (you can use a dialog or any other widget)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Current Location"),
            content: Text("Latitude: $latitude\nLongitude: $longitude"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print("Error: $e");
      // Handle errors here
    }
  }

  Future<void> _registerCustomer() async {
    try {
      // Get the latitude and longitude as double values
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;

      if (userNameController.text.toString().isEmpty) {
        helper.snackBarNotification("Please provide user Name", context);
        return;
      }
      if (phoneController.text.toString().isEmpty) {
        helper.snackBarNotification("Please provide phone", context);
        return;
      }

      SimpleFontelicoProgressDialog progressDialog =
          SimpleFontelicoProgressDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Registring ...",
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String resCenter = (prefs.getString('Sales_Resp_Ctr_Filter') ?? '');
      String Location_Code = (prefs.getString('Location_Code') ?? '');
      String basicAuth = 'Basic ' +
          base64Encode(
              utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
      final response = await http
          .post(Uri.parse(ApiUrl.registerCustomer),
              headers: {
                'Content': 'application/x-www-form-urlencoded',
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Authorization': '$basicAuth',
                "Access-Control-Allow-Origin": "*",
              },
              body: jsonEncode(<String, dynamic>{
                "Name": userNameController.text.toString(),
                "Phone_No": phoneController.text.toString(),
                "E_Mail": EmailAddressController.text.toString(),
                "Home_Page": homePageController.text.toString(),
                "Responsibility_Center": widget.responsC.toString(),
                // "Fax_No": faxNoController.text.toString(),
                // "Contact_Name": contactNameController.text.toString(),
                "Location_Code": Location_Code.toString(),
                "Gen_Bus_Posting_Group": "DOMESTIC",
                "Customer_Posting_Group": "DOMESTIC",
                "Latitude": latitude,
                "Longitude": longitude,
                "Customer_Price_Group": "ACC RET"
              }))
          .catchError((err) {
        progressDialog.hide();
        helper.alertDialogTitle('${Helper.errorMessageOops}',
            '${Helper.errorMessageSomethingWentWrong}', context);
      });

      progressDialog.hide();
      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 201) {
        progressDialog.hide();
        String nno = responseJson["No"].toString();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => customerShopsPage(
                      Id: "",
                      responsC: widget.responsC.toString(),
                    )),
            (route) => false);

        // progressDialog.hide();
        SharedPreferences prefs2 = await SharedPreferences.getInstance();
        // prefs.setString('User_ID_2', User_ID_2);
        prefs2.setString('nno', nno);
        // helper.alertDialogNoTitle(nno, context);
        helper.flushBar2("Success", " Successful", context);

        setState(() {
          newNo = nno.toString();
          // _profilePicture();
        });
      } else {
        progressDialog.hide();
        // helper.flushBar2("Error", response.body, context);

        helper.alertDialogNoTitle(response.body, context);

        // helper.alertDialogNoTitle(
        //     'enter a valid email  eg;test@gmail.com', context);
      }
    } catch (e) {
      print("Error: $e");
      // Handle errors here
    }
  }

  Future<void> _profilePicture() async {
    SimpleFontelicoProgressDialog progressDialog =
        SimpleFontelicoProgressDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Picture ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.patch(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('WAGCOL%20POS')/CustomerAPI('$newNo')/Picture/$base64Image"),
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

      // Navigator.pop(context);

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyNevBar()));

      helper.flushBar2("Success", " Successful Registered", context);
    } else {
      progressDialog.hide();
      //helper.flushBar2("Error", response.body, context);
      helper.flushBar2("Success", " Registered", context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyNevBar()));

      // helper.alertDialogNoTitle("Insert Image", context);
    }
  }
}

// void main() => runApp(MaterialApp(home: RegisterCustomerPage()));

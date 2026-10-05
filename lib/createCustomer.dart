import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_pos/widgets/app_loader.dart';
import 'package:http/http.dart' as http;
import 'API.dart';
import 'apiHelper.dart';
import 'bottomNavigation.dart';
import 'customerShops.dart';
import 'theme/app_theme.dart';
import 'widgets/app_widgets.dart';
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

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register Customer"),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          AppCard(
            child: Row(
              children: [
                const IconBadge(
                  icon: Icons.storefront_outlined,
                  color: AppColors.primary,
                  size: 48,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "New customer",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayValue(resCenter.toString()),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SmallCapsLabel("Business"),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel("Customer Name"),
                TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    hintText: "Enter customer name",
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                ),
                const SizedBox(height: 14),
                _fieldLabel("Email (optional)"),
                TextField(
                  controller: EmailAddressController,
                  decoration: const InputDecoration(
                    hintText: "name@example.com",
                    prefixIcon: Icon(Icons.alternate_email_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SmallCapsLabel("Contact"),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel("Phone Number"),
                TextField(
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  controller: phoneController,
                  decoration: const InputDecoration(
                    hintText: "e.g. 0241234567",
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                ),
                const SizedBox(height: 4),
                _fieldLabel("Home Page"),
                TextField(
                  controller: homePageController,
                  decoration: const InputDecoration(
                    hintText: "www.example.com",
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: SmallCapsLabel("Location")),
              TextButton.icon(
                onPressed: () {
                  showPlacePicker();
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: const Text("Add Location"),
              ),
            ],
          ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fieldLabel("Longitude & Latitude"),
                GestureDetector(
                  onTap: () {
                    showPlacePicker();
                  },
                  child: TextField(
                    readOnly: true,
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: "Tap to pick a location",
                      prefixIcon: const Icon(Icons.place_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.location_on),
                        onPressed: showPlacePicker, // Get location
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "Terms and Conditions",
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "Powered By Synergy Center",
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _registerCustomer();
                // showPlacePicker();
              },
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text("Register Customer"),
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

      AppLoadingDialog progressDialog =
          AppLoadingDialog(
              context: context, barrierDimisable: true);
      progressDialog.show(
        message: "Registering ...",
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
    AppLoadingDialog progressDialog =
        AppLoadingDialog(context: context, barrierDimisable: true);
    progressDialog.show(
      message: "Uploading picture ...",
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('${ApiUrl.APIusername}:${ApiUrl.APIpassword}'));
    final response = await http.patch(
      Uri.parse(
          "http://40.67.140.177:7048/DynamicsNAV110/ODataV4/Company('ZZZ%20TEST%20FOR%20WAGCOL')/CustomerAPI('$newNo')/Picture/$base64Image"),
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

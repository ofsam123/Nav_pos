import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_fontellico_progress_dialog/simple_fontico_loading.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'apiHelper.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Completer<GoogleMapController> _controller = Completer();
  late double myLat = 0;
  late double myLong = 0;
  late LatLng myLocation = LatLng(myLat, myLong);
  late List responseList;
  var currentLocationController = TextEditingController();
  var otherLocationController = TextEditingController();
  late Position position;

  final Helper helper = Helper();
  //late Future<List<viewLocationModel>> _func2;
  bool _isShow = false;
  bool _isShow1 = true;
  String _currentCountry = "", _currentAddress = "";

  @override
  void initState() {
    currentLocationController.text = "";
    otherLocationController.text = "";

    Timer(Duration(seconds: 0), () {
      setState(() {
        _getCurrentLocation();
        // SearchController.text = widget.drugName!;
        // currentLocationController.text = _currentAddress!;
        // loadSharedPref();
      });
    });
    Timer(Duration(seconds: 2), () {
      setState(() {
        _getCurrentLocation();
      });
    });
    super.initState();
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("location"),
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Color.fromARGB(255, 236, 235, 235),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 3),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: double.infinity,
                  height: 220,
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Other Location",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 20),
                        child: Row(
                          children: [
                            Container(
                              height: 30,
                              child: Icon(Icons.map),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /*  Text(
                                  _currentCountry,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                SizedBox(
                                  height: 5,
                                ),*/
                                Text(
                                  otherLocationController.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
                                /*Text(
                                  otherLocationController.text,
                                  style: TextStyle(color: Colors.black, fontSize: smallText),
                                ),*/
                              ],
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.only(right: 20.0),
                              child: GestureDetector(
                                onTap: () {
                                  showPlacePicker();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 20.0),
                                  child: Icon(Icons.edit),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  )),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPlacePicker() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacePicker(
          apiKey: Platform.isAndroid ? Helper.androidApiKey : Helper.iosApiKey,
          onPlacePicked: (result) {
            //  print(result.address);
            setState(() {
              //otherLocationController.text = result.name.toString().replaceAll("null", "");
              otherLocationController.text =
                  result.formattedAddress.toString().replaceAll("null", "");
              _currentAddress = otherLocationController.text;
              // _addLocation(result.geometry!.location.lng.toString(),result.geometry!.location.lat.toString(),);
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
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission()
        .then((value) {})
        .onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      print("ERROR" + error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  _getCurrentLocation() {
    getUserCurrentLocation().then((value) async {
      setState(() {
        myLat = value.latitude;
        myLong = value.longitude;
        myLocation = LatLng(myLat, myLong);
      });
      setState(() {});
    });
  }
}

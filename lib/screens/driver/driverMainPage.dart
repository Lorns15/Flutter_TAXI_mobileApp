import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/screens/driver/bookingHistoryPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'bookingsPage.dart';

class DriverMainPage extends StatefulWidget {
  static const routeName = '/DriverMainPage';
  @override
  DriverMainPageState createState() => DriverMainPageState();
}

class DriverMainPageState extends State<DriverMainPage> {
  bool _isLoading = true;
  bool _isLoadingMap = false;
  late Map<String, dynamic> globalResponse;
  late SharedPreferences sharedPreferences;
  var userLatLng = LatLng(8.6765826, 126.13578990000002);
  var userLatLngDisplay = LatLng(8.6765826, 126.13578990000002);
  var destinationLatLng;
  Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  double routeDistance = 0.0;
  double routeDistanceDOL = 0.0;
  double routeDistanceDOLFinal = 0.0;
  Set<Polyline> _polylines = {};
  Set<Polyline> _polylinesDOL = {};
  late PointLatLng pickUpLoc;
  late PointLatLng dropOffLoc;
  var bookingDetails;
  bool _isPickupSelected = true;
  Set<Marker> _markers = {};
  Set<Marker> _markersDOL = {};
  bool _hasBooking = false;
  bool _hasPickUp = false;
  // bool _hasDropOff = false;
  Timer? distanceTimer;
  Timer? curentLocTimer;
  String globalToken = '';
  bool isCurrentLocUpdate = false;

  initializeValue() async {
    var currentLocationP = await locateUser();
    sharedPreferences = await SharedPreferences.getInstance();
    globalResponse = json.decode(sharedPreferences.getString("response")!);
    print("globalResponse");
    print(globalResponse);

    if (globalResponse.containsKey("access_token")){
      globalToken = globalResponse["access_token"];
    }
    if (globalToken.isEmpty) {
      globalToken = sharedPreferences.getString("otp_token")!;
    }

    setState(() {
      userLatLng = LatLng(currentLocationP.latitude, currentLocationP.longitude);

      if (globalResponse.containsKey("data") && globalResponse["data"].containsKey("has_book")) {
        _hasBooking = globalResponse["data"]["has_book"];
      }

      // if (globalResponse.containsKey("data") && globalResponse["data"].containsKey("is_picked_up")) {
      //   _hasPickUp = globalResponse["data"]["is_picked_up"];
      // }

      if (_hasBooking) {
        var url = Uri.parse(domainBackend + "/api/driver/confirm-booking");
        // var token = globalResponse["access_token"];
        http.get(
          url,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
        ).then((response) {
          print(response.statusCode);

          if (response.statusCode != 500) {
            var jsonResponse = json.decode(response.body);
            print(jsonResponse);

            if (response.statusCode >= 200 && response.statusCode <= 299) {
              if(jsonResponse != null) {
                var data = json.decode(response.body)["data"];
                print("data");
                print(data);
                _hasPickUp = data["is_picked_up"];
                callbackBooking(data);
                // bookingDetails = data;
                // PointLatLng destination = PointLatLng(double.parse(data["drop_off_lat"]),
                //     double.parse(data["drop_off_long"]));
                // setPolylines(destination);
              } else {
                notify(context, "No response");
              }
            } else {
              notify(context, response.statusCode);
            }
          } else {
            notify(context, "server error");
          }
        });
      }

      _isLoading = false;

    });
  }

  Future<Position> locateUser() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValue();
    curentLocTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) => updateCurrentLoc());
    distanceTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer t) => checkDistanceLoc());
  }

  @override
  void dispose() {
    curentLocTimer?.cancel();
    distanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator()) : SafeArea(
        child: Column(
          verticalDirection: VerticalDirection.up,
          children: [
            (routeDistanceDOL != 0.0 || _hasBooking) ? infoBookingSection(): infoSection(),
            Expanded(
                child: Container(
                  child: _isLoadingMap ? Center(child: CircularProgressIndicator()) : GoogleMap(
                  mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: userLatLngDisplay,
                      zoom: 17.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                              LatLngBounds(
                                southwest: LatLng(
                                    userLatLngDisplay.latitude <= destinationLatLng.latitude
                                        ? userLatLngDisplay.latitude
                                        : destinationLatLng.latitude,
                                    userLatLngDisplay.longitude <= destinationLatLng.longitude
                                        ? userLatLngDisplay.longitude
                                        : destinationLatLng.longitude),
                                northeast: LatLng(
                                    userLatLngDisplay.latitude <= destinationLatLng.latitude
                                        ? destinationLatLng.latitude
                                        : userLatLngDisplay.latitude,
                                    userLatLngDisplay.longitude <= destinationLatLng.longitude
                                        ? destinationLatLng.longitude
                                        : userLatLngDisplay.longitude),
                              ),
                              50)
                      );
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    indoorViewEnabled: true,
                    polylines: _isPickupSelected ? _polylines : _polylinesDOL,
                    markers: _isPickupSelected ? _markers : _markersDOL,
                  ),
            ),
            ),
            if (routeDistanceDOL != 0.0) infoBookingTopSection()
          ],
        )
      ),
    );
  }

  Container infoSection() {
    String fname = "";

    if (globalResponse.containsKey("data")
        && globalResponse["data"].containsKey("fname")){
      print(globalResponse["data"]["fname"]);
      fname = globalResponse["data"]["fname"];
    }

    if (fname.isEmpty){
      refreshUserInfo();
      fname = globalResponse["data"]["fname"];
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text("Hello, $fname",
                textAlign: TextAlign.center,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 17, color: genUnselectedColor),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              margin: EdgeInsets.only(top: 5, bottom: 10.0),
              child: OutlinedButton(
                child: Row(
                  children: [
                    Icon(Icons.select_all),
                    Text(
                      "  View bookings",
                      style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genPrimaryColor),
                    ),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                  side: BorderSide(width: 1.0, color: genPrimaryColor),
                  backgroundColor: genBackgroundColor,
                ),
                onPressed: viewBooking,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 50.0,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              margin: EdgeInsets.only(bottom: 10.0),
              child: ElevatedButton(
                child: Row(
                  children: [
                    Icon(Icons.book),
                    Text(
                      "  Booking History",
                      style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  primary: genPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                ),
                  onPressed: showBookingHistoryPageModal
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container infoBookingSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: (_hasPickUp) ? [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text("From your location to drop off location\nKM: $routeDistanceDOLFinal",
                textAlign: TextAlign.center,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genUnselectedColor),
              ),
            ),
            Container(
                height: 55.0,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                margin: EdgeInsets.only(top: 5, bottom: 10.0),
                child: ButtonSolid(
                    bgcolor: /*(routeDistanceDOLFinal != 0.0) ? Colors.grey :*/ genPrimaryColor,
                    text: 'DROP-OFF',
                    onPressed: dropOff
                ),
              ),
          ] : [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text("From your location to pick up location\nKM: $routeDistance",
                textAlign: TextAlign.center,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genUnselectedColor),
              ),
            ),
            // Container(
            //   alignment: Alignment.center,
            //   padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
            //   child: Text("Note: you can only press PICK-UP button once you are in pick-up location",
            //     textAlign: TextAlign.center,
            //     style: TextStyle( fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
            //   ),
            // ),
            (!_hasBooking) ? Row(
              children: [
                Expanded(
                  child: Container(
                    height: 55.0,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonSolid(
                      text: 'ACCEPT',
                      onPressed: acceptBooking
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 55.0,
                    padding: EdgeInsets.only(right: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonOutline(
                      text: 'Cancel',
                      onPressed: cancelBooking
                    ),
                  ),
                ),
              ],
            ) :
             Container(
                height: 55.0,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                margin: EdgeInsets.only(top: 5, bottom: 10.0),
                child: ButtonSolid(
                    bgcolor: /*(routeDistance != 0.0) ? Colors.grey :*/ genPrimaryColor,
                    text: 'PICK-UP',
                    onPressed: pickUp
                ),
             ),
          ],
        ),
      ),
    );
  }

  Container infoBookingTopSection() {
    var pickUpLocName = bookingDetails['pick_up_location'].toString();
    var dropOffLocName = bookingDetails['drop_off_location'].toString();

    if (dropOffLocName.length > 46) {
      dropOffLocName = dropOffLocName.substring(0, 45) + " ...";
    }

    if (pickUpLocName.length > 46) {
      pickUpLocName = pickUpLocName.substring(0, 45) + " ...";
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.25,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 102,
                        child: Text("Pick Up: ",
                          textAlign: TextAlign.center,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 152,
                        child: Text(pickUpLocName,
                          textAlign: TextAlign.justify,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: genUnselectedColor),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 102,
                        child: Text("Destination: ",
                          textAlign: TextAlign.center,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 152,
                        child: Text(dropOffLocName,
                          textAlign: TextAlign.justify,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: genUnselectedColor),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        width: 102,
                        child: Text("KM: ",
                          textAlign: TextAlign.center,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 152,
                        child: Text("$routeDistanceDOL",
                          textAlign: TextAlign.justify,
                          style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: genUnselectedColor),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40.0,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonOutline(
                      bgcolor: _isPickupSelected ? Colors.white60 : genBackgroundColor,
                      text: 'VIEW PICK-UP',
                      onPressed: viewPickUp
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 40.0,
                    padding: EdgeInsets.only(right: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonOutline(
                      bgcolor: _isPickupSelected ? genBackgroundColor : Colors.white60,
                      text: 'VIEW DROP-OFF',
                      onPressed: viewDropOff
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  callbackBooking (bookDetails) {
    bookingDetails = bookDetails;
    print("bookingDetails");
    print(bookingDetails);
    pickUpLoc = PointLatLng(num.parse(bookingDetails['pick_up_lat']).toDouble(),
        num.parse(bookingDetails['pick_up_long']).toDouble());

    dropOffLoc = PointLatLng(num.parse(bookingDetails['drop_off_lat']).toDouble(),
        num.parse(bookingDetails['drop_off_long']).toDouble());

    setState(() => _isLoadingMap = true);
    setPickUpPolylines();
  }

  setPickUpPolylines() async {
    // userLatLng = await getUserLocation();
    userLatLngDisplay = userLatLng;
    destinationLatLng = pickUpLoc;

    List<LatLng> polylineCoordinates = [];
    // LatLng sourcePin;
    LatLng pickUpPin;
    LatLng dropOffPin;

    PolylineResult result = await
    polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(userLatLng.latitude, userLatLng.longitude),
        pickUpLoc);
    print("result");
    print(result.points.length);
    // sourcePin = LatLng(result.points[0].latitude, result.points[0].longitude);
    pickUpPin = LatLng(result.points[result.points.length - 1].latitude, result.points[result.points.length - 1].longitude);

    result.points.forEach((PointLatLng point){
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });


    List<LatLng> polylineCoordinatesDOL = [];
    PolylineResult resultDOL = await
    polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        pickUpLoc,
        dropOffLoc);

    dropOffPin = LatLng(resultDOL.points[resultDOL.points.length - 1].latitude, resultDOL.points[resultDOL.points.length - 1].longitude);

    resultDOL.points.forEach((PointLatLng point){
      polylineCoordinatesDOL.add(
          LatLng(point.latitude, point.longitude));
    });

    setState(() {
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          points: polylineCoordinates,
          width: 5
      );
      routeDistance = _calculateDistance(polylineCoordinates);
      print("routeDistance");
      print(routeDistance);
      _polylines.clear();
      _polylines.add(polyline);
      _markers.clear();
      // _markers.add(Marker(
      //     markerId: MarkerId('sourcePin'),
      //     position: sourcePin,
      // ));
      _markers.add(Marker(
        markerId: MarkerId('pickUpPin'),
        position: pickUpPin,
        icon: BitmapDescriptor.defaultMarkerWithHue(10.0)
      ));

      Polyline polyline2 = Polyline(
          polylineId: PolylineId('poly'),
          points: polylineCoordinatesDOL,
          width: 5
      );
      routeDistanceDOL = _calculateDistance(polylineCoordinatesDOL);
      print("routeDistanceDOL");
      print(routeDistanceDOL);
      routeDistanceDOLFinal = routeDistanceDOL;
      _polylinesDOL.clear();
      _polylinesDOL.add(polyline2);
      _markersDOL.clear();
      _markersDOL.add(Marker(
        markerId: MarkerId('pickUpPin'),
        position: pickUpPin,
      ));
      _markersDOL.add(Marker(
          markerId: MarkerId('dropOffPin'),
          position: dropOffPin,
      ));

      _isLoadingMap = false;
    });
  }

  viewBooking() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return BookingsPage(callback: callbackBooking, token: globalToken, userLatLng: userLatLng);
        }
    );
  }

  showBookingHistoryPageModal(){
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return BookingHistoryPage(token: globalToken);
        }
    );
  }

  viewPickUp() async {
    if (!_isPickupSelected) {
      setState(() => _isLoadingMap = true);
      print("VIEW PICK-UP");
      // userLatLng = await getUserLocation();
      userLatLngDisplay = userLatLng;
      destinationLatLng = pickUpLoc;
      await Future.delayed(const Duration(seconds: 1), (){});
      setState(() {
        _isPickupSelected = true;
        _isLoadingMap = false;
      });
    }
  }

  viewDropOff() async {
    if (_isPickupSelected) {
      setState(() => _isLoadingMap = true);
      print("VIEW DROP-OFF");
      userLatLngDisplay = LatLng(pickUpLoc.latitude,
          pickUpLoc.longitude);
      destinationLatLng = dropOffLoc;
      await Future.delayed(const Duration(
          seconds: 1), () {});

      setState(() {
        _isPickupSelected = false;
        _isLoadingMap = false;
      });
    }
  }

  acceptBooking() {
    var url = Uri.parse(domainBackend + "/api/driver-booking/" + bookingDetails["id"].toString());

    http.put(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
    ).then((response) {
      print(response.statusCode);

      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            setState(() => _hasBooking = true);
            notify(context, "Booking accepted");
          } else {
            notify(context, "No response");
          }
        } else {
          notify(context, response.statusCode);
        }
      } else {
        notify(context, "server error");
      }
    });
  }

  cancelBooking() {
    routeDistance = 0.0;
    routeDistanceDOL = 0.0;
    routeDistanceDOLFinal = 0.0;
    _polylines.clear();
    _polylinesDOL.clear();
    _markers.clear();
    _markersDOL.clear();
    _isPickupSelected = true;
    _hasPickUp = false;
    _hasBooking = false;
    setState(() {});
  }

  checkDistanceLoc() async {
    if (_hasPickUp && routeDistanceDOLFinal != 0) {
      List<LatLng> polylineCoordinates = [];
      // userLatLng = await getUserLocation();
      userLatLngDisplay = userLatLng;
      PolylineResult result = await
      polylinePoints.getRouteBetweenCoordinates(
          kGoogleApiKey,
          PointLatLng(userLatLng.latitude, userLatLng.longitude),
          dropOffLoc);

      result.points.forEach((PointLatLng point){
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId('poly'),
            points: polylineCoordinates,
            width: 5
        );
        routeDistanceDOLFinal = _calculateDistance(polylineCoordinates);
        _polylinesDOL.clear();
        _polylinesDOL.add(polyline);
        _isPickupSelected = false;
      });
    } else if (_hasBooking && routeDistance != 0) {
      List<LatLng> polylineCoordinates = [];
      // userLatLng = await getUserLocation();
      userLatLngDisplay = userLatLng;
      PolylineResult result = await
      polylinePoints.getRouteBetweenCoordinates(
          kGoogleApiKey,
          PointLatLng(userLatLng.latitude, userLatLng.longitude),
          pickUpLoc);

      result.points.forEach((PointLatLng point){
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        Polyline polyline = Polyline(
            polylineId: PolylineId('poly'),
            points: polylineCoordinates,
            width: 5
        );
        routeDistance = _calculateDistance(polylineCoordinates);
        _polylines.clear();
        _polylines.add(polyline);
      });
    }
  }

  updateCurrentLoc() async {
    if (isCurrentLocUpdate == false) {
      isCurrentLocUpdate = true;
      userLatLng = await getUserLocation();
      var currentLoc = await _getAddressName(userLatLng);
      // print("currentLoc " + currentLoc);
      Map data = {
        "current_location": currentLoc,
        "long": userLatLng.longitude.toString(),
        "lat": userLatLng.latitude.toString()
      };

      http.put(
        Uri.parse(domainBackend + "/api/location"),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $globalToken',
        },
        body: data,
      ).then((response) {
        // print("updateCurrentLoc");
        // print(response.statusCode);
        // print(response.body);
        isCurrentLocUpdate = false;
      });
    }
  }

  Future<String> _getAddressName(latLong) async {
    FetchGeocoder fetchGeocoder = await Geocoder2.getAddressFromCoordinates(
        latitude: latLong.latitude,
        longitude: latLong.longitude,
        googleMapApiKey: kGoogleApiKey);
    var first = fetchGeocoder.results.first;
    // final coordinates = new Coordinates(latLong.latitude, latLong.longitude);
    // var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // var first = addresses.first;
    return first.formattedAddress;
  }

  pickUp () {
    // if (routeDistance == 0.0) {
      var url = Uri.parse(domainBackend + "/api/driver/pickUp");

      http.put(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
      ).then((response) {
        print(response.statusCode);

        if (response.statusCode != 500) {
          var jsonResponse = json.decode(response.body);
          print(jsonResponse);

          if (response.statusCode >= 200 && response.statusCode <= 299) {
            if(jsonResponse != null) {
              print("jsonResponse");
              print(jsonResponse);
              setState(() => _hasPickUp = true);
            } else {
              notify(context, "No response");
            }
          } else {
            notify(context, response.statusCode);
          }
        } else {
          notify(context, "server error");
        }
      });
    // }
  }

  dropOff () {
    // if (routeDistanceDOLFinal == 0.0) {
      var url = Uri.parse(domainBackend + "/api/driver/dropOff");

      http.put(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
      ).then((response) {
        print(response.statusCode);

        if (response.statusCode != 500) {
          var jsonResponse = json.decode(response.body);
          print(jsonResponse);

          if (response.statusCode >= 200 && response.statusCode <= 299) {
            if(jsonResponse != null) {
              print("jsonResponse");
              print(jsonResponse);
              cancelBooking();
              // setState(() {});
              // setState(() => _hasDropOff = true);
            } else {
              notify(context, "No response");
            }
          } else {
            notify(context, response.statusCode);
          }
        } else {
          notify(context, "server error");
        }
      });

    // }
  }

  Future<LatLng> getUserLocation() async {
    var currentLocationP = await locateUser();
    LatLng latLng = LatLng(currentLocationP.latitude, currentLocationP.longitude);
    return latLng;
  }

  double _calculateDistance(List<LatLng> polyline) {
    double totalDistance = 0;
    for (int i = 0; i < polyline.length; i++) {
      if (i < polyline.length - 1) { // skip the last index
        totalDistance += _coordinateDistance(
            polyline[i + 1].latitude,
            polyline[i + 1].longitude,
            polyline[i].latitude,
            polyline[i].longitude);
      }
    }
    return double.parse((totalDistance).toStringAsFixed(2));
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  refreshUserInfo() {
    var url = Uri.parse(domainBackend + "/api/auth/user");

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
    ).then((response) {
      print(response.statusCode);

      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(jsonResponse);

        if (response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            // sharedPreferences.setString("response", response.body);
            globalResponse["data"] = json.decode(response.body)["data"];
            setState(() {});
          } else {
            notify(context, "No response");
          }
        } else {
          notify(context, response.statusCode);
        }
      } else {
        notify(context, "server error");
      }
    });
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/NumberInputWithIncrementDecrement.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'bookingHistoryPage.dart';
import 'searchPlacePage.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:http/http.dart' as http;

class MapPage extends StatefulWidget {
  static const routeName = '/mapPage';
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {

  bool _isLoading = true;
  var userLatLng = LatLng(8.6765826, 126.13578990000002) ;
  var destinationLatLng;
  Completer<GoogleMapController> _controller = Completer();
  PolylinePoints polylinePoints = PolylinePoints();
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  double routeDistance = 0.0;
  String destinationName = "";
  int _itemCount = 1;
  bool _isBook = false;
  bool _isBookConfirm = false;
  Timer? timer;
  var driversInfo;
  String globalToken = '';

  Future<Position> locateUser() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  var googlePlace = GooglePlace(kGoogleApiKey);
  List<AutocompletePrediction> predictions = [];
  late DetailsResult detailsPlaceResult;

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    print(value);
    if (result != null && result.predictions != null && mounted) {
      print(result.status);
      setState(() {
        predictions = result.predictions!;
        print(predictions);
      });
    }
  }

  Future<LatLng> getUserLocation() async {
    var currentLocationP = await locateUser();
    // setState(() {
    LatLng latLng = LatLng(currentLocationP.latitude, currentLocationP.longitude);
    //   _isLoading = false;
    // });
    print('user location $latLng');
    return latLng;
  }

  late SharedPreferences sharedPreferences;
  late Map<String, dynamic> globalResponse;

  setSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
    globalResponse = json.decode(sharedPreferences.getString("response")!);
    setState(() {
      _isLoading = false;
    });
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
            globalResponse["data"] = jsonResponse["data"];
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

  initializeValue() async {
    var currentLocationP = await locateUser();
    sharedPreferences = await SharedPreferences.getInstance();
    print(sharedPreferences.getString("response"));
    globalResponse = json.decode(sharedPreferences.getString("response")!);
    print(globalResponse);

    if (globalResponse.containsKey("access_token")){
      globalToken = globalResponse["access_token"];
    }
    if (globalToken.isEmpty) {
      globalToken = sharedPreferences.getString("otp_token")!;
    }


    // setState(() {
      userLatLng = LatLng(currentLocationP.latitude, currentLocationP.longitude);

      if (globalResponse.containsKey("data") && globalResponse["data"].containsKey("has_book")) {
        _isBook = globalResponse["data"]["has_book"];
      }

      if (_isBook) {
        var url = Uri.parse(domainBackend + "/api/booking");
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

                PointLatLng destination = PointLatLng(double.parse(data["drop_off_lat"]),
                    double.parse(data["drop_off_long"]));
                setPolylines(destination);
                driversInfo = data["driver"];
              } else {
                notify(context, "No response");
              }
            } else {
              _isBook = false;
              setState(() => _isLoading = false);
              // notify(context, response.statusCode.toString());
            }
          } else {
            notify(context, "server error");
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    // });
    print('user location $userLatLng');
  }

  void getDetails(String placeId) async {
    var result = await this.googlePlace.details.get(placeId);
    if (result != null && result.result != null && mounted) {
      setState(() {
        detailsPlaceResult = result.result!;
        print(detailsPlaceResult.geometry!.location!.lat.toString());
        print(detailsPlaceResult.geometry!.location!.lng.toString());
      });
    }
  }

  callbackDetailsResult(DetailsResult value) {
    // setState(() {
      detailsPlaceResult = value;
      print("detailsPlaceResult.reference");
      print(detailsPlaceResult.reference);
      print(detailsPlaceResult.geometry!.location!.lat.toString());
      print(detailsPlaceResult.geometry!.location!.lng.toString());
      print(detailsPlaceResult.geometry!.location!.lat!.toDouble());
      print(detailsPlaceResult.geometry!.location!.lng!.toDouble());
      PointLatLng destination = PointLatLng(detailsPlaceResult.geometry!.location!.lat!.toDouble(),
          detailsPlaceResult.geometry!.location!.lng!.toDouble());

      setState(() => _isLoading = true);
      setPolylines(destination);
    // });
  }

  callbackPassengerCount(int value) {
    _itemCount = value;
  }

  setPolylines(PointLatLng destination) async {

    userLatLng = await getUserLocation();
    destinationLatLng = destination;

    print(userLatLng.latitude);
    print(userLatLng.longitude);

    List<LatLng> polylineCoordinates = [];
    LatLng sourcePin;
    LatLng destPin;

    PolylineResult result = await
    polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(userLatLng.latitude, userLatLng.longitude),
        destination);

    print("result.points");
    print(result.points);
    print(result.points[0]);
    print(result.points[result.points.length - 1]);

    sourcePin = LatLng(result.points[0].latitude, result.points[0].longitude);
    destPin = LatLng(result.points[result.points.length - 1].latitude, result.points[result.points.length - 1].longitude);

    result.points.forEach((PointLatLng point){
      polylineCoordinates.add(
          LatLng(point.latitude, point.longitude));
    });

    // final coordinates = new Coordinates(destination.latitude, destination.longitude);
    // var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    // var first = addresses.first;
    // print("${first.featureName} : ${first.addressLine}");
    // destinationName = first.addressLine;
    destinationName = await _getAddressName(destination);

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs
      Polyline polyline = Polyline(
          polylineId: PolylineId('poly'),
          points: polylineCoordinates,
          width: 5
      );
      routeDistance = _calculateDistance(polylineCoordinates);
      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map
      _polylines.clear();
      _polylines.add(polyline);
      _markers.clear();
      _markers.add(Marker(
          markerId: MarkerId('sourcePin'),
          position: sourcePin));
      // destination pin
      _markers.add(
        Marker(
          // icon: Icons.pin,
          draggable: true,
          markerId: MarkerId('destPin'),
          position: destPin,
          onDragEnd: (newPosition) {
            print("newPosition");
            print(newPosition.latitude);
            print(newPosition.longitude);
            if (!_isBook) {
              setState(() => setPolylines(PointLatLng(newPosition.latitude, newPosition.longitude)));
            }
          },
        ),
      );
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValue();
    timer = Timer.periodic(Duration(seconds: 3), (Timer t) => checkBooking());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  checkBooking() {
    if (_isBook && !_isBookConfirm) {
      print("pasok");
      var url = Uri.parse(domainBackend + "/api/booking");

      if (driversInfo == null) {
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
                var data = jsonResponse["data"];
                driversInfo = data["driver"];
              } else {
                notify(context, "No response");
              }
            } else {
              setState(() => _isBook = false);
              // notify(context, response.statusCode.toString());
            }
          } else {
            notify(context, "server error");
          }
        });
      }

      if (driversInfo != null) {
        setState(() => _isBookConfirm = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("routeDistance");
    print(routeDistance);
    print("_isBook");
    print(_isBook);
    print("_isLoading");
    print(_isLoading);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body:  _isLoading ? Center(child: CircularProgressIndicator()) : SafeArea(
        child:
        Column(
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
              (routeDistance != 0.0 || _isBook)  ? confirmButtonSection() : searchButtonSection(),
              Expanded(
                child: Container(
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                        target: userLatLng,
                        zoom: 17.0,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      controller.animateCamera(
                          CameraUpdate.newLatLngBounds(
                              LatLngBounds(
                                  southwest: LatLng(
                                      userLatLng.latitude <= destinationLatLng.latitude
                                        ? userLatLng.latitude
                                        : destinationLatLng.latitude,
                                      userLatLng.longitude <= destinationLatLng.longitude
                                        ? userLatLng.longitude
                                        : destinationLatLng.longitude),
                                  northeast: LatLng(
                                      userLatLng.latitude <= destinationLatLng.latitude
                                        ? destinationLatLng.latitude
                                        : userLatLng.latitude,
                                      userLatLng.longitude <= destinationLatLng.longitude
                                        ? destinationLatLng.longitude
                                        : userLatLng.longitude),
                              ),
                              50)
                      );
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    indoorViewEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }

  Container searchButtonSection() {
    String fname = "";

    if (globalResponse.containsKey("data")
    && globalResponse["data"].containsKey("fname")){
      print(globalResponse["data"]["fname"]);
      fname = globalResponse["data"]["fname"];
    }

    if (fname.isEmpty){
      print("empty");
      print("globalResponse");
      print(globalResponse);
      refreshUserInfo();

      fname = globalResponse["data"]["fname"];
    }

    return Container(
      width: MediaQuery.of(context).size.width,
      // height: 160,
      height: MediaQuery.of(context).size.height * 0.25,
      // padding: EdgeInsets.symmetric(horizontal: 15.0),
      // margin: EdgeInsets.only(bottom: 15.0),
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
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text("Where do you want to go?",
                textAlign: TextAlign.left,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genPrimaryColor),
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
                    Icon(Icons.location_pin),
                    Text(
                      "  Enter a destination",
                      style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genUnselectedColor),
                    ),
                  ],
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                  side: BorderSide(width: 1.0, color: genUnselectedColor),
                  backgroundColor: genBackgroundColor,
                ),
                onPressed: showSearchPlacePageModal,
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
                onPressed: showBookingHistoryPageModal,
              ),
            ),
            // ButtonSolid(onPressed: () {  }, text: 'Confirm',),
          ],
        ),
      ),
    );
  }

  Container confirmButtonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.40,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            SizedBox(height: 5),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text(destinationName,
                textAlign: TextAlign.left,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20, color: genUnselectedColor),
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text("Distance: $routeDistance km",
                textAlign: TextAlign.center,
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 25, ),
              ),
            ),
            SizedBox(height: 10),
            (!_isBook) ? Row(children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
                child: Text("Passenger count:",
                  style: TextStyle( fontWeight: FontWeight.bold, fontSize: 25, color: genPrimaryColor),
                ),
              ),
              NumberInputWithIncrementDecrement(callback: callbackPassengerCount),
            ],) : Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 5),
              child: Text( _isBookConfirm ? driversInfo['fname']+" "+driversInfo['lname']+"\n0"+driversInfo['mobile_no']+"\nPlate No: "+driversInfo['plate_no']
                  : "Waiting for a driver ...",
                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 25, color: genPrimaryColor),
              ),
            ),
            SizedBox(height: 10),
            (!_isBook) ? Row(
              children: [
                Expanded(
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    height: 55.0,
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonSolid(
                      text: 'Confirm',
                      onPressed: () {
                        print("confirm");
                        _confirmBooking();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    // width: MediaQuery.of(context).size.width,
                    height: 55.0,
                    // padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    padding: EdgeInsets.only(right: horizontalPadding),
                    margin: EdgeInsets.only(top: 5, bottom: 10.0),
                    child: ButtonOutline(
                      text: 'Cancel',
                      onPressed: () {
                        setState(() {
                          routeDistance = 0.0;
                          _polylines.clear();
                          _markers.clear();
                        });
                      },
                    ),
                  ),
                ),
              ],
            ):
            Container(
              height: 55.0,
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              margin: EdgeInsets.only(top: 5, bottom: 10.0),
              child: ButtonOutline(
                text: 'Cancel',
                onPressed: _cancelBooking,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showSearchPlacePageModal(){
    showMaterialModalBottomSheet(
      context: context,
      builder: (builder){
        return SearchPlacePage(callback: callbackDetailsResult);
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

  _confirmBooking() async {
    var polyline = _polylines.first;
    var points = polyline.points;
    var userPoint = points.first;
    var disPoint = points.last;
    var userAddress = await _getAddressName(userLatLng);

    Map data = {
      "pick_up_location" : userAddress,
      "pick_up_long" : userPoint.longitude.toString(),
      "pick_up_lat" : userPoint.latitude.toString(),
      "drop_off_location" : destinationName,
      "drop_off_long" : disPoint.longitude.toString(),
      "drop_off_lat": disPoint.latitude.toString(),
      "passenger_count": _itemCount.toString()
    };
    print("data $data");

    var url = Uri.parse(domainBackend + "/api/booking");
    var token = globalResponse["access_token"];
    print("access_token $token");

    http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
        body: data,
    ).then((response) {
      print("response.statusCode");
      print(response.statusCode);

      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(response.statusCode);

        if(response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            // Navigator.of(context).pushNamedAndRemoveUntil(MapPage.routeName, (route) => false);
            // notify(context, "ok");
          } else {
            notify(context, "No respond");
          }
        } else {
          notify(context, jsonResponse != null ? jsonResponse["message"]: "Invalid credentials");
        }
      } else {
        notify(context, "server error, try again later");
      }
    });

    setState(() => _isBook = true);
  }

  _cancelBooking() {
    var url = Uri.parse(domainBackend + "/api/booking-cancel");
    var token = globalResponse["access_token"];

    http.put(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      }
    ).then((response) {
      print("response.statusCode");
      print(response.statusCode);

      if (response.statusCode != 500) {
        var jsonResponse = json.decode(response.body);
        print(response.statusCode);

        if(response.statusCode >= 200 && response.statusCode <= 299) {
          if(jsonResponse != null) {
            // Navigator.of(context).pushNamedAndRemoveUntil(MapPage.routeName, (route) => false);
            // notify(context, jsonResponse != null ? jsonResponse["message"]: "Booking was canceled");
            setState(() => _isBook = false);
          } else {
            notify(context, "No respond");
          }
        } else {
          notify(context, jsonResponse != null ? jsonResponse["message"]: "Invalid credentials");
        }
      } else {
        notify(context, "server error, try again later");
      }
    });
  }
}
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BookingsPage extends StatefulWidget {
  final Function callback;
  final String token;
  final LatLng userLatLng;
  const BookingsPage({Key? key, required this.callback,
    required this.token,
    required this.userLatLng}) : super(key: key);

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  var bookings = [];
  bool _isLoading = true;

  initializeValue() {
    var url = Uri.parse(domainBackend + "/api/driver-booking");

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.token},
    ).then((response) async {
      print(response.statusCode);
      print(response.body);
      var jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey("data")) {
        bookings = jsonResponse['data'];
        print("bookings");
        print(bookings);
        var filterBookings = [];

        for(final booking in bookings){
          print("booking");
          print(booking);
          if (booking['driver_id'] == null) {
            // get only within 3 km distance
            var pickUpLat = num.parse(booking['pick_up_lat']).toDouble();
            var pickUpLong = num.parse(booking['pick_up_long']).toDouble();
            var distance = await getDistance(PointLatLng(pickUpLat, pickUpLong));

            if (distance <= 3.0) {
              filterBookings.add(booking);
            }
          }
        }
        bookings = filterBookings;
      }
      setState(() => _isLoading = false);
    });
  }

  getDistance(pickUpLoc) async {
    PolylineResult result = await
    PolylinePoints().getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(widget.userLatLng.latitude, widget.userLatLng.longitude),
        pickUpLoc);

    List<LatLng> polylineCoordinates = [];

    result.points.forEach((PointLatLng point){
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    });

    return _calculateDistance(polylineCoordinates);
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValue();

  }

  @override
  Widget build(BuildContext context) {
    print("bookings " + bookings.toString());

    return Scaffold(
      body:  SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                children: [
                  IconButton(
                    icon: new Icon(Icons.close_sharp, color: genSecondColor, size: 30,),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    "Available bookings",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              bookings.isEmpty ? Center(child: noAvailableBooking()) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    var infoLoc = bookings[index]['pick_up_location'].toString() + '\nto\n' + bookings[index]['drop_off_location'].toString();
                    return ListTile(
                      leading: CircleAvatar(
                        child: Icon( Icons.person_pin_outlined ),
                      ),
                      title: Text(
                        infoLoc,
                        textAlign: TextAlign.justify,
                      ),
                      onTap: () {
                        widget.callback(bookings[index]);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container noAvailableBooking() {
    return Container(
      child: Text(
        "No Available Booking.",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }
}

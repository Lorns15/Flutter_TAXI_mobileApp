import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/screens/operator/driversActivityLogs.dart';
import 'package:btsi_taxi/screens/operator/reports.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'driversInfoPage.dart';


class OperatorMainPage extends StatefulWidget {
  static const routeName = '/OperatorMainPage';
  @override
  OperatorMainPageState createState() => OperatorMainPageState();
}

class OperatorMainPageState extends State<OperatorMainPage> {
  bool _isLoading = true;
  bool _isLoadingMap = false;
  late Map<String, dynamic> globalResponse;
  late SharedPreferences sharedPreferences;
  var userLatLngDisplay = LatLng(15.945843, 120.255821);
  String globalToken = '';
  Timer? driversLocTimer;
  bool isDriversLocUpdate = false;
  Set<Marker> _markers = {};
  var driversData = [];

  initializeValue() async {
    sharedPreferences = await SharedPreferences.getInstance();
    globalResponse = json.decode(sharedPreferences.getString("response")!);

    if (globalResponse.containsKey("access_token")){
      globalToken = globalResponse["access_token"];
    }
    if (globalToken.isEmpty) {
      globalToken = sharedPreferences.getString("otp_token")!;
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeValue();
    driversLocTimer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkDriversLoc());
  }

  @override
  void dispose() {
    driversLocTimer?.cancel();
    super.dispose();
  }

  checkDriversLoc() {
    if (isDriversLocUpdate == false) {
      isDriversLocUpdate = true;
      var url = Uri.parse(domainBackend + "/api/drivers");

      http.get(
        url,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $globalToken'},
      ).then((response) {
        if (response.statusCode >= 200 && response.statusCode <= 299) {
          var jsonResponse = json.decode(response.body);

          if (jsonResponse != null) {
            isDriversLocUpdate = false;
            var data = jsonResponse["data"];
            _markers.clear();

            if (driversData.length != data.length) {
              driversData = data;
              print("driversData");
              print(driversData);
            }

            data.forEach((item){
              if (item["lat"] != null) {
                _markers.add(Marker(
                    markerId: MarkerId(item["id"].toString()),
                    position: LatLng(
                        double.parse(item["lat"]), double.parse(item["long"])))
                );
              }
            });
            setState(() {});
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator()) : SafeArea(
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.30,
                child: Center (
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      SizedBox(height: 5),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        height: 55.0,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        margin: EdgeInsets.only(top: 5, bottom: 10.0),
                        child: ElevatedButton(
                          child: Row(
                            children: [
                              Icon(Icons.perm_device_info),
                              Text(
                                "  Drivers Information",
                                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: genPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                          ),
                          onPressed: () {
                            print(driversData);
                            showDriversInformation();
                          },
                        ),
                      ),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        height: 55.0,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        margin: EdgeInsets.only(top: 5, bottom: 10.0),
                        child: ElevatedButton(
                          child: Row(
                            children: [
                              Icon(Icons.history_edu),
                              Text(
                                "  Drivers Activity logs",
                                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: genPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                          ),
                          onPressed: () {
                            showDriversActivityLogs();
                          },
                        ),
                      ),
                      Container(
                        // width: MediaQuery.of(context).size.width,
                        height: 55.0,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        margin: EdgeInsets.only(top: 5, bottom: 10.0),
                        child: ElevatedButton(
                          child: Row(
                            children: [
                              Icon(Icons.history_edu),
                              Text(
                                "  Reports",
                                style: TextStyle( fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: genPrimaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
                          ),
                          onPressed: () {
                            showReports();
                          },
                        ),
                      ),
                    ]
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  child: _isLoadingMap ? Center(child: CircularProgressIndicator()) : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: userLatLngDisplay,
                      zoom: 8.0,
                    ),
                    // myLocationEnabled: true,
                    indoorViewEnabled: true,
                    markers: _markers,
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }

  showDriversInformation() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return DriversInfoPage(driversData: driversData, globalToken: globalToken,);
        }
    );
  }

  showDriversActivityLogs() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return DriversActivityLogs(driversData: driversData, globalToken: globalToken,);
        }
    );
  }

  showReports() {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return ReportsPage(globalToken: globalToken);
        }
    );
  }
}
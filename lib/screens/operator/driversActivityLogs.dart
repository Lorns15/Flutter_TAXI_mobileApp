import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DriversActivityLogs extends StatefulWidget {
  final globalToken;
  final driversData;
  const DriversActivityLogs({Key? key, required this.driversData, required this.globalToken}) : super(key: key);

  @override
  _DriversActivityLogsState createState() => _DriversActivityLogsState();
}

class _DriversActivityLogsState extends State<DriversActivityLogs> {
  bool _isLoading = true;
  var activityData = [];
  var globalDriverData = [];

  initializeValue() {
    globalDriverData = widget.driversData;
    var url = Uri.parse(domainBackend + "/api/driver/logs");

    http.get(
      url,
      headers: {HttpHeaders.authorizationHeader: 'Bearer '+widget.globalToken},
    ).then((response) {
      print(response.statusCode);
      print(response.body);
      setState(() {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey("data") && response.statusCode == 200) {
          // var tempDat = jsonResponse['data'];
          jsonResponse['data'].forEach((item){
            if (GetName(item['user_id'].toString()) != "") {
              activityData.add(item);
            }
          });
        }
        _isLoading = false;
      });
    });
    print(activityData);
  }

  @override
  void initState() {
    // TODO: implement initState
    initializeValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    "Drivers Activity Logs",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              activityData.isEmpty ? Center(child: noActivitylog()) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: activityData.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(top: 10.0),
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: RichText(
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                    text: "Description: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: activityData[index]['description'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Date: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: activityData[index]['created_at'].toString().substring(0, 10) + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Time: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: activityData[index]['created_at'].toString().substring(12, 19) + "\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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

  Container noActivitylog() {
    return Container(
      child: Text(
        "No Drivers Activity.",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }

  String GetName(driverId){
    for (int i = 0; i < globalDriverData.length; i++) {
      print(globalDriverData[i]['id'].toString() );
      if (globalDriverData[i]['id'].toString() == driverId) {

        return globalDriverData[i]['lname'].toString() + ", " + globalDriverData[i]['fname'].toString();
      }
    }
    return "";
  }
}

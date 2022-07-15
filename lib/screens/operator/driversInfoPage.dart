import 'dart:convert';
import 'dart:io';

import 'package:btsi_taxi/Utility/colors.dart';
import 'package:btsi_taxi/Utility/environment.dart';
import 'package:btsi_taxi/Utility/snackBar.dart';
import 'package:btsi_taxi/Utility/widgets/buttons.dart';
import 'package:btsi_taxi/screens/operator/driverLog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'driverRatingAndComments.dart';


class DriversInfoPage extends StatefulWidget {
  final driversData;
  final globalToken;
  const DriversInfoPage({Key? key, required this.driversData, required this.globalToken}) : super(key: key);

  @override
  _DriversInfoPageState createState() => _DriversInfoPageState();
}

class _DriversInfoPageState extends State<DriversInfoPage> {
  // var bookings = [];
  bool _isLoading = true;
  var globalDriverData;

  initializeValue() {
    setState(() {
      globalDriverData = widget.driversData;
      print("globalDriverData");
      print(globalDriverData);
      print(globalDriverData[0]['driver_license_photo'].runtimeType);
      _isLoading = false;
    });
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
                    "Drivers Information",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading ? Center(child: CircularProgressIndicator()) :
              globalDriverData.isEmpty ? Center(child: noAvailableBooking()) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: globalDriverData.length,
                  itemBuilder: (context, index) {
                    // child: Text(globalDriverData[index].toString()),
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
                                    text: "Name: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['lname'].toString() + ", " + globalDriverData[index]['fname'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Date of Birth: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['bday'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Address: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['address'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Mobile no: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "0" + globalDriverData[index]['mobile_no'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Max Qouta per day: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['qouta_per_day'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "rating: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['rating'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Is Confirmed: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['is_confirmed'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "Driver License: ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: globalDriverData[index]['driver_license'].toString() + "\n\n",
                                    style: TextStyle(
                                      color: genThirdColor,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ]
                              ),
                            )
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            margin: EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              width: 200.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                image: DecorationImage(
                                    image: NetworkImage(
                                      domainBackend+"/"+globalDriverData[index]['driver_license_photo'].toString(),
                                    ),
                                    fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                          !globalDriverData[index]['is_confirmed'] ? Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            margin: EdgeInsets.only(bottom: 10.0),
                            alignment: Alignment.bottomRight,
                            child: ButtonSolid(
                              text: "Confirm",
                              onPressed: () {
                                confirmDialog(index);
                              },
                            ),
                          ) : Container(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            margin: EdgeInsets.only(bottom: 10.0),
                            // alignment: Alignment.bottomRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ButtonSolid(
                                  text: "Reviews",
                                  onPressed: () {
                                    showDriverRatingsAndComments(globalDriverData[index]['id'].toString());
                                  },
                                ),
                                SizedBox(width: 20,),
                                ButtonSolid(
                                  text: "View log",
                                  onPressed: () {
                                    showDriverActivityLogs(globalDriverData[index]['id'].toString());
                                  },
                                ),
                              ],
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

  Container noAvailableBooking() {
    return Container(
      child: Text(
        "No Drivers Information.",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: genSecondColor),
      ),
    );
  }

  confirmDialog(index) {
      // set up the button
    Widget yesButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith (
              (Set  states) {
            if (states.contains(MaterialState.pressed))
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            return genPrimaryColor; // Use the component's default.
          },
        ),
      ),
      child: Text("Yes", style: TextStyle(fontSize: 18.0, color: Colors.white)),
      onPressed: () {
        print("Yes");
        Navigator.of(context).pop();
        setState(() => _isLoading = true);
        var url = Uri.parse(domainBackend + "/api/drivers/" + globalDriverData[index]["id"].toString());
        var token = widget.globalToken;

        http.put(
          url,
          headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
        ).then((response) {
          print(response.statusCode);

          if (response.statusCode != 500) {
            var jsonResponse = json.decode(response.body);
            print(jsonResponse);

            if (response.statusCode >= 200 && response.statusCode <= 299) {
              if(jsonResponse != null) {
                notify(context, jsonResponse["message"]);
                globalDriverData[index]["is_confirmed"] = true;
              } else {
                notify(context, "No response");
              }
            } else {
              notify(context, response.statusCode);
            }
          } else {
            notify(context, "server error");
          }
          setState(() => _isLoading = false);
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Account Confirmation"),
      content: Text("Are you sure to confirm " + globalDriverData[index]["fname"] + " " + globalDriverData[index]["lname"] + " account?"),
      actions: [
        yesButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showDriverActivityLogs(id) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return DriverLog(driverId: id, globalToken: widget.globalToken);
        }
    );
  }

  showDriverRatingsAndComments(id) {
    showMaterialModalBottomSheet(
        context: context,
        builder: (builder){
          return DriverRatingAndComments(driverId: id, globalToken: widget.globalToken);
        }
    );
  }
}
